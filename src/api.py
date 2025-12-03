from fastapi import FastAPI, UploadFile, File, HTTPException, Form, Security, Depends
from fastapi.security import APIKeyHeader
from fastapi.responses import JSONResponse, FileResponse
from typing import List, Optional
import tempfile
import traceback
import json
import httpx
import os
import sys
from pathlib import Path
import dotenv

# Load environment variables
env_path = Path(__file__).parent.parent / '.env'
dotenv.load_dotenv(dotenv_path=env_path)

# Add src directory to Python path
sys.path.insert(0, str(Path(__file__).parent))

from OpenRouter import client
from utils import export_results_to_excel
from ExtractText import extract_text_from_pdf, extract_text_from_jd
from ExtractLLM import analyze_cv, analyze_jd, summarize_jd
from Scoring import compute_match_score

from fastapi.middleware.cors import CORSMiddleware

# ==========================
# API KEY AUTHENTICATION
# ==========================
API_KEY_NAME = "X-API-Key"
api_key_header = APIKeyHeader(name=API_KEY_NAME, auto_error=False)

# Get API key from environment
API_KEY = os.getenv("API_SECRET_KEY")

if not API_KEY:
    print("WARNING: API_SECRET_KEY not set in .env file. API will be unprotected!")
    API_KEY = None  


async def verify_api_key(api_key: str = Security(api_key_header)):
    """Verify the API key from request header."""
    # If no API key is configured, allow all requests (development mode)
    if API_KEY is None:
        return True
    
    # Check if API key is provided
    if api_key is None:
        raise HTTPException(
            status_code=401,
            detail="Missing API Key. Please provide X-API-Key header."
        )
    
    # Verify API key matches
    if api_key != API_KEY:
        raise HTTPException(
            status_code=403,
            detail="Invalid API Key"
        )
    
    return True


# ==========================
# INIT
# ==========================
app = FastAPI(title="CV–JD Matching API")

# client = load_client()



# ==========================
# UTILS
# ==========================
async def extract_and_analyze(file_path: str, file_type: str):
    """Trích xuất và phân tích CV hoặc JD."""
    if file_type == "cv":
        with open(file_path, "rb") as f:
            text = extract_text_from_pdf(f)
        return await analyze_cv(client, text)
    elif file_type == "jd":
        text = extract_text_from_jd(file_path)
        return await analyze_jd(client, text)
    else:
        raise ValueError("file_type phải là 'cv' hoặc 'jd'")

# ==========================
# ROUTES
# ==========================
@app.get("/")
def root():
    return {"message": "Welcome to CV–JD Matching API 🚀"}


@app.post("/match")
async def match_single_cv_jd(
    cv: UploadFile = File(...),
    jd: UploadFile = File(...),
    weights: Optional[str] = Form(None),
    authenticated: bool = Depends(verify_api_key)
):
    """Phân tích 1 CV và 1 JD, trả về điểm khớp với trọng số tùy chọn."""
    try:
        # parse weights nếu có
        user_weights = json.loads(weights) if weights else None

        with tempfile.NamedTemporaryFile(delete=False, suffix=".pdf") as cv_tmp:
            cv_tmp.write(await cv.read())
            cv_path = cv_tmp.name

        with tempfile.NamedTemporaryFile(delete=False, suffix=".pdf") as jd_tmp:
            jd_tmp.write(await jd.read())
            jd_path = jd_tmp.name

        cv_json = await extract_and_analyze(cv_path, "cv")
        jd_json = await extract_and_analyze(jd_path, "jd")

        scores = compute_match_score(cv_json, jd_json, weights=user_weights)

        return JSONResponse({
            "cv_filename": cv.filename,
            "jd_filename": jd.filename,
            "match_score": scores
        })

    except Exception as e:
        print("[Error]", traceback.format_exc())
        raise HTTPException(status_code=500, detail=f"Server error: {e}")

async def download_file_from_url(url: str) -> str:
    """Tải file từ URL về và trả về file path."""
    try:
        async with httpx.AsyncClient() as client:
            response = await client.get(url)
            response.raise_for_status()

        suffix = ".pdf"  # tùy bạn
        with tempfile.NamedTemporaryFile(delete=False, suffix=suffix) as tmp:
            tmp.write(response.content)
            return tmp.name
    except Exception as e:
        raise HTTPException(status_code=400, detail=f"Không tải được file từ URL: {e}")


@app.get("/download/{filename}")
async def download_file(filename: str):
    file_path = f"/tmp/{filename}"
    return FileResponse(
        file_path,
        media_type="application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
        filename=filename
    )

@app.post("/match/multiple")
async def match_multiple_cvs(
    jd: Optional[UploadFile] = File(None),
    jd_url: Optional[str] = Form(None),
    cvs: Optional[List[UploadFile]] = File(None),
    cv_urls: Optional[str] = Form(None),  # dạng JSON list string
    weights: Optional[str] = Form(None),
    authenticated: bool = Depends(verify_api_key)
):
    """Nhận 1 JD và nhiều CV từ file hoặc URL."""
    try:
        user_weights = json.loads(weights) if weights else None

        # --- Xử lý JD ---
        if jd:
            with tempfile.NamedTemporaryFile(delete=False, suffix=".pdf") as jd_tmp:
                jd_tmp.write(await jd.read())
                jd_path = jd_tmp.name
        elif jd_url:
            jd_path = await download_file_from_url(jd_url)
        else:
            raise HTTPException(status_code=400, detail="Bạn phải gửi JD hoặc JD URL!")

        jd_json = await extract_and_analyze(jd_path, "jd")
        results = []

        # --- Xử lý danh sách CV ---
        cv_url_list = json.loads(cv_urls) if cv_urls else []

        # 1) File upload
        if cvs:
            for cv in cvs:
                with tempfile.NamedTemporaryFile(delete=False, suffix=".pdf") as cv_tmp:
                    cv_tmp.write(await cv.read())
                    cv_path = cv_tmp.name

                try:
                    cv_json = await extract_and_analyze(cv_path, "cv")
                    scores = compute_match_score(cv_json, jd_json, weights=user_weights)
                    results.append({
                        "cv_filename": cv.filename,
                        "match_score": scores,
                        "cv_data": cv_json
                    })
                except Exception as inner_e:
                    results.append({
                        "cv_filename": cv.filename,
                        "error": str(inner_e)
                    })

        # 2) CV từ URLs
        for url in cv_url_list:
            try:
                cv_path = await download_file_from_url(url)
                cv_json = await extract_and_analyze(cv_path, "cv")
                scores = compute_match_score(cv_json, jd_json, weights=user_weights)
                results.append({
                    "cv_url": url,
                    "match_score": scores,
                    "cv_data": cv_json
                })
            except Exception as inner_e:
                results.append({
                    "cv_url": url,
                    "error": str(inner_e)
                })
        excel_path = export_results_to_excel(results)
        excel_filename = os.path.basename(excel_path)
        return JSONResponse({
            "jd_source": jd.filename if jd else jd_url,
            "results": results,
            "excel_download_url": f"{os.getenv('BASE_URL', 'http://127.0.0.1:8000')}/download/{excel_filename}"
        })


    except Exception as e:
        print("[Error]", traceback.format_exc())
        raise HTTPException(status_code=500, detail=f"Server error: {e}")


@app.post("/summarize-jd")
async def summarize_job_description(
    jd_text: Optional[str] = Form(None),
    jd_file: Optional[UploadFile] = File(None),
    jd_url: Optional[str] = Form(None),
    authenticated: bool = Depends(verify_api_key)
):
    """
    Summarize a job description and return structured JSON.
    
    You can provide the job description in one of three ways:
    1. jd_text: Direct text input
    2. jd_file: Upload a PDF file
    3. jd_url: URL to a PDF file
    
    Returns a structured summary with:
    - Job title, company, location
    - Summary overview
    - Key responsibilities
    - Key requirements
    - Experience level, salary, benefits
    """
    try:
        # Determine the source and extract text
        if jd_text:
            text = jd_text
            source = "text_input"
        elif jd_file:
            with tempfile.NamedTemporaryFile(delete=False, suffix=".pdf") as tmp:
                tmp.write(await jd_file.read())
                tmp_path = tmp.name
            text = extract_text_from_jd(tmp_path)
            source = jd_file.filename
        elif jd_url:
            jd_path = await download_file_from_url(jd_url)
            text = extract_text_from_jd(jd_path)
            source = jd_url
        else:
            raise HTTPException(
                status_code=400,
                detail="You must provide one of: jd_text, jd_file, or jd_url"
            )
        
        # Validate that we have text
        if not text or len(text.strip()) < 10:
            raise HTTPException(
                status_code=400,
                detail="Job description text is too short or empty"
            )
        
        # Generate summary
        summary = await summarize_jd(client, text)
        
        # Check for errors in the result
        if "error" in summary:
            raise HTTPException(
                status_code=500,
                detail=f"Failed to generate summary: {summary.get('error')}"
            )
        
        return JSONResponse({
            "success": True,
            "source": source,
            "summary": summary
        })
    
    except HTTPException:
        raise
    except Exception as e:
        print("[Error]", traceback.format_exc())
        raise HTTPException(status_code=500, detail=f"Server error: {e}")


# ==========================
# CORS MIDDLEWARE
# ==========================
# app.add_middleware(
#     CORSMiddleware,
#     allow_origins=["*"],  # In production, specify actual origins
#     allow_credentials=True,
#     allow_methods=["*"],
#     allow_headers=["*"],
# )

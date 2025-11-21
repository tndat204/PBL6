from fastapi import FastAPI, UploadFile, File, HTTPException, Form
from fastapi.responses import JSONResponse, FileResponse
from typing import List, Optional
import tempfile
import traceback
import json
import httpx
import os
from LangchainClient import client
from utils import export_results_to_excel
from ExtractText import extract_text_from_pdf, extract_text_from_jd
from ExtractLLM import  analyze_cv, analyze_jd
from Scoring import compute_match_score

from fastapi.middleware.cors import CORSMiddleware


# ==========================
# INIT
# ==========================
app = FastAPI(title="CV–JD Matching API")

# client = load_client()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],     # Cho phép mọi domain
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


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
    weights: Optional[str] = Form(None)
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
    weights: Optional[str] = Form(None)
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
            "excel_download_url": f"http://127.0.0.1:8000/download/{excel_filename}"
        })

    except Exception as e:
        print("[Error]", traceback.format_exc())
        raise HTTPException(status_code=500, detail=f"Server error: {e}")

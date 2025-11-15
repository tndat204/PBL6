

from fastapi import FastAPI, UploadFile, File, HTTPException, Form
from fastapi.responses import JSONResponse
from typing import List, Optional
import tempfile
import traceback
import json

from LangchainClient import client

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


@app.post("/match/multiple")
async def match_multiple_cvs(
    jd: UploadFile = File(...),
    cvs: List[UploadFile] = File(...),
    weights: Optional[str] = Form(None)
):
    """Nhận 1 JD và nhiều CV, có thể cấu hình trọng số."""
    try:
        user_weights = json.loads(weights) if weights else None

        with tempfile.NamedTemporaryFile(delete=False, suffix=".pdf") as jd_tmp:
            jd_tmp.write(await jd.read())
            jd_path = jd_tmp.name

        jd_json = await extract_and_analyze(jd_path, "jd")
        results = []

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

        return JSONResponse({
            "jd_filename": jd.filename,
            "results": results
        })

    except Exception as e:
        print("[Error]", traceback.format_exc())
        raise HTTPException(status_code=500, detail=f"Server error: {e}")

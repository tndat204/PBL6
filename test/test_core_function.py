#!/usr/bin/env python3
"""
CV–JD Matching CLI using LLM extraction + rule-based scoring.
Usage:
    python analyze.py --cv path/to/cv.pdf --jd path/to/jd.pdf
"""

import argparse
import sys
from pprint import pprint
from src.extract_text import extract_text_from_pdf, extract_text_from_jd
from src.llm_extract import load_client, analyze_cv, analyze_jd
from src.scoring import compute_match_score

# --------------------------
# EXTRACT FUNCTION
# --------------------------
def extract_and_analyze(file_path, file_type, client):
    """Trích xuất và phân tích CV hoặc JD."""
    try:
        if file_type == "cv":
            with open(file_path, "rb") as f:
                text = extract_text_from_pdf(f)
            return analyze_cv(client, text)
        elif file_type == "jd":
            text = extract_text_from_jd(file_path)
            return analyze_jd(client, text)
        else:
            raise ValueError("file_type phải là 'cv' hoặc 'jd'")
    except Exception as e:
        print(f"[Error] Lỗi khi xử lý {file_type.upper()}: {e}", file=sys.stderr)
        sys.exit(1)


# --------------------------
# MAIN
# --------------------------
def main():
    parser = argparse.ArgumentParser(description="CV–JD Matcher CLI")
    parser.add_argument("--cv", required=True, help="File CV PDF")
    parser.add_argument("--jd", required=True, help="File JD PDF")
    args = parser.parse_args()

    client = load_client()

    print("=== 🧠 Đang phân tích CV ===")
    cv_json = extract_and_analyze(args.cv, "cv", client)

    print("\n=== 🧠 Đang phân tích JD ===")
    jd_json = extract_and_analyze(args.jd, "jd", client)

    print("\n=== ✅ Dữ liệu trích xuất ===")
    print("\n--- CV ---")
    pprint(cv_json)
    print("\n--- JD ---")
    pprint(jd_json)

    print("\n=== ⚖️ Đang tính điểm khớp ===")
    scores = compute_match_score(cv_json, jd_json)
    pprint(scores)
    print("\nTổng điểm phù hợp:", scores["TotalScore"], "/ 100")



if __name__ == "__main__":
    main()

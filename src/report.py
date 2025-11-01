"""
report.py
Định dạng và ghi báo cáo kết quả scoring ra console hoặc file.
"""

def print_report(result):
    print("==== CV Scoring Result ====")
    print(f"Total score: {result.get('total_score', 0)}")
    print("---- Breakdown ----")
    for key, value in result.get("breakdown", {}).items():
        print(f"{key}: {value}")
    if result.get("missing"):
        print("---- Missing/Not Matched ----")
        for missing in result["missing"]:
            print(missing)

def save_report(result, filepath):
    import json
    with open(filepath, "w", encoding="utf-8") as f:
        json.dump(result, f, indent=2, ensure_ascii=False)
    print(f"[INFO] Report saved to {filepath}")
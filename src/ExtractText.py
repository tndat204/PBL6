import os
from PyPDF2 import PdfReader
# from docx import Document 

def extract_text_from_pdf(file) -> str:
    """
    Đọc văn bản từ file PDF (CV hoặc JD), trả về chuỗi text sạch.
    """
    reader = PdfReader(file)
    pages_text = []
    for page in reader.pages:
        text = page.extract_text() or ""
        pages_text.append(text)
    return "\n".join(pages_text).strip()

def extract_text_from_txt(file):
    """
    Đọc văn bản từ file txt.
    """
    if hasattr(file, "read"):
        return file.read().decode('utf-8')
    else:
        with open(file, encoding="utf-8") as f:
            return f.read()

def extract_text_from_docx(file):
    """
    Đọc văn bản từ file Word DOCX (placeholder!)
    """
    raise NotImplementedError("extract_text_from_docx chưa hỗ trợ.")


def extract_text_from_jd(file_path):
    """
    Tự động detect file type (pdf, docx, txt) và extract text JD phù hợp.
    """
    ext = os.path.splitext(file_path)[1].lower()
    if ext == ".pdf":
        with open(file_path, "rb") as f:
            return extract_text_from_pdf(f)
    elif ext == ".txt":
        return extract_text_from_txt(file_path)
    elif ext == ".docx":
        return extract_text_from_docx(file_path)  # Chưa xài được
    else:
        raise ValueError(f"Unsupported JD filetype: {ext}")

import os
import json
import time
from dotenv import load_dotenv
from typing import Dict, Any
import asyncio
from OpenRouter import client


SKILL_DICTIONARY = {
    "ProgrammingLanguages": [
        "Python", "Java", "JavaScript", "TypeScript", "C", "C++", "C#", "PHP",
        "Go", "Ruby", "Kotlin", "Swift", "R", "HTML/CSS", "SQL", "NoSQL"
    ],
    "Frameworks": [
        "React", "Angular", "Vue.js", "Next.js", "Node.js", "Express",
        "Django", "Flask", "Spring Boot", "Spring MVC", "Spring Security",
        "ASP.NET", "Laravel", "Symfony", "jQuery", "Bootstrap", "TailwindCSS",
        "TensorFlow", "PyTorch", "Keras"
    ],
    "Databases": [
        "MySQL", "PostgreSQL", "SQLite", "Oracle", "MongoDB", "Redis",
        "Firebase", "SQL Server", "Elasticsearch"
    ],
    "Tools": [
        "Git", "Docker", "Kubernetes", "Jenkins", "CI/CD", "AWS", "GCP", "Azure",
        "Linux", "VS Code", "IntelliJ", "Eclipse", "Postman", "Figma", "Jira",
        "Trello"
    ],
    "Others": [
        "RESTful APIs", "GraphQL", "Microservices", "Agile/Scrum", "JSON/XML",
        "OOP", "Unit Testing", "Integration Testing", "DevOps", "Cloud Computing",
        "CI/CD Pipelines", "System Design", "Web Security", "Mobile Development"
    ],
    "SoftSkills": [
        "Teamwork", "Communication", "Problem Solving", "Creativity",
        "Adaptability", "Responsibility", "Proactive", "Attention to Detail",
        "Leadership", "Critical Thinking", "Honesty", "Time Management",
        "Independent Work", "English Reading Ability"
    ]
}


def skill_dict_text(skill_dict: dict) -> str:
    return "\n".join(
        [f"- {key}: {', '.join(values)}" for key, values in skill_dict.items()]
    )


def cv_extraction_prompt(cv_text: str, skill_dict: dict) -> str:
    return f"""
You are an expert resume parser. Extract information from the resume below and return a **pure JSON**.

### VERY STRICT RULES
1. Only use skills that exactly match this skill dictionary:
{skill_dict_text(skill_dict)}

2. You must not:
   - Create, rename, abbreviate, or expand any skill names.
   - Use lowercase or variants (e.g., 'react', 'React.js', 'ReactJS' → all invalid).
   - Add any skill not present in the list above.

3. If a skill does not match exactly, ignore it.

4. Output must be **only valid JSON**, no markdown, no explanation.

### JSON STRUCTURE
{{
  "TechnicalSkills": {{
    "ProgrammingLanguages": [],
    "Frameworks": [],
    "Tools": [],
    "Databases": [],
    "Others": []
  }},
  "SoftSkills": [],
  "Experience": {{
    "Years": null,
    "Roles": [],
    "Projects": [],
    "Achievements": []
  }},
  "Education": {{
    "Degree": null,
    "Major": null,
    "University": null,
    "GPA": null
  }},
  "Certifications": [],
  "Languages": [],
  "OtherInfo": []
}}

Now extract structured data from this resume:
---
{cv_text}
---
Return ONLY the valid JSON object.
"""


def jd_extraction_prompt(job_description: str, skill_dict: dict) -> str:
    return f"""
### STRICT RULES
1. Only use exact skill names from this dictionary:
{skill_dict_text(skill_dict)}

2. Never:
   - Add, abbreviate, or pluralize skills.
   - Use any variant (e.g., 'react.js', 'springboot', 'Html' → invalid).
   - Modify capitalization or punctuation.

3. If a skill is mentioned but not in the list, skip it.
4. Output must be valid JSON, **no markdown fences** (like ```json).

### JSON STRUCTURE
{{
  "TechnicalSkills": {{
    "ProgrammingLanguages": [],
    "Frameworks": [],
    "Tools": [],
    "Databases": [],
    "Others": []
  }},
  "SoftSkills": [],
  "Experience": {{
    "Years": null,
    "Roles": [],
    "Projects": [],
    "Achievements": []
  }},
  "Education": {{
    "Degree": null,
    "Major": null,
    "University": null,
    "GPA": null
  }},
  "Certifications": [],
  "Languages": [],
  "OtherInfo": []
}}

Now extract structured data from this job description:
---
{job_description}
---
Return only the JSON object.
"""

def safe_json_parse(content: str) -> Dict[str, Any]:
    """Parse JSON safely, avoid crash if model returns junk."""
    content = content.strip()
    if content.startswith("```"):
        content = content.strip("`").replace("json", "").strip()
    try:
        return json.loads(content)
    except json.JSONDecodeError:
        start, end = content.find("{"), content.rfind("}")
        if start != -1 and end != -1:
            try:
                return json.loads(content[start:end+1])
            except Exception:
                pass
        return {"error": "invalid_json", "raw_output": content}


def filter_valid_skills(extracted: Dict[str, Any], skill_dict: Dict[str, list]) -> Dict[str, Any]:
    """Remove skills not in SKILL_DICTIONARY."""
    valid = {k: {s.lower(): s for s in v} for k, v in skill_dict.items()}
    for cat, vals in extracted.get("TechnicalSkills", {}).items():
        cleaned = []
        for s in vals:
            if s.lower() in valid.get(cat, {}):
                cleaned.append(valid[cat][s.lower()])
        extracted["TechnicalSkills"][cat] = cleaned
    return extracted

async def with_retry(func, max_retries=3, delay=2):
    for attempt in range(1, max_retries + 1):
        result = await func()
        if isinstance(result, dict) and "error" not in result:
            return result
        print(f"[Retry {attempt}/{max_retries}] Invalid JSON, retrying...")
        await asyncio.sleep(delay)
    return {"error": "max_retries_exceeded"}




async def analyze_cv(client, cv_text: str) -> Dict[str, Any]:
    async def _extract():
        prompt = cv_extraction_prompt(cv_text, SKILL_DICTIONARY)
        
        # Gọi LLM async
        res = await client.generate(
            system_prompt="Bạn là một chuyên gia HR. Trích xuất thông tin từ CV dưới đây thành JSON có cấu trúc.",
            user_prompt=prompt,
            temperature=0.3,
            max_tokens=1024,
        )

        # Parse JSON an toàn
        result = safe_json_parse(res)
        if "error" not in result:
            result = filter_valid_skills(result, SKILL_DICTIONARY)
        return result

    # Retry wrapper async
    return await with_retry(_extract)
async def analyze_jd(client, jd_text: str) -> Dict[str, Any]:
    async def _extract():
        prompt = jd_extraction_prompt(jd_text, SKILL_DICTIONARY)
        res = await client.generate(
            system_prompt="Bạn là một chuyên gia HR. Trích xuất thông tin từ Job Description dưới đây thành JSON có cấu trúc.",
            user_prompt=prompt,
            temperature=0.3,
            max_tokens=1024,
        )
        result = safe_json_parse(res)
        if "error" not in result:
            result = filter_valid_skills(result, SKILL_DICTIONARY)
        return result

    return await with_retry(_extract)


def jd_summary_prompt(job_description: str) -> str:
    """Generate prompt for summarizing job description."""
    return f"""
Bạn là một chuyên gia HR. Hãy phân tích job description dưới đây và tạo bản tóm tắt có cấu trúc.

### QUY TẮC NGHIÊM NGẶT
1. **NGÔN NGỮ TRẢ LỜI**: BẮT BUỘC phải trả lời bằng TIẾNG VIỆT
   - Dù job description được viết bằng tiếng Anh hay tiếng Việt
   - TẤT CẢ các phần tóm tắt, trách nhiệm, yêu cầu đều phải bằng TIẾNG VIỆT
2. Trích xuất thông tin quan trọng nhất từ job description
3. Ngắn gọn nhưng đầy đủ
4. Output phải là **JSON hợp lệ**, không có markdown fences, không có giải thích thêm
5. Sử dụng ngôn ngữ chuyên nghiệp
6. Nếu thông tin không có, sử dụng null

### CẤU TRÚC JSON
{{
  "jobTitle": "string - Tên vị trí công việc",
  "company": "string - Tên công ty nếu có đề cập, nếu không thì null",
  "location": "string - Địa điểm làm việc nếu có đề cập, nếu không thì null",
  "employmentType": "string - Toàn thời gian/Bán thời gian/Hợp đồng/etc., nếu không thì null",
  "summary": "string - Tóm tắt ngắn gọn 2-3 câu về vị trí này (bằng tiếng Việt)",
  "keyResponsibilities": [
    "string - Trách nhiệm chính 1 (bằng tiếng Việt)",
    "string - Trách nhiệm chính 2 (bằng tiếng Việt)",
    "string - Trách nhiệm chính 3 (bằng tiếng Việt)"
  ],
  "keyRequirements": [
    "string - Yêu cầu thiết yếu 1 (bằng tiếng Việt)",
    "string - Yêu cầu thiết yếu 2 (bằng tiếng Việt)",
    "string - Yêu cầu thiết yếu 3 (bằng tiếng Việt)"
  ],
  "experienceLevel": "string - Mức độ kinh nghiệm: Mới vào nghề/Junior/Middle/Senior, nếu không thì null",
  "salaryRange": "string - Thông tin lương nếu có đề cập, nếu không thì null",
  "benefits": [
    "string - Quyền lợi 1 (bằng tiếng Việt)",
    "string - Quyền lợi 2 (bằng tiếng Việt)"
  ]
}}

Bây giờ hãy tóm tắt job description này:
---
{job_description}
---

**LƯU Ý QUAN TRỌNG**: Trả lời bằng TIẾNG VIỆT cho tất cả các phần trong JSON.
Trả về CHỈ object JSON hợp lệ.
"""


async def summarize_jd(client, jd_text: str) -> Dict[str, Any]:
    """
    Summarize a job description and return structured JSON.
    
    Args:
        client: OpenRouter client instance
        jd_text: The job description text to summarize
        
    Returns:
        Dictionary containing structured summary of the job description
    """
    async def _summarize():
        prompt = jd_summary_prompt(jd_text)
        res = await client.generate(
            system_prompt="You are an expert HR assistant specializing in job description analysis. Provide clear, concise summaries in JSON format.",
            user_prompt=prompt,
            temperature=0.3,  # Lower temperature for more consistent, factual output
            max_tokens=1024,
        )
        result = safe_json_parse(res)
        return result

    return await with_retry(_summarize)


def cv_review_prompt(cv_text: str) -> str:
    """Generate prompt for reviewing CV and providing feedback."""
    return f"""
Bạn là một chuyên gia tư vấn CV chuyên nghiệp. Hãy phân tích CV dưới đây và đưa ra góp ý chi tiết theo các tiêu chí sau:

### QUY TẮC NGHIÊM NGẶT
1. **NGÔN NGỮ TRẢ LỜI**: BẮT BUỘC phải trả lời bằng TIẾNG VIỆT
   - Dù CV được viết bằng tiếng Anh hay tiếng Việt
   - TẤT CẢ các phản hồi, nhận xét, gợi ý đều phải bằng TIẾNG VIỆT
2. Đánh giá CV theo từng tiêu chí cụ thể
3. Đưa ra góp ý mang tính xây dựng, rõ ràng và hữu ích
4. Chỉ ra điểm mạnh và điểm cần cải thiện
5. Output phải là **JSON hợp lệ**, không có markdown fences, không có giải thích thêm
6. Nếu thiếu thông tin, hãy ghi rõ trong phần góp ý

### CÁC TIÊU CHÍ ĐÁNH GIÁ

**1. Thông tin cá nhân:**
- Có đầy đủ: tên đầy đủ, địa chỉ, email, số điện thoại?
- Đối với công ty trong nước: có ngày sinh, giới tính, tình trạng hôn nhân không?
- Thông tin có được trình bày rõ ràng, dễ đọc không?

**2. Mục tiêu công việc:**
- Có nêu rõ mong muốn nghề nghiệp không?
- Có chỉ ra tại sao ứng viên phù hợp với vị trí không?
- Có đề cập đến mong muốn chuyên nghiệp trong quy trình làm việc không?
- Có chỉ ra vị trí thăng tiến mong muốn (kèm thời gian cụ thể) không?
- Có nêu kỹ năng sẽ đóng góp cho công ty không?
- Có đề cập mục tiêu giúp công ty (tăng doanh số, thu hút khách hàng...) không?

**3. Giáo dục:**
- Có đầy đủ: trường học, chuyên ngành, thời gian tốt nghiệp, bằng cấp không?
- Có ghi điểm trung bình (nếu từ khá trở lên) không?
- Thông tin có được sắp xếp hợp lý không?

**4. Kinh nghiệm làm việc:**
- Có liệt kê kinh nghiệm liên quan đến vị trí ứng tuyển không?
- Có sắp xếp theo thứ tự thời gian (mới nhất trước) không?
- Mỗi công việc có bao gồm: khoảng thời gian, tên công ty (in hoa), vị trí không?
- Có mô tả trách nhiệm và thành tựu đạt được không?
- Có nhấn mạnh kỹ năng học được từ công việc không?

**5. Kỹ năng:**
- Có liệt kê kỹ năng liên quan đến công việc ứng tuyển không?
- Có cụ thể hóa kỹ năng (ví dụ: tốc độ đánh máy 70 từ/phút) không?
- Có phân loại rõ ràng: kỹ năng kỹ thuật, kỹ năng mềm, ngôn ngữ không?

**6. Hoạt động xã hội:**
- Có liệt kê hoạt động xã hội/câu lạc bộ tham gia không?
- Có ghi: thời gian, tên tổ chức, vị trí, mô tả công việc không?
- Có chỉ ra kỹ năng đạt được liên quan đến công việc ứng tuyển không?
- Có đề cập đóng góp cho cộng đồng/tổ chức không?

**7. Giấy chứng nhận và giải thưởng:**
- Có liệt kê chứng chỉ/giải thưởng liên quan không?
- Có ghi thời gian đạt được không?
- Có mô tả rõ tên chứng nhận/giải thưởng không?

### CẤU TRÚC JSON OUTPUT
{{
  "overall_score": "số điểm tổng thể từ 0-100",
  "overall_comment": "nhận xét chung về CV",
  "criteria_reviews": {{
    "personal_info": {{
      "score": "điểm từ 0-100",
      "strengths": ["điểm mạnh 1", "điểm mạnh 2"],
      "improvements": ["cần cải thiện 1", "cần cải thiện 2"],
      "suggestions": ["gợi ý cụ thể 1", "gợi ý cụ thể 2"]
    }},
    "career_objective": {{
      "score": "điểm từ 0-100",
      "strengths": [],
      "improvements": [],
      "suggestions": []
    }},
    "education": {{
      "score": "điểm từ 0-100",
      "strengths": [],
      "improvements": [],
      "suggestions": []
    }},
    "work_experience": {{
      "score": "điểm từ 0-100",
      "strengths": [],
      "improvements": [],
      "suggestions": []
    }},
    "skills": {{
      "score": "điểm từ 0-100",
      "strengths": [],
      "improvements": [],
      "suggestions": []
    }},
    "social_activities": {{
      "score": "điểm từ 0-100",
      "strengths": [],
      "improvements": [],
      "suggestions": []
    }},
    "certifications": {{
      "score": "điểm từ 0-100",
      "strengths": [],
      "improvements": [],
      "suggestions": []
    }}
  }},
  "priority_improvements": [
    "cải thiện ưu tiên 1",
    "cải thiện ưu tiên 2",
    "cải thiện ưu tiên 3"
  ],
  "final_recommendations": [
    "khuyến nghị cuối cùng 1",
    "khuyến nghị cuối cùng 2"
  ]
}}

Bây giờ hãy phân tích CV này:
---
{cv_text}
---

**LƯU Ý QUAN TRỌNG**: Trả lời bằng TIẾNG VIỆT cho tất cả các phần trong JSON.
Trả về CHỈ object JSON hợp lệ.
"""


async def review_cv(client, cv_text: str) -> Dict[str, Any]:
    """
    Review a CV and provide detailed feedback based on multiple criteria.
    
    Args:
        client: OpenRouter client instance
        cv_text: The CV text to review
        
    Returns:
        Dictionary containing detailed review and suggestions for the CV
    """
    async def _review():
        prompt = cv_review_prompt(cv_text)
        res = await client.generate(
            system_prompt="Bạn là một chuyên gia tư vấn CV hàng đầu với hơn 15 năm kinh nghiệm. Hãy đưa ra góp ý chi tiết, mang tính xây dựng và thực tế để giúp ứng viên cải thiện CV.",
            user_prompt=prompt,
            temperature=0.4,  # Slightly higher for more creative suggestions
            max_tokens=2048,  # More tokens for detailed feedback
        )
        result = safe_json_parse(res)
        return result

    return await with_retry(_review)



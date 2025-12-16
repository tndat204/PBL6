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
You are an expert HR assistant. Analyze the job description below and create a concise, structured summary.

### STRICT RULES
1. Extract the most important information from the job description
2. Be concise but comprehensive
3. Output must be **valid JSON only**, no markdown fences, no explanation
4. Use professional language
5. If information is not available, use null

### JSON STRUCTURE
{{
  "jobTitle": "string - The job position title",
  "company": "string - Company name if mentioned, otherwise null",
  "location": "string - Job location if mentioned, otherwise null",
  "employmentType": "string - Full-time/Part-time/Contract/etc., otherwise null",
  "summary": "string - A brief 2-3 sentence overview of the position",
  "keyResponsibilities": [
    "string - Main responsibility 1",
    "string - Main responsibility 2",
    "string - Main responsibility 3"
  ],
  "keyRequirements": [
    "string - Essential requirement 1",
    "string - Essential requirement 2",
    "string - Essential requirement 3"
  ],
  "experienceLevel": "string - Entry/Junior/Mid/Senior level, otherwise null",
  "salaryRange": "string - Salary information if mentioned, otherwise null",
  "benefits": [
    "string - Benefit 1",
    "string - Benefit 2"
  ]
}}

Now summarize this job description:
---
{job_description}
---

Return ONLY the valid JSON object.
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



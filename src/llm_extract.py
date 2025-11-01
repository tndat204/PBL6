import os
import json
import time
from dotenv import load_dotenv
from openai import OpenAI
from typing import Dict, Any

MODEL = "minimax/minimax-m2:free"

# ===============================
# 📘 Skill Dictionary (chuẩn hoá)
# ===============================
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


# ===============================
# 🔍 Helper to format dict text
# ===============================
def skill_dict_text(skill_dict: dict) -> str:
    return "\n".join(
        [f"- {key}: {', '.join(values)}" for key, values in skill_dict.items()]
    )


# ===============================
# 🧠 Prompt Templates
# ===============================
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
You are an expert HR assistant.
Extract structured information from the job description below into JSON.

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


# ===============================
# 🚀 Client Loader
# ===============================
def load_client() -> OpenAI:
    load_dotenv()
    api_key = os.getenv("OPENROUTER_API_KEY")
    if not api_key:
        raise RuntimeError("OPENROUTER_API_KEY not found in .env file.")
    return OpenAI(base_url="https://openrouter.ai/api/v1", api_key=api_key)


# ===============================
# 🧩 JSON-safe Parsing + Cleanup
# ===============================
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


# ===============================
# 🧩 Post-filter (enforce skills)
# ===============================
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


# ===============================
# 🔁 Retry Wrapper
# ===============================
def with_retry(func, max_retries=3, delay=2):
    """Retry a function if invalid JSON is returned."""
    for attempt in range(1, max_retries + 1):
        result = func()
        if isinstance(result, dict) and "error" not in result:
            return result
        print(f"[Retry {attempt}/{max_retries}] Invalid JSON, retrying...")
        time.sleep(delay)
    return {"error": "max_retries_exceeded"}


# ===============================
# 🔎 Extraction Wrappers
# ===============================
def analyze_cv(client: OpenAI, cv_text: str) -> Dict[str, Any]:
    def _extract():
        prompt = cv_extraction_prompt(cv_text, SKILL_DICTIONARY)
        resp = client.chat.completions.create(
            model=MODEL,
            messages=[{"role": "user", "content": prompt}],
            temperature=0.1,
            max_tokens=1500,
        )
        result = safe_json_parse(resp.choices[0].message.content)
        if "error" not in result:
            result = filter_valid_skills(result, SKILL_DICTIONARY)
        return result

    return with_retry(_extract)


def analyze_jd(client: OpenAI, jd_text: str) -> Dict[str, Any]:
    def _extract():
        prompt = jd_extraction_prompt(jd_text, SKILL_DICTIONARY)
        resp = client.chat.completions.create(
            model=MODEL,
            messages=[{"role": "user", "content": prompt}],
            temperature=0.1,
            max_tokens=1500,
        )
        result = safe_json_parse(resp.choices[0].message.content)
        if "error" not in result:
            result = filter_valid_skills(result, SKILL_DICTIONARY)
        return result

    return with_retry(_extract)

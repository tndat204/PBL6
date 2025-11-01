def compute_match_score(cv_data: dict, jd_data: dict, weights: dict = None) -> dict:
    """Rule-based matching giữa CV và JD, cho phép người dùng tùy chỉnh trọng số."""
    
    def skill_overlap(cv_list, jd_list):
        if not jd_list:
            return 1.0
        overlap = len(set(cv_list) & set(jd_list))
        return overlap / len(jd_list)
    
    # ===== 1️⃣ Technical Skills =====
    tech_score_sum = 0
    tech_categories = jd_data["TechnicalSkills"].keys()
    for cat in tech_categories:
        jd_skills = jd_data["TechnicalSkills"][cat]
        cv_skills = cv_data["TechnicalSkills"][cat]
        tech_score_sum += skill_overlap(cv_skills, jd_skills)
    tech_score = tech_score_sum / len(tech_categories)

    # ===== 2️⃣ Soft Skills =====
    soft_score = skill_overlap(cv_data["SoftSkills"], jd_data["SoftSkills"])

    # ===== 3️⃣ Experience =====
    cv_years = cv_data["Experience"]["Years"]
    jd_years = jd_data["Experience"]["Years"]
    if isinstance(cv_years, (int, float)) and isinstance(jd_years, (int, float)):
        exp_score = min(cv_years / jd_years, 1.0)
    else:
        exp_score = 0.5 if cv_years else 0

    # ===== 4️⃣ Education =====
    jd_gpa = jd_data["Education"].get("GPA")
    cv_gpa = cv_data["Education"].get("GPA")
    if not jd_gpa:
        edu_score = 1.0
    elif not cv_gpa:
        edu_score = 0.0
    else:
        edu_score = min(cv_gpa / jd_gpa, 1.0)

    # ===== 5️⃣ Other =====
    cert_overlap = skill_overlap(cv_data["Certifications"], jd_data["Certifications"])
    lang_overlap = skill_overlap(cv_data["Languages"], jd_data["Languages"])
    other_score = (cert_overlap + lang_overlap) / 2

    # ===== 🧾 Weighted sum =====
    default_weights = {
        "TechnicalSkills": 0.4,
        "SoftSkills": 0.2,
        "Experience": 0.25,
        "Education": 0.1,
        "Other": 0.05
    }

    # Nếu người dùng có truyền trọng số thì ghi đè
    if weights:
        for key in default_weights:
            if key in weights:
                default_weights[key] = weights[key]

    total = (
        tech_score * default_weights["TechnicalSkills"]
        + soft_score * default_weights["SoftSkills"]
        + exp_score * default_weights["Experience"]
        + edu_score * default_weights["Education"]
        + other_score * default_weights["Other"]
    ) * 100

    return {
        "TechnicalSkills": round(tech_score * 100, 2),
        "SoftSkills": round(soft_score * 100, 2),
        "Experience": round(exp_score * 100, 2),
        "Education": round(edu_score * 100, 2),
        "Other": round(other_score * 100, 2),
        "TotalScore": round(total, 2)
    }

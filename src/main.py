import streamlit as st
import requests
import json

API_URL = "http://127.0.0.1:8000/match/multiple"
st.set_page_config(page_title="CV–JD Matching", layout="wide")

st.title("CV–JD Matching Dashboard")
st.write("Upload 1 JD file (PDF) và nhiều CV files (PDF) để hệ thống tự động chấm điểm khớp.")

# ===== Upload files =====
st.header("Upload Files")
jd_file = st.file_uploader("Job Description (JD)", type=["pdf"], key="jd_upload")
cv_files = st.file_uploader(
    "Candidate CVs (nhiều file)",
    type=["pdf"],
    accept_multiple_files=True,
    key="cv_upload"
)

# ===== Weight configuration =====
st.header("Nhập trọng số tiêu chí (Weights)")
st.markdown("Nhập các trọng số sao cho tổng cộng bằng 1.0")

col1, col2, col3 = st.columns(3)
with col1:
    tech_weight = st.number_input("Technical Skills", min_value=0.0, max_value=1.0, value=0.4, step=0.01)
    soft_weight = st.number_input("Soft Skills", min_value=0.0, max_value=1.0, value=0.2, step=0.01)
with col2:
    exp_weight = st.number_input("Experience", min_value=0.0, max_value=1.0, value=0.25, step=0.01)
    edu_weight = st.number_input("Education", min_value=0.0, max_value=1.0, value=0.1, step=0.01)
with col3:
    other_weight = st.number_input("Other", min_value=0.0, max_value=1.0, value=0.05, step=0.01)

# ===== Validate weights =====
total_weight = tech_weight + soft_weight + exp_weight + edu_weight + other_weight
if abs(total_weight - 1.0) > 0.001:
    st.error(f"Tổng trọng số hiện tại là {total_weight:.2f}. Tổng phải bằng 1.0.")
    weights_valid = False
else:
    st.success("Tổng trọng số hợp lệ.")
    weights_valid = True

# ===== Run matching =====
if st.button("Match Now", use_container_width=True):
    if jd_file is None or not cv_files:
        st.error("Vui lòng upload đủ 1 JD và ít nhất 1 CV.")
    elif not weights_valid:
        st.error("Tổng trọng số không hợp lệ. Hãy chỉnh lại sao cho tổng bằng 1.0.")
    else:
        with st.spinner("Đang gửi dữ liệu đến server và tính toán..."):
            try:
                weights_json = json.dumps({
                    "TechnicalSkills": tech_weight,
                    "SoftSkills": soft_weight,
                    "Experience": exp_weight,
                    "Education": edu_weight,
                    "Other": other_weight
                })

                files = [("jd", (jd_file.name, jd_file, "application/pdf"))]
                files += [("cvs", (cv.name, cv, "application/pdf")) for cv in cv_files]

                response = requests.post(
                    API_URL,
                    files=files,
                    data={"weights": weights_json}
                )

                if response.status_code == 200:
                    result = response.json()
                    st.success("Matching completed successfully.")
                    st.write(f"JD File: {result['jd_filename']}")

                    st.subheader("Match Results")
                    for r in result["results"]:
                        st.markdown("---")
                        if "error" in r:
                            st.error(f"{r['cv_filename']}: {r['error']}")
                        else:
                            score = r["match_score"]
                            cv_data = r.get("cv_data", {})

                            with st.expander(f"{r['cv_filename']} - Total Score: {score['TotalScore']}%"):
                                cols = st.columns(5)
                                cols[0].metric("Technical", f"{score['TechnicalSkills']}%")
                                cols[1].metric("Soft Skills", f"{score['SoftSkills']}%")
                                cols[2].metric("Experience", f"{score['Experience']}%")
                                cols[3].metric("Education", f"{score['Education']}%")
                                cols[4].metric("Other", f"{score['Other']}%")

                                # Hiển thị CV structured data theo section
                                st.subheader("Technical Skills")
                                for k, v in cv_data.get("TechnicalSkills", {}).items():
                                    st.write(f"**{k}:** {', '.join(v) if v else 'N/A'}")

                                st.subheader("Soft Skills")
                                st.write(", ".join(cv_data.get("SoftSkills", [])) or "N/A")

                                st.subheader("Experience")
                                exp = cv_data.get("Experience", {})
                                st.write(f"Years: {exp.get('Years', 'N/A')}")
                                st.write(f"Roles: {', '.join(exp.get('Roles', [])) or 'N/A'}")
                                st.write(f"Projects: {', '.join(exp.get('Projects', [])) or 'N/A'}")
                                st.write(f"Achievements: {', '.join(exp.get('Achievements', [])) or 'N/A'}")

                                st.subheader("Education")
                                edu = cv_data.get("Education", {})
                                st.write(f"Degree: {edu.get('Degree', 'N/A')}")
                                st.write(f"Major: {edu.get('Major', 'N/A')}")
                                st.write(f"University: {edu.get('University', 'N/A')}")
                                st.write(f"GPA: {edu.get('GPA', 'N/A')}")

                                st.subheader("Certifications")
                                st.write(", ".join(cv_data.get("Certifications", [])) or "N/A")

                                st.subheader("Languages")
                                st.write(", ".join(cv_data.get("Languages", [])) or "N/A")

                                st.subheader("Other Info")
                                st.write(", ".join(cv_data.get("OtherInfo", [])) or "N/A")

                else:
                    st.error(f"Lỗi server ({response.status_code}): {response.text}")

            except Exception as e:
                st.error(f"Lỗi khi gọi API: {e}")

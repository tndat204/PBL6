// src/App.jsx
import React, { useState } from "react";
import axios from "axios";
import SearchBar from "../components/SearchBar";
import JobFilters from "../components/JobFilters";
import JobList from "../components/JobList";
import MainLayout from "../layouts/MainLayout";

function ResumeAnalyze() {
  const [jdFile, setJdFile] = useState(null);
  const [cvFiles, setCvFiles] = useState([]);
  const [selectedFiles, setSelectedFiles] = useState({ jd: null, cv: [] });
  const [step, setStep] = useState(1);

  const [weights, setWeights] = useState({
    TechnicalSkills: 0.4,
    SoftSkills: 0.2,
    Experience: 0.25,
    Education: 0.1,
    Other: 0.05,
  });
  const [results, setResults] = useState([]);
  const [loading, setLoading] = useState(false);
  const [errorMsg, setErrorMsg] = useState("");

  const totalWeight =
    Object.values(weights).reduce((acc, v) => acc + v, 0);

  const handleFileChange = (e, type) => {
    if (type === "jd") {
      setJdFile(e.target.files[0]);
      setSelectedFiles(prev => ({ ...prev, jd: e.target.files[0] }));
    } else if (type === "cv") {
      const cvs = Array.from(e.target.files);
      setCvFiles(cvs);
      setSelectedFiles(prev => ({ ...prev, cv: cvs }));
    }
  };

  const handleWeightChange = (e) => {
    const { name, value } = e.target;
    setWeights((prev) => ({ ...prev, [name]: parseFloat(value) }));
  };

  const handleSubmit = async () => {
    if (!jdFile || cvFiles.length === 0) {
      setErrorMsg("Vui lòng upload 1 JD và ít nhất 1 CV.");
      return;
    }
    if (Math.abs(totalWeight - 1.0) > 0.001) {
      setErrorMsg(`Tổng trọng số là ${totalWeight.toFixed(2)}, phải bằng 1.0`);
      return;
    }

    setErrorMsg("");
    setLoading(true);
    setResults([]);

    try {
      const formData = new FormData();
      formData.append("jd", jdFile);
      cvFiles.forEach((cv) => formData.append("cvs", cv));
      formData.append("weights", JSON.stringify(weights));

      const response = await axios.post(
        "http://127.0.0.1:8000/match/multiple",
        formData,
        { headers: { "Content-Type": "multipart/form-data" } }
      );
      console.log("FULL API RESPONSE:", response);
      
      const apiResults = response.data.results || [];
      // sort giảm dần theo TotalScore
      apiResults.sort((a, b) => b.match_score.TotalScore - a.match_score.TotalScore);
      setResults(apiResults);
    } catch (err) {
      console.error(err);
      setErrorMsg(err.response?.data?.detail || "Lỗi khi gọi API");
    } finally {
      setLoading(false);
    }
  };

  return (
<MainLayout showBanner={true}>
  {/* SearchBar floating */}
  <div className="relative -mt-24 z-20">
    <SearchBar />
  </div>


    <main className="col-span-12 md:col-span-9">
      <div className="container mx-auto p-6 bg-white mt-6">

        {/* TITLE */}
        <h1 className="text-3xl font-bold mb-6 text-sea-400">
          Rate Resumes
        </h1>

        <section className="mb-8 p-5 bg-gray-50 rounded-lg border border-gray-200">
          <h2 className="text-xl font-semibold mb-4 text-gray-700">Upload Files</h2>

          {/* Upload JD */}
          <div className="mb-4">
            <label className="block mb-1 font-semibold text-gray-700">Job Description (JD)</label>

            <div
              className="flex items-center gap-3 p-3 border border-gray-300 rounded-lg cursor-pointer hover:bg-gray-100 transition"
              onClick={() => document.getElementById("jd-upload").click()}
            >
              <svg xmlns="http://www.w3.org/2000/svg" fill="none"
                viewBox="0 0 24 24" strokeWidth={1.5}
                stroke="currentColor" className="w-6 h-6 text-gray-600">
                <path strokeLinecap="round" strokeLinejoin="round"
                  d="M12 16.5v-9m0 0L9.75 9.75M12 7.5l2.25 2.25M6.75 18.75h10.5A2.25 2.25 0 0019.5 16.5V7.5a2.25 2.25 0 00-2.25-2.25H6.75A2.25 2.25 0 004.5 7.5v9a2.25 2.25 0 002.25 2.25z" />
              </svg>

              <span className="text-gray-700">
                {selectedFiles?.jd ? selectedFiles.jd.name : "Choose JD PDF..."}
              </span>
            </div>

            <input
              id="jd-upload"
              type="file"
              accept=".pdf"
              className="hidden"
              onChange={(e) => handleFileChange(e, "jd")}
            />
          </div>

          {/* Upload CVs */}
          <div className="mb-4">
            <label className="block mb-1 font-semibold text-gray-700">Candidate CVs</label>

            <div
              className="flex items-center gap-3 p-3 border border-gray-300 rounded-lg cursor-pointer hover:bg-gray-100 transition"
              onClick={() => document.getElementById("cv-upload").click()}
            >
              <svg xmlns="http://www.w3.org/2000/svg" fill="none"
                viewBox="0 0 24 24" strokeWidth={1.5}
                stroke="currentColor" className="w-6 h-6 text-gray-600">
                <path strokeLinecap="round" strokeLinejoin="round"
                  d="M12 16.5v-9m0 0L9.75 9.75M12 7.5l2.25 2.25M6.75 18.75h10.5A2.25 2.25 0 0019.5 16.5V7.5a2.25 2.25 0 00-2.25-2.25H6.75A2.25 2.25 0 004.5 7.5v9a2.25 2.25 0 002.25 2.25z" />
              </svg>

              <span className="text-gray-700">
                {selectedFiles?.cv?.length
                  ? `${selectedFiles.cv.length} file(s) selected`
                  : "Choose CV PDF(s)..."}
              </span>
            </div>

            <input
              id="cv-upload"
              type="file"
              accept=".pdf"
              multiple
              className="hidden"
              onChange={(e) => handleFileChange(e, "cv")}
            />
          </div>
        </section>


        {/* Weights */}
        <section className="mb-8 p-5 bg-gray-50 rounded-lg border border-gray-200">
          <h2 className="text-xl font-semibold mb-4 text-gray-700">Weights (Total must = 1.0)</h2>

          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            {["TechnicalSkills", "SoftSkills", "Experience", "Education", "Other"].map((key) => (
              <div key={key} className="flex justify-between items-center bg-white px-4 py-2 rounded-lg shadow border border-gray-200">
                <label className="font-medium text-gray-700">{key}</label>
                <input
                  type="number"
                  step="0.01"
                  min="0"
                  max="1"
                  name={key}
                  className="w-24 border border-gray-300 rounded px-2 py-1 text-right"
                  value={weights[key]}
                  onChange={handleWeightChange}
                />
              </div>
            ))}
          </div>

          <p className={`mt-4 font-semibold ${totalWeight === 1.0 ? "text-green-600" : "text-red-600"}`}>
            Total: {totalWeight.toFixed(2)}
          </p>
        </section>

        {/* Error */}
        {errorMsg && (
          <div className="bg-red-100 text-red-700 border border-red-300 p-3 rounded mb-4">
            {errorMsg}
          </div>
        )}

        {/* Button */}
        <button
          className="w-full bg-sea-400 hover:bg-sea-300 text-white font-semibold px-6 py-3 rounded-lg shadow-md transition"
          onClick={handleSubmit}
          disabled={loading}
        >
          {loading ? "Matching..." : "Match Now"}
        </button>

        {/* Results */}
        <section className="mt-10">
          {results.map((r) => (
            <div key={r.cv_filename} className="bg-white border border-gray-200 shadow rounded-xl p-6 mb-6">

              {r.error ? (
                <div className="text-red-600 font-semibold">{r.cv_filename}: {r.error}</div>
              ) : (
                <>
                  <h3 className="text-lg font-bold text-gray-800 mb-2">
                    {r.cv_filename} – Total Score: <span className="text-blue-600">{r.match_score.TotalScore}%</span>
                  </h3>

                  {/* Score Grid */}
                  <div className="grid grid-cols-2 md:grid-cols-5 gap-4 mb-4">
                    <ScoreCard label="Technical" value={r.match_score.TechnicalSkills} />
                    <ScoreCard label="Soft Skills" value={r.match_score.SoftSkills} />
                    <ScoreCard label="Experience" value={r.match_score.Experience} />
                    <ScoreCard label="Education" value={r.match_score.Education} />
                    <ScoreCard label="Other" value={r.match_score.Other} />
                  </div>

                  {/* Details */}
                    <CollapsibleSection title="CV Details">
                        <CvDataView cv={r.cv_data} />
                    </CollapsibleSection>

                </>
              )}
            </div>
          ))}
        </section>
      </div>
    </main>

</MainLayout>

    
  );
}

const CollapsibleSection = ({ title, children }) => {
  const [open, setOpen] = useState(false);

  return (
    <div className="border border-gray-300 rounded-lg bg-gray-50 p-4 mb-4">
      {/* Header */}
      <div
        className="flex items-center justify-between cursor-pointer"
        onClick={() => setOpen(!open)}
      >
        <h3 className="font-semibold text-gray-800">{title}</h3>

        <span
          className={`transform transition-transform ${
            open ? "rotate-90" : ""
          }`}
        >
          ▶
        </span>
      </div>

      {/* Content */}
      {open && <div className="mt-4">{children}</div>}
    </div>
  );
};

const ScoreCard = ({ label, value }) => (
  <div className="p-3 bg-blue-50 border border-blue-200 rounded-lg text-center shadow">
    <p className="font-semibold text-gray-700">{label}</p>
    <p className="text-xl font-bold text-blue-700">{value}%</p>
  </div>
);
const TagList = ({ title, items }) => {
  if (!items || items.length === 0) return null;

  return (
    <div className="mb-3">
      <h4 className="font-semibold mb-1">{title}</h4>
      <div className="flex flex-wrap gap-2">
        {items.map((item, idx) => (
          <span
            key={idx}
            className="bg-blue-100 text-blue-800 px-3 py-1 rounded-full text-sm border border-blue-300"
          >
            {item}
          </span>
        ))}
      </div>
    </div>
  );
};
const SectionBox = ({ title, children }) => (
  <div className="border border-gray-200 rounded p-4 bg-gray-50 mb-4">
    <h3 className="font-semibold mb-2">{title}</h3>
    {children}
  </div>
);

const CvDataView = ({ cv }) => {
  if (!cv) return null;

  return (
    <div className="mt-6 bg-gray-50 p-5 rounded-xl border border-gray-200">
      {/* === TECHNICAL SKILLS === */}
      <SectionBox title="Technical Skills">
        <TagList title="Programming Languages" items={cv.TechnicalSkills?.ProgrammingLanguages} />
        <TagList title="Frameworks" items={cv.TechnicalSkills?.Frameworks} />
        <TagList title="Tools" items={cv.TechnicalSkills?.Tools} />
        <TagList title="Databases" items={cv.TechnicalSkills?.Databases} />
        <TagList title="Other Skills" items={cv.TechnicalSkills?.Others} />
      </SectionBox>

      {/* === SOFT SKILLS === */}
      <SectionBox title="Soft Skills">
        <TagList title="Soft Skills" items={cv.SoftSkills} />
      </SectionBox>

      {/* === EXPERIENCE === */}
      <SectionBox title="Experience">
        <div><b>Years:</b> {cv.Experience?.Years}</div>
        <TagList title="Roles" items={cv.Experience?.Roles} />
        <TagList title="Projects" items={cv.Experience?.Projects} />

        {cv.Experience?.Achievements?.length > 0 && (
          <div className="mt-2">
            <h4 className="font-semibold mb-1">Achievements</h4>
            <ul className="list-disc list-inside text-gray-700">
              {cv.Experience.Achievements.map((a, i) => (
                <li key={i}>{a}</li>
              ))}
            </ul>
          </div>
        )}
      </SectionBox>

      {/* === EDUCATION === */}
      <SectionBox title="Education">
        <div><b>Degree:</b> {cv.Education?.Degree}</div>
        <div><b>Major:</b> {cv.Education?.Major}</div>
        <div><b>University:</b> {cv.Education?.University}</div>
        <div><b>GPA:</b> {cv.Education?.GPA}</div>
      </SectionBox>

      {/* === CERTIFICATIONS === */}
      <SectionBox title="Certifications">
        <TagList title="Certifications" items={cv.Certifications} />
      </SectionBox>

      {/* === LANGUAGES === */}
      <SectionBox title="Languages">
        <TagList title="Languages" items={cv.Languages} />
      </SectionBox>
    </div>
  );
};


export default ResumeAnalyze;

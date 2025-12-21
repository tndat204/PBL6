


import { useEffect, useState } from "react";
import { useNavigate, useParams } from "react-router-dom";
import MainLayout from "../layouts/MainLayout";

import locationIcon from "../assets/images/location-icon.png";
import jobIcon from "../assets/images/job-type-icon.png";
import experienceIcon from "../assets/images/experience-icon.png";
import salaryIcon from "../assets/images/salary-icon.png";

import { jobService, companyService, skillService, applicationService } from "../services";
import JobCard from "../components/JobCard";
import ApplyJobModal from "../components/ApplyJobModal";
import { formatSalaryRange } from "../utils/formatUtils";
import { FileText, Eye, Download } from "lucide-react";
import { useAuth } from "../hooks/useAuth";

const JOB_TYPE_LABELS = {
  FULL_TIME: "Toàn thời gian",
  PART_TIME: "Bán thời gian",
  FREELANCE: "Freelance",
};

function JobDetails() {
  const navigate = useNavigate();
  const { id } = useParams();

  const [job, setJob] = useState(null);
  const [company, setCompany] = useState(null);
  const { user } = useAuth();
  const [skillNames, setSkillNames] = useState([]);
  const [relatedJobs, setRelatedJobs] = useState([]);

  const [loading, setLoading] = useState(true);
  const [loadingRelated, setLoadingRelated] = useState(false);
  const [error, setError] = useState("");

  // ✅ NEW: state mở/đóng modal
  const [isApplyOpen, setIsApplyOpen] = useState(false);

  // ===== LẤY JOB THEO ID =====
  useEffect(() => {
    if (!id) return;

    const fetchJob = async () => {
      try {
        setLoading(true);
        setError("");

        const jobData = await jobService.getJobById(id);
        setJob(jobData);

        // Lấy công ty
        if (jobData.companyId) {
          try {
            const companyRes = await companyService.getCompanyById(jobData.companyId);
            const companyData = companyRes.result || companyRes;
            setCompany(companyData);
          } catch {
            setCompany(null);
          }
        }

        // Lấy skill theo skillIds
        if (jobData.skillIds && jobData.skillIds.length > 0) {
          try {
            const skillsRes = await skillService.getSkillsByIds(jobData.skillIds);
            const skillsData = skillsRes.result || skillsRes || [];
            setSkillNames(skillsData); // theo JobCard, đây là mảng tên
          } catch {
            setSkillNames([]);
          }
        } else {
          setSkillNames([]);
        }
      } catch (err) {
        console.error("Lỗi khi lấy job:", err);
        setError("Không thể tải thông tin công việc.");
      } finally {
        setLoading(false);
      }
    };

    fetchJob();
  }, [id]);

  // ===== RELATED JOBS THEO CATEGORY – LỌC TỪ getAllJobs() =====
  useEffect(() => {
    if (!job) return;
    if (!job.categoryIds || job.categoryIds.length === 0) {
      setRelatedJobs([]);
      return;
    }

    const fetchRelatedJobs = async () => {
      try {
        setLoadingRelated(true);

        const allJobs = await jobService.getAllJobs();
        const currentCategories = job.categoryIds;

        const filtered = allJobs
          .filter((j) => j.id !== job.id)
          .filter(
            (j) =>
              j.categoryIds &&
              j.categoryIds.some((cid) => currentCategories.includes(cid))
          )
          .slice(0, 4);

        setRelatedJobs(filtered);
      } catch (err) {
        console.error("Lỗi khi lấy việc làm liên quan:", err);
        setRelatedJobs([]);
      } finally {
        setLoadingRelated(false);
      }
    };

    fetchRelatedJobs();
  }, [job]);

  // ===== HELPER FORMAT =====

  const formatExperience = (expMin, expMax) => {
    // Only use years range
    if ((expMin === 0 || !expMin) && (expMax === 0 || !expMax)) {
      return "Không yêu cầu";
    }
    if (expMin > 0 && (!expMax || expMax === 0)) return `${expMin}+ năm`;
    if ((!expMin || expMin === 0) && expMax > 0) return `Dưới ${expMax} năm`;
    return `${expMin} - ${expMax} năm`;
  };

  const formatExperienceLevel = (expLevel) => {
    const levelLabels = {
      INTERN: "Intern",
      FRESHER: "Fresher",
      JUNIOR: "Junior",
      SENIOR: "Senior",
      PRINCIPAL: "Principal",
      MANAGER: "Manager",
      ANY: "Bất kì"
    };
    return levelLabels[expLevel] || "Đang cập nhật";
  };

  const formatDate = (value) => {
    if (!value) return "Không có";
    const d = new Date(value);
    if (Number.isNaN(d.getTime())) return value;
    return d.toLocaleDateString("vi-VN");
  };

  // ===== UI LOADING / ERROR =====
  if (loading) {
    return (
      <MainLayout showBanner={true}>
        <div className="max-w-7xl mx-auto py-10 text-center text-gray-600">
          Đang tải thông tin công việc...
        </div>
      </MainLayout>
    );
  }

  if (error || !job) {
    return (
      <MainLayout showBanner={true}>
        <div className="max-w-7xl mx-auto py-10 text-center text-red-500">
          {error || "Không tìm thấy công việc."}
        </div>
      </MainLayout>
    );
  }

  // ===== DERIVED DATA =====
  const jobTypeLabel = job.jobType || "Đang cập nhật";
  const salaryLabel = formatSalaryRange(job.salaryMin, job.salaryMax);
  const experienceLabel = formatExperience(
    job.requiredYearsOfExpMin,
    job.requiredYearsOfExpMax
  );
  const experienceLevelLabel = formatExperienceLevel(job.experienceLevel);
  const expiryDateLabel = formatDate(job.expiryDate);

  // Check if job is expired (compare dates only, not time)
  const isExpired = job.expiryDate ? (() => {
    const today = new Date();
    today.setHours(0, 0, 0, 0); // Set to midnight

    const expiry = new Date(job.expiryDate);
    expiry.setHours(0, 0, 0, 0); // Set to midnight

    return expiry < today; // Only expired if expiry date is before today
  })() : false;

  const companyName = company?.name || "Đang cập nhật";
  const companyLocation = company?.location || job.location || "Đang cập nhật";
  const companyLogo = company?.logoUrl || "/images/cmc.png";
  const companyDescription =
    company?.description || "Thông tin công ty đang được cập nhật.";

  // ===== RENDER =====
  return (
    <MainLayout showBanner={true}>
      <div className="max-w-7xl mx-auto py-10 grid grid-cols-1 md:grid-cols-4 gap-6">
        {/* Cột trái: thông tin job + công ty */}
        <div className="md:col-span-1 space-y-6">
          {/* Thông tin công việc */}
          <div className="bg-white rounded-lg shadow p-5">
            <h2 className="text-xl font-semibold mb-4">Thông tin công việc</h2>
            <ul className="space-y-3">
              {/* Địa điểm */}
              <li className="flex items-center">
                <img src={locationIcon} className="w-5 h-5 mr-3" />
                <div>
                  <span className="block text-gray-500 font-semibold">Địa điểm</span>
                  <span className="text-sea-400">
                    {job.location || "Đang cập nhật"}
                  </span>
                </div>
              </li>

              {/* Hình thức làm việc */}
              <li className="flex items-center">
                <img src={jobIcon} className="w-5 h-5 mr-3" />
                <div>
                  <span className="block text-gray-500 font-semibold">
                    Hình thức làm việc
                  </span>
                  <span className="text-sea-400">{jobTypeLabel}</span>
                </div>
              </li>

              {/* Trình độ */}
              <li className="flex items-center">
                <div className="w-5 h-5 mr-3 text-gray-500">
                  <svg fill="currentColor" viewBox="0 0 20 20">
                    <path d="M10.394 2.08a1 1 0 00-.788 0l-7 3a1 1 0 000 1.84L5.25 8.051a.999.999 0 01.356-.257l4-1.714a1 1 0 11.788 1.838L7.667 9.088l1.94.831a1 1 0 00.787 0l7-3a1 1 0 000-1.838l-7-3zM3.31 9.397L5 10.12v4.102a8.969 8.969 0 00-1.05-.174 1 1 0 01-.89-.89 11.115 11.115 0 01.25-3.762zM9.3 16.573A9.026 9.026 0 007 14.935v-3.957l1.818.78a3 3 0 002.364 0l5.508-2.361a11.026 11.026 0 01.25 3.762 1 1 0 01-.89.89 8.968 8.968 0 00-5.35 2.524 1 1 0 01-1.4 0zM6 18a1 1 0 001-1v-2.065a8.935 8.935 0 00-2-.712V17a1 1 0 001 1z" />
                  </svg>
                </div>
                <div>
                  <span className="block text-gray-500 font-semibold">Trình độ</span>
                  <span className="text-sea-400">
                    {experienceLevelLabel}
                  </span>
                </div>
              </li>

              {/* Kinh nghiệm */}
              <li className="flex items-center">
                <img src={experienceIcon} className="w-5 h-5 mr-3" />
                <div>
                  <span className="block text-gray-500 font-semibold">Kinh nghiệm</span>
                  <span className="text-sea-400">
                    {experienceLabel}
                  </span>
                </div>
              </li>

              {/* Lương */}
              <li className="flex items-center">
                <img src={salaryIcon} className="w-5 h-5 mr-3" />
                <div>
                  <span className="block text-gray-500 font-semibold">Mức lương</span>
                  <span className="text-sea-400">{salaryLabel}</span>
                </div>
              </li>

              {/* Hạn ứng tuyển */}
              <li className="flex items-center">
                <div className="w-5 h-5 mr-3 text-gray-500">🕒</div>
                <div>
                  <span className="block text-gray-500 font-semibold">
                    Hạn ứng tuyển
                  </span>
                  <div className="flex items-center gap-2">
                    <span className="text-sea-400">{expiryDateLabel}</span>
                    {isExpired && (
                      <span className="text-xs bg-red-100 text-red-600 px-2 py-0.5 rounded-full font-medium">
                        Hết hạn
                      </span>
                    )}
                  </div>
                </div>
              </li>
            </ul>
          </div>

          {/* Giới thiệu công ty */}
          <div className="bg-white rounded-lg shadow p-5">
            <h2 className="text-xl font-semibold mb-4">Giới thiệu công ty</h2>
            <div className="flex items-center mb-3">
              <img
                src={companyLogo}
                alt="Logo công ty"
                className="w-12 h-12 border rounded-full object-cover mr-3"
              />
              <div>
                <p className="font-semibold">{companyName}</p>
                <p className="text-sm text-sea-400">{companyLocation}</p>
              </div>
            </div>
            <p className="text-sm text-sea-400 mb-3">{companyDescription}</p>
            {company?.id && (
              <button
                onClick={() => navigate(`/company-profile/${company.id}`)}
                className="text-blue-600 text-sm hover:underline"
              >
                Xem chi tiết công ty
              </button>
            )}
          </div>
        </div>

        {/* Cột phải: mô tả công việc */}
        <div className="md:col-span-3 bg-white rounded-lg shadow p-8 pt-4">
          <h1 className="text-xl font-semibold mb-4">{job.title}</h1>

          {/* Mô tả công việc heading */}
          <h2 className="text-lg font-semibold mb-3 mt-6">Mô tả công việc</h2>

          <p className="text-sm text-gray-600 mb-6 whitespace-pre-line">
            {job.description}
          </p>

          {/* File JD Section */}
          {job.jdUrl && (
            <div className="mb-8">
              <h2 className="text-lg font-semibold mb-4 flex items-center gap-2">
                {/* <FileText className="text-gray-700" size={20} /> */}
                Tài liệu mô tả công việc
              </h2>
              <div className="group flex flex-col sm:flex-row items-center justify-between p-4 bg-gray-50 rounded-lg border border-gray-200 hover:border-gray-300 transition-all gap-4">
                <div className="flex items-center gap-4 w-full sm:w-auto">
                  <div className="w-12 h-12 bg-white rounded-lg flex items-center justify-center shadow-sm text-gray-600 shrink-0">
                    <FileText size={28} />
                  </div>
                  <div className="overflow-hidden">
                    <p className="font-medium text-gray-900 truncate" title={job.jdUrl.split('/').pop()}>
                      {job.jdUrl.split('/').pop() || 'job-description.pdf'}
                    </p>
                    <p className="text-xs text-gray-500 mt-0.5">PDF Document</p>
                  </div>
                </div>
                <div className="flex items-center gap-2 w-full sm:w-auto justify-end">
                  <button
                    onClick={() => window.open(job.jdUrl, '_blank')}
                    className="flex items-center justify-center gap-2 px-4 py-2 bg-white text-gray-700 rounded-lg text-sm font-medium border border-gray-200 hover:bg-gray-50 hover:text-blue-600 hover:border-blue-200 transition-all shadow-sm w-full sm:w-auto"
                  >
                    <Eye size={16} />
                    Xem trước
                  </button>
                  <a
                    href={job.jdUrl}
                    target="_blank"
                    rel="noopener noreferrer"
                    className="flex items-center justify-center gap-2 px-4 py-2 bg-white text-gray-700 rounded-lg text-sm font-medium border border-gray-200 hover:bg-gray-50 hover:text-blue-600 hover:border-blue-200 transition-all shadow-sm w-full sm:w-auto"
                  >
                    <Download size={16} />
                    Tải xuống
                  </a>
                </div>
              </div>
            </div>
          )}

          {/* Kỹ năng yêu cầu */}
          {skillNames.length > 0 && (
            <>
              <h2 className="text-lg font-semibold mb-3">Kỹ năng yêu cầu</h2>
              <div className="flex flex-wrap gap-2 mb-6">
                {skillNames.map((name, idx) => (
                  <span
                    key={idx}
                    className="bg-gray-100 px-3 py-1 rounded-full border text-xs"
                  >
                    {name}
                  </span>
                ))}
              </div>
            </>
          )}

          {/* ✅ UPDATED: Only USER role can apply */}
          <button
            onClick={() => setIsApplyOpen(true)}
            disabled={isExpired || !(user && user.roles && user.roles.some(role => role.name === 'USER'))}
            className={`mt-8 px-6 py-2 rounded-sm transition ${
              isExpired || !(user && user.roles && user.roles.some(role => role.name === 'USER'))
                ? 'bg-gray-300 text-gray-500 cursor-not-allowed'
                : 'bg-sea-400 text-white hover:bg-sea-300'
            }`}
          >
            {isExpired ? 'Hết hạn nộp hồ sơ' : 'Ứng tuyển'}
          </button>
        </div>
      </div>

      {/* Việc làm liên quan */}
      <section className="mt-12 max-w-7xl mx-auto">
        <h2 className="text-center text-2xl font-semibold text-gray-800 mb-8">
          Việc làm liên quan
        </h2>

        {loadingRelated ? (
          <p className="text-center text-sm text-gray-500">
            Đang tải việc làm liên quan...
          </p>
        ) : relatedJobs.length === 0 ? (
          <p className="text-center text-sm text-gray-500">
            Chưa có việc làm liên quan trong cùng ngành.
          </p>
        ) : (
          <div
            className="
              grid
              grid-cols-1
              sm:grid-cols-2
              lg:grid-cols-3
              gap-6
            "
          >
            {relatedJobs.map((rj) => (
              <div key={rj.id} className="max-w-[350px]">
                <JobCard job={rj} />
              </div>
            ))}
          </div>
        )}
      </section>

      {/* ✅ NEW: Modal ứng tuyển */}

      {/* <ApplyJobModal
        open={isApplyOpen}
        onClose={() => setIsApplyOpen(false)}
        jobTitle={job.title}
        
        // QUAN TRỌNG: Kiểm tra xem job.id hay job._id mới đúng với API của bạn
        jobId={job.id || job._id} 
        
        onSubmit={(payload) => {
          console.log("👉 Payload gửi đi:", payload); 
          // Nếu log này vẫn hiện jobId: undefined, hãy kiểm tra lại object 'job' ở trên
          
          // TODO: Gọi API ứng tuyển ở đây
          // applicationService.applyJob(payload)...
        }}
      /> */}
      <ApplyJobModal
        open={isApplyOpen}
        onClose={() => setIsApplyOpen(false)}
        jobTitle={job.title}
        jobId={job.id || job._id}
        onSubmit={async (payload) => {
          try {
            console.log("👉 Payload gửi đi:", payload);
            // Tạo FormData
            const formData = new FormData();
            formData.append("jobId", payload.jobId);
            formData.append("notes", payload.notes);

            if (payload.cv) {
              formData.append("cv", payload.cv);
            }

            // Gọi API (lúc này api.js đã biết cách xử lý formData)
            await applicationService.applyJob(formData);

            alert("Ứng tuyển thành công!");
            setIsApplyOpen(false);

          } catch (error) {
            console.error("Lỗi khi ứng tuyển:", error);
            alert(error.message || "Có lỗi xảy ra, vui lòng thử lại.");
          }
        }}
      />
    </MainLayout>
  );
}

export default JobDetails;

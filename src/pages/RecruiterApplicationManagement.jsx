import React, { useState, useEffect } from "react";
import { useAuth } from "../hooks/useAuth";
import { applicationService, jobService } from "../services";
import { FileText, Eye, Download, Briefcase } from "lucide-react";

function RecruiterApplicationManagement() {
  const { company } = useAuth();
  const [applications, setApplications] = useState([]);
  const [jobs, setJobs] = useState([]);
  const [selectedJobId, setSelectedJobId] = useState("ALL");
  const [loading, setLoading] = useState(true);
  const [filterStatus, setFilterStatus] = useState("ALL");
  const [searchTerm, setSearchTerm] = useState("");
  const [showHRAssistantModal, setShowHRAssistantModal] = useState(false);
  const [hrAssistantResults, setHrAssistantResults] = useState(null);
  const [expandedCVIndex, setExpandedCVIndex] = useState(null);
  const [weights, setWeights] = useState({
    TechnicalSkills: 0.1,
    SoftSkills: 0.3,
    Experience: 0.25,
    Education: 0.3,
    Other: 0.05
  });

  useEffect(() => {
    if (company?.id) {
      fetchJobs();
    }
  }, [company]);

  useEffect(() => {
    if (selectedJobId && selectedJobId !== "ALL") {
      fetchApplicationsByJob(selectedJobId);
    } else if (selectedJobId === "ALL") {
      setApplications([]);
    }
  }, [selectedJobId]);

  const fetchJobs = async () => {
    try {
      setLoading(true);
      const data = await jobService.getJobsByCompany(company.id);
      setJobs(Array.isArray(data) ? data : []);
    } catch (error) {
      console.error("Error fetching jobs:", error);
      setJobs([]);
    } finally {
      setLoading(false);
    }
  };

  const fetchApplicationsByJob = async (jobId) => {
    try {
      setLoading(true);
      const data = await applicationService.getApplicationsByJob(jobId);
      console.log("Applications data:", data);

      // Transform data to match expected format
      const transformedData = Array.isArray(data) ? data.map(app => ({
        id: app.applicationId,
        candidateName: app.applicantInfo?.fullName || "N/A",
        candidateEmail: app.applicantInfo?.email || "N/A",
        candidatePhone: app.applicantInfo?.phone,
        candidateAddress: app.applicantInfo?.address,
        candidateAvatar: app.applicantInfo?.avatarUrl,
        status: app.status,
        notes: app.notes,
        cvUrl: app.cvFileUrl,
        appliedDate: app.appliedDate,
        jobId: app.jobId,
        applicantId: app.applicantId
      })) : [];

      setApplications(transformedData);
    } catch (error) {
      console.error("Error fetching applications:", error);
      setApplications([]);
    } finally {
      setLoading(false);
    }
  };

  const handleStatusChange = async (applicationId, newStatus) => {
    try {
      await applicationService.updateApplicationStatus(applicationId, newStatus);
      alert("Cập nhật trạng thái thành công!");
      if (selectedJobId && selectedJobId !== "ALL") {
        fetchApplicationsByJob(selectedJobId);
      }
    } catch (error) {
      console.error("Error updating status:", error);
      alert("Không thể cập nhật trạng thái!");
    }
  };

  const filteredApplications = applications.filter((app) => {
    const matchesStatus = filterStatus === "ALL" || app.status === filterStatus;
    const matchesSearch =
      app.candidateName?.toLowerCase().includes(searchTerm.toLowerCase()) ||
      app.candidateEmail?.toLowerCase().includes(searchTerm.toLowerCase());
    return matchesStatus && matchesSearch;
  });

  const getStatusBadge = (status) => {
    const badges = {
      SUBMITTED: "bg-blue-100 text-blue-800",
      REVIEWED: "bg-purple-100 text-purple-800",
      INTERVIEW: "bg-orange-100 text-orange-800",
      HIRED: "bg-green-100 text-green-800",
      REJECTED: "bg-red-100 text-red-800",
    };
    return badges[status] || "bg-gray-100 text-gray-800";
  };

  const getStatusLabel = (status) => {
    const labels = {
      SUBMITTED: "Mới nộp",
      REVIEWED: "Đã xem xét",
      INTERVIEW: "Đã hẹn phỏng vấn",
      HIRED: "Đã tuyển",
      REJECTED: "Từ chối",
    };
    return labels[status] || status;
  };

  if (loading) {
    return (
      <div className="flex items-center justify-center min-h-screen">
        <div className="animate-spin rounded-full h-12 w-12 border-4 border-emerald-500 border-t-transparent"></div>
      </div>
    );
  }

  return (
    <div>
      {/* Header */}
      <div className="mb-6">
        <h1 className="text-2xl font-bold text-gray-900">Quản lý Hồ Sơ Ứng Tuyển</h1>
        <p className="text-gray-600 mt-1">Xem và quản lý tất cả CV đã nhận</p>
      </div>

      {/* Filters - All in one row */}
      <div className="bg-white rounded-lg shadow-sm p-4 mb-6">
        <div className="flex flex-wrap gap-3 items-end">
          {/* Search Input */}
          {selectedJobId !== "ALL" && (
            <div className="flex-1 min-w-[200px]">
              <label className="block text-sm font-medium text-gray-700 mb-2">
                Tìm kiếm
              </label>
              <input
                type="text"
                placeholder="Tìm theo tên hoặc email ứng viên..."
                value={searchTerm}
                onChange={(e) => setSearchTerm(e.target.value)}
                className="w-full border border-gray-300 rounded-lg px-4 py-2 focus:ring-2 focus:ring-emerald-500 outline-none"
              />
            </div>
          )}

          {/* Job Selection */}
          <div className="flex-1 min-w-[250px]">
            <label className="block text-sm font-medium text-gray-700 mb-2">
              <Briefcase className="inline-block mr-1" size={14} />
              Chọn tin đăng
            </label>
            <select
              value={selectedJobId}
              onChange={(e) => setSelectedJobId(e.target.value)}
              className="w-full border border-gray-300 rounded-lg px-4 py-2 focus:ring-2 focus:ring-emerald-500 outline-none"
            >
              <option value="ALL">-- Chọn tin đăng để xem hồ sơ --</option>
              {jobs.map((job) => (
                <option key={job.id} value={job.id}>
                  {job.title} ({job.location})
                </option>
              ))}
            </select>
          </div>

          {/* Status Filter Selectbox */}
          {selectedJobId !== "ALL" && (
            <div className="min-w-[180px]">
              <label className="block text-sm font-medium text-gray-700 mb-2">
                Lọc trạng thái
              </label>
              <select
                value={filterStatus}
                onChange={(e) => setFilterStatus(e.target.value)}
                className="w-full border border-gray-300 rounded-lg px-4 py-2 focus:ring-2 focus:ring-emerald-500 outline-none"
              >
                <option value="ALL">Tất cả</option>
                <option value="SUBMITTED">{getStatusLabel("SUBMITTED")}</option>
                <option value="REVIEWED">{getStatusLabel("REVIEWED")}</option>
                <option value="INTERVIEW">{getStatusLabel("INTERVIEW")}</option>
                <option value="HIRED">{getStatusLabel("HIRED")}</option>
                <option value="REJECTED">{getStatusLabel("REJECTED")}</option>
              </select>
            </div>
          )}

          {/* HR Assistant Button */}
          {selectedJobId !== "ALL" && filteredApplications.length > 0 && (
            <button
              onClick={() => setShowHRAssistantModal(true)}
              className="px-4 py-2 border border-blue-500 text-blue-600 bg-blue-50 rounded-lg hover:bg-blue-100 transition font-medium whitespace-nowrap"
            >
              HR Assistant
            </button>
          )}
        </div>
      </div>

      {/* HR Assistant Modal */}
      {showHRAssistantModal && (
        <HRAssistantModal
          applications={filteredApplications}
          selectedJobId={selectedJobId}
          weights={weights}
          setWeights={setWeights}
          onClose={() => setShowHRAssistantModal(false)}
          onResultsReceived={(results) => {
            setHrAssistantResults(results);
            setShowHRAssistantModal(false);
          }}
        />
      )}

      {/* Applications Table */}
      {!hrAssistantResults && (
        selectedJobId === "ALL" ? (
          <div className="bg-white rounded-lg shadow-sm p-12 text-center">
            <Briefcase className="mx-auto text-gray-300 mb-4" size={64} />
            <p className="text-gray-500 text-lg">Vui lòng chọn tin đăng để xem danh sách hồ sơ ứng tuyển</p>
          </div>
        ) : (
          <div className="bg-white rounded-lg shadow-sm overflow-hidden">
            <table className="w-full">
              <thead className="bg-gray-50 border-b">
                <tr>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Ứng viên
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Liên hệ
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Trạng thái
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Ngày ứng tuyển
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Hành động
                  </th>
                </tr>
              </thead>
              <tbody className="bg-white divide-y divide-gray-200">
                {filteredApplications.length === 0 ? (
                  <tr>
                    <td colSpan="5" className="px-6 py-8 text-center text-gray-500">
                      Không có hồ sơ nào
                    </td>
                  </tr>
                ) : (
                  filteredApplications.map((app) => (
                    <tr key={app.id} className="hover:bg-gray-50">
                      <td className="px-6 py-4">
                        <div className="flex items-center gap-3">
                          <div className="w-10 h-10 rounded-full bg-emerald-100 flex items-center justify-center overflow-hidden">
                            {app.candidateAvatar ? (
                              <img src={app.candidateAvatar} alt={app.candidateName} className="w-full h-full object-cover" />
                            ) : (
                              <FileText className="text-emerald-600" size={20} />
                            )}
                          </div>
                          <div>
                            <p className="text-sm font-medium text-gray-900">{app.candidateName}</p>
                            <p className="text-xs text-gray-500">{app.candidateAddress || "N/A"}</p>
                          </div>
                        </div>
                      </td>
                      <td className="px-6 py-4">
                        <div className="text-sm">
                          <p className="text-gray-900">{app.candidateEmail}</p>
                          <p className="text-gray-500">{app.candidatePhone || "N/A"}</p>
                        </div>
                      </td>
                      <td className="px-6 py-4">
                        <select
                          value={app.status}
                          onChange={(e) => handleStatusChange(app.id, e.target.value)}
                          className={`inline-flex px-2 py-1 text-xs font-semibold rounded-full ${getStatusBadge(app.status)} border-0 cursor-pointer`}
                        >
                          <option value="SUBMITTED">{getStatusLabel("SUBMITTED")}</option>
                          <option value="REVIEWED">{getStatusLabel("REVIEWED")}</option>
                          <option value="INTERVIEW">{getStatusLabel("INTERVIEW")}</option>
                          <option value="HIRED">{getStatusLabel("HIRED")}</option>
                          <option value="REJECTED">{getStatusLabel("REJECTED")}</option>
                        </select>
                      </td>
                      <td className="px-6 py-4 text-sm text-gray-500">
                        {app.appliedDate ? new Date(app.appliedDate).toLocaleDateString("vi-VN") : "N/A"}
                      </td>
                      <td className="px-6 py-4">
                        <div className="flex items-center gap-2">
                          {app.cvUrl && (
                            <a
                              href={app.cvUrl}
                              target="_blank"
                              rel="noopener noreferrer"
                              className="p-2 text-blue-600 hover:bg-blue-50 rounded-lg transition"
                              title="Xem CV"
                            >
                              <Eye size={18} />
                            </a>
                          )}
                          {app.cvUrl && (
                            <a
                              href={app.cvUrl}
                              download
                              className="p-2 text-emerald-600 hover:bg-emerald-50 rounded-lg transition"
                              title="Tải CV"
                            >
                              <Download size={18} />
                            </a>
                          )}
                        </div>
                      </td>
                    </tr>
                  ))
                )}
              </tbody>
            </table>
          </div>
        )
      )}

      {/* HR Assistant Results Table */}
      {hrAssistantResults && hrAssistantResults.results && (
        <div className="mt-6 bg-white rounded-lg shadow-sm overflow-hidden border border-gray-200">
          <div className="px-6 py-4 border-b border-gray-200 flex justify-between items-center">
            <div>
              <h3 className="text-lg font-semibold text-gray-900">Kết quả phân tích CV</h3>
              <p className="text-gray-600 text-sm mt-1">{hrAssistantResults.results.length} CV đã được phân tích</p>
            </div>
            <div className="flex gap-2">
              {hrAssistantResults.excel_download_url && (
                <a
                  href={hrAssistantResults.excel_download_url}
                  download
                  className="px-4 py-2 border border-gray-300 text-gray-700 rounded-lg hover:bg-gray-50 transition text-sm font-medium"
                >
                  Tải Excel
                </a>
              )}
              <button
                onClick={() => setHrAssistantResults(null)}
                className="px-4 py-2 border border-gray-300 text-gray-700 rounded-lg hover:bg-gray-50 transition text-sm font-medium"
              >
                Đóng
              </button>
            </div>
          </div>

          <div className="overflow-x-auto">
            <table className="w-full">
              <thead className="bg-gray-50 border-b border-gray-200">
                <tr>
                  <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">#</th>
                  <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Tên CV</th>
                  <th className="px-4 py-3 text-center text-xs font-medium text-gray-500 uppercase">Tổng điểm</th>
                  <th className="px-4 py-3 text-center text-xs font-medium text-gray-500 uppercase">Kỹ năng</th>
                  <th className="px-4 py-3 text-center text-xs font-medium text-gray-500 uppercase">Kinh nghiệm</th>
                  <th className="px-4 py-3 text-center text-xs font-medium text-gray-500 uppercase">Học vấn</th>
                  <th className="px-4 py-3 text-center text-xs font-medium text-gray-500 uppercase">Chi tiết</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-gray-200">
                {hrAssistantResults.results
                  .sort((a, b) => b.match_score.TotalScore - a.match_score.TotalScore)
                  .map((cv, idx) => {
                    // Find candidate name by matching cv_url with applications
                    const application = applications.find(app => app.cvUrl === cv.cv_url);
                    const candidateName = application?.candidateName || cv.cv_url?.split('/').pop() || 'CV';

                    return (
                      <React.Fragment key={idx}>
                        <tr className="hover:bg-gray-50">
                          <td className="px-4 py-3 text-sm text-gray-900">
                            {idx + 1}
                          </td>
                          <td className="px-4 py-3 text-sm text-gray-900">
                            <div>
                              <p className="font-medium">{candidateName}</p>
                              {application?.candidateEmail && (
                                <p className="text-xs text-gray-500">{application.candidateEmail}</p>
                              )}
                            </div>
                          </td>
                          <td className="px-4 py-3 text-center">
                            <span className="text-sm font-semibold text-gray-900">{cv.match_score.TotalScore}%</span>
                          </td>
                          <td className="px-4 py-3 text-center text-sm text-gray-700">{cv.match_score.TechnicalSkills}%</td>
                          <td className="px-4 py-3 text-center text-sm text-gray-700">{cv.match_score.Experience}%</td>
                          <td className="px-4 py-3 text-center text-sm text-gray-700">{cv.match_score.Education}%</td>
                          <td className="px-4 py-3 text-center">
                            <button
                              onClick={() => setExpandedCVIndex(expandedCVIndex === idx ? null : idx)}
                              className="text-blue-600 hover:text-blue-800 text-sm"
                            >
                              {expandedCVIndex === idx ? 'Ẩn' : 'Xem'}
                            </button>
                          </td>
                        </tr>

                        {/* Expanded Details Row */}
                        {expandedCVIndex === idx && cv.cv_data && (
                          <tr>
                            <td colSpan="7" className="px-6 py-4 bg-gray-50 border-t border-gray-200">
                              <div className="space-y-4 text-sm">
                                {/* Technical Skills */}
                                {cv.cv_data.TechnicalSkills && (
                                  <div>
                                    <h5 className="font-semibold text-gray-900 mb-2">Kỹ năng kỹ thuật</h5>
                                    <div className="grid grid-cols-3 gap-3 text-gray-700">
                                      {cv.cv_data.TechnicalSkills.ProgrammingLanguages?.length > 0 && (
                                        <div>
                                          <p className="text-gray-600 font-medium mb-1">Ngôn ngữ:</p>
                                          <p>{cv.cv_data.TechnicalSkills.ProgrammingLanguages.join(', ')}</p>
                                        </div>
                                      )}
                                      {cv.cv_data.TechnicalSkills.Frameworks?.length > 0 && (
                                        <div>
                                          <p className="text-gray-600 font-medium mb-1">Frameworks:</p>
                                          <p>{cv.cv_data.TechnicalSkills.Frameworks.join(', ')}</p>
                                        </div>
                                      )}
                                      {cv.cv_data.TechnicalSkills.Databases?.length > 0 && (
                                        <div>
                                          <p className="text-gray-600 font-medium mb-1">Databases:</p>
                                          <p>{cv.cv_data.TechnicalSkills.Databases.join(', ')}</p>
                                        </div>
                                      )}
                                    </div>
                                  </div>
                                )}

                                {/* Soft Skills */}
                                {cv.cv_data.SoftSkills?.length > 0 && (
                                  <div>
                                    <h5 className="font-semibold text-gray-900 mb-2">Kỹ năng mềm</h5>
                                    <p className="text-gray-700">{cv.cv_data.SoftSkills.join(', ')}</p>
                                  </div>
                                )}

                                {/* Experience */}
                                {cv.cv_data.Experience && (
                                  <div>
                                    <h5 className="font-semibold text-gray-900 mb-2">Kinh nghiệm</h5>
                                    <div className="space-y-1 text-gray-700">
                                      {cv.cv_data.Experience.Years && (
                                        <p>Số năm: <span className="font-medium">{cv.cv_data.Experience.Years} năm</span></p>
                                      )}
                                      {cv.cv_data.Experience.Roles?.length > 0 && (
                                        <p>Vị trí: {cv.cv_data.Experience.Roles.join(', ')}</p>
                                      )}
                                    </div>
                                  </div>
                                )}

                                {/* Education */}
                                {cv.cv_data.Education && (
                                  <div>
                                    <h5 className="font-semibold text-gray-900 mb-2">Học vấn</h5>
                                    <div className="grid grid-cols-2 gap-2 text-gray-700">
                                      {cv.cv_data.Education.Degree && (
                                        <p>Bằng cấp: {cv.cv_data.Education.Degree}</p>
                                      )}
                                      {cv.cv_data.Education.Major && (
                                        <p>Chuyên ngành: {cv.cv_data.Education.Major}</p>
                                      )}
                                      {cv.cv_data.Education.University && (
                                        <p>Trường: {cv.cv_data.Education.University}</p>
                                      )}
                                      {cv.cv_data.Education.GPA && (
                                        <p>GPA: <span className="font-medium">{cv.cv_data.Education.GPA}</span></p>
                                      )}
                                    </div>
                                  </div>
                                )}
                              </div>
                            </td>
                          </tr>
                        )}
                      </React.Fragment>
                    );
                  })}
              </tbody>
            </table>
          </div>
        </div>
      )}
    </div>
  );
}

// HR Assistant Modal Component
const HRAssistantModal = ({ applications, selectedJobId, weights, setWeights, onClose, onResultsReceived }) => {
  const [jdUrl, setJdUrl] = useState("");
  const [loading, setLoading] = useState(false);
  const [result, setResult] = useState(null);
  const [expandedCV, setExpandedCV] = useState(null);

  // Fetch job details to get JD URL
  useEffect(() => {
    const fetchJobDetails = async () => {
      try {
        const job = await jobService.getJobById(selectedJobId);
        console.log("Job details:", job);
        const jdFileUrl = job.jdFileUrl || job.jdUrl || job.jobDescriptionUrl || "";
        setJdUrl(jdFileUrl);
      } catch (error) {
        console.error("Error fetching job details:", error);
      }
    };

    if (selectedJobId) {
      fetchJobDetails();
    }
  }, [selectedJobId]);

  const handleWeightChange = (key, value) => {
    const numValue = parseFloat(value) || 0;
    setWeights(prev => ({ ...prev, [key]: numValue }));
  };

  const handleSubmit = async () => {
    // Validate weights sum to 1.0
    const totalWeight = Object.values(weights).reduce((sum, w) => sum + w, 0);
    if (Math.abs(totalWeight - 1.0) > 0.01) {
      alert(`Tổng trọng số phải bằng 1.0 (hiện tại: ${totalWeight.toFixed(2)})`);
      return;
    }

    if (!jdUrl.trim()) {
      alert("Không tìm thấy JD URL từ tin đăng này. Vui lòng nhập thủ công.");
      return;
    }

    const cv_urls = applications.map(app => app.cvUrl).filter(Boolean);

    if (cv_urls.length === 0) {
      alert("Không có CV nào để phân tích");
      return;
    }

    // Create FormData
    const formData = new FormData();

    // Add cv_urls as JSON string
    formData.append('cv_urls', JSON.stringify(cv_urls));

    // Add jd_url
    formData.append('jd_url', jdUrl);

    // Add weights as JSON string
    formData.append('weights', JSON.stringify(weights));

    console.log("HR Assistant FormData:", {
      weights,
      cv_urls,
      jd_url: jdUrl
    });

    try {
      setLoading(true);
      const apiKey = import.meta.env.VITE_CV_MATCHING_API_KEY || "";

      const response = await fetch('http://jobhuntai.c5etagb0eja7f7hf.southeastasia.azurecontainer.io:8000/match/multiple', {
        method: 'POST',
        headers: {
          'X-API-Key': apiKey
          // Don't set Content-Type, let browser set it with boundary for FormData
        },
        body: formData
      });

      if (!response.ok) {
        const errorText = await response.text();
        console.error('API Error Response:', errorText);
        throw new Error(`HTTP error! status: ${response.status}`);
      }

      const data = await response.json();
      console.log("HR Assistant Result:", data);
      onResultsReceived(data);
      // Modal will be closed by parent component
    } catch (error) {
      console.error('Error calling HR Assistant API:', error);
      alert(`Lỗi khi gọi API: ${error.message}`);
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="fixed inset-0 bg-black/50 flex items-center justify-center z-50 p-4">
      <div className="bg-white rounded-lg shadow-lg w-full max-w-2xl max-h-[90vh] overflow-y-auto">
        {/* Header */}
        <div className="px-6 py-4 border-b border-gray-200">
          <h3 className="text-lg font-semibold text-gray-900">HR Assistant - Phân tích CV</h3>
          <p className="text-gray-600 text-sm mt-1">
            Phân tích {applications.length} CV với trọng số tùy chỉnh
          </p>
        </div>

        {/* Body */}
        <div className="p-6 space-y-6">
          {/* JD URL Input */}
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">
              JD File URL <span className="text-red-500">*</span>
            </label>
            <input
              type="url"
              value={jdUrl}
              onChange={(e) => setJdUrl(e.target.value)}
              placeholder="https://example.com/jd-file.pdf"
              className="w-full border border-gray-300 rounded-lg px-4 py-2 focus:ring-2 focus:ring-blue-500 focus:border-blue-500 outline-none"
            />
          </div>

          {/* Weights Configuration */}
          <div>
            <label className="block text-sm font-semibold text-gray-700 mb-3">
              Cấu hình trọng số (tổng = 1.0)
            </label>
            <div className="space-y-3">
              {Object.entries(weights).map(([key, value]) => (
                <div key={key} className="flex items-center gap-3">
                  <label className="w-40 text-sm text-gray-700">{key}:</label>
                  <input
                    type="number"
                    step="0.01"
                    min="0"
                    max="1"
                    value={value}
                    onChange={(e) => handleWeightChange(key, e.target.value)}
                    className="flex-1 border border-gray-300 rounded-lg px-3 py-2 focus:ring-2 focus:ring-purple-500 outline-none"
                  />
                  <span className="text-sm text-gray-500 w-12 text-right">
                    {(value * 100).toFixed(0)}%
                  </span>
                </div>
              ))}
            </div>
            <div className="mt-2 text-sm text-gray-600">
              Tổng: <span className={`font-semibold ${Math.abs(Object.values(weights).reduce((s, w) => s + w, 0) - 1.0) < 0.01 ? 'text-green-600' : 'text-red-600'}`}>
                {Object.values(weights).reduce((s, w) => s + w, 0).toFixed(2)}
              </span>
            </div>
          </div>

          {/* CV List Preview */}
          <div>
            <label className="block text-sm font-semibold text-gray-700 mb-2">
              Danh sách CV ({applications.filter(app => app.cvUrl).length})
            </label>
            <div className="max-h-32 overflow-y-auto border border-gray-200 rounded-lg p-3 bg-gray-50">
              {applications.filter(app => app.cvUrl).map((app, idx) => (
                <div key={idx} className="text-xs text-gray-600 truncate">
                  {idx + 1}. {app.candidateName} - {app.candidateEmail}
                </div>
              ))}
            </div>
          </div>

          {/* Result Display */}
          {result && result.results && (
            <div className="border border-green-200 bg-green-50 rounded-lg p-4">
              <div className="flex justify-between items-center mb-3">
                <h4 className="font-semibold text-green-800">✓ Kết quả phân tích ({result.results.length} CV)</h4>
                {result.excel_download_url && (
                  <a
                    href={result.excel_download_url}
                    download
                    className="px-3 py-1 bg-green-600 text-white rounded-lg hover:bg-green-700 transition text-sm"
                  >
                    📥 Tải Excel
                  </a>
                )}
              </div>

              <div className="overflow-x-auto">
                <table className="w-full text-xs">
                  <thead className="bg-green-100">
                    <tr>
                      <th className="px-2 py-2 text-left">#</th>
                      <th className="px-2 py-2 text-left">CV</th>
                      <th className="px-2 py-2 text-center">Tổng điểm</th>
                      <th className="px-2 py-2 text-center">Kỹ năng</th>
                      <th className="px-2 py-2 text-center">Kinh nghiệm</th>
                      <th className="px-2 py-2 text-center">Học vấn</th>
                      <th className="px-2 py-2 text-center">Chi tiết</th>
                    </tr>
                  </thead>
                  <tbody className="divide-y divide-green-200">
                    {result.results
                      .sort((a, b) => b.match_score.TotalScore - a.match_score.TotalScore)
                      .map((cv, idx) => (
                        <React.Fragment key={idx}>
                          <tr className={idx < 3 ? 'bg-yellow-50' : 'bg-white'}>
                            <td className="px-2 py-2 font-bold">
                              {idx + 1}
                              {idx === 0 && ' 🥇'}
                              {idx === 1 && ' 🥈'}
                              {idx === 2 && ' 🥉'}
                            </td>
                            <td className="px-2 py-2 truncate max-w-[150px]" title={cv.cv_url}>
                              {cv.cv_url?.split('/').pop() || 'CV'}
                            </td>
                            <td className="px-2 py-2 text-center font-bold text-green-700">
                              {cv.match_score.TotalScore.toFixed(1)}%
                            </td>
                            <td className="px-2 py-2 text-center">{cv.match_score.TechnicalSkills.toFixed(1)}%</td>
                            <td className="px-2 py-2 text-center">{cv.match_score.Experience.toFixed(1)}%</td>
                            <td className="px-2 py-2 text-center">{cv.match_score.Education.toFixed(1)}%</td>
                            <td className="px-2 py-2 text-center">
                              <button
                                onClick={() => setExpandedCV(expandedCV === idx ? null : idx)}
                                className="text-blue-600 hover:text-blue-800 text-xs font-medium"
                              >
                                {expandedCV === idx ? '▲ Ẩn' : '▼ Xem'}
                              </button>
                            </td>
                          </tr>

                          {/* Expanded Details Row */}
                          {expandedCV === idx && cv.cv_data && (
                            <tr>
                              <td colSpan="7" className="px-4 py-3 bg-gray-50">
                                <div className="space-y-3 text-xs">
                                  {/* Technical Skills */}
                                  {cv.cv_data.TechnicalSkills && (
                                    <div>
                                      <h5 className="font-semibold text-gray-800 mb-1">💻 Kỹ năng kỹ thuật</h5>
                                      <div className="grid grid-cols-2 gap-2">
                                        {cv.cv_data.TechnicalSkills.ProgrammingLanguages?.length > 0 && (
                                          <div>
                                            <p className="text-gray-600 font-medium">Ngôn ngữ:</p>
                                            <p className="text-gray-800">{cv.cv_data.TechnicalSkills.ProgrammingLanguages.join(', ')}</p>
                                          </div>
                                        )}
                                        {cv.cv_data.TechnicalSkills.Frameworks?.length > 0 && (
                                          <div>
                                            <p className="text-gray-600 font-medium">Frameworks:</p>
                                            <p className="text-gray-800">{cv.cv_data.TechnicalSkills.Frameworks.join(', ')}</p>
                                          </div>
                                        )}
                                        {cv.cv_data.TechnicalSkills.Databases?.length > 0 && (
                                          <div>
                                            <p className="text-gray-600 font-medium">Databases:</p>
                                            <p className="text-gray-800">{cv.cv_data.TechnicalSkills.Databases.join(', ')}</p>
                                          </div>
                                        )}
                                      </div>
                                    </div>
                                  )}

                                  {/* Soft Skills */}
                                  {cv.cv_data.SoftSkills?.length > 0 && (
                                    <div>
                                      <h5 className="font-semibold text-gray-800 mb-1">🤝 Kỹ năng mềm</h5>
                                      <p className="text-gray-800">{cv.cv_data.SoftSkills.join(', ')}</p>
                                    </div>
                                  )}

                                  {/* Experience */}
                                  {cv.cv_data.Experience && (
                                    <div>
                                      <h5 className="font-semibold text-gray-800 mb-1">💼 Kinh nghiệm</h5>
                                      <div className="space-y-1">
                                        {cv.cv_data.Experience.Years && <p><span className="text-gray-600">Số năm:</span> <span className="text-gray-800 font-medium">{cv.cv_data.Experience.Years} năm</span></p>}
                                        {cv.cv_data.Experience.Roles?.length > 0 && <p><span className="text-gray-600">Vị trí:</span> <span className="text-gray-800">{cv.cv_data.Experience.Roles.join(', ')}</span></p>}
                                      </div>
                                    </div>
                                  )}

                                  {/* Education */}
                                  {cv.cv_data.Education && (
                                    <div>
                                      <h5 className="font-semibold text-gray-800 mb-1">🎓 Học vấn</h5>
                                      <div className="space-y-1">
                                        {cv.cv_data.Education.Degree && <p><span className="text-gray-600">Bằng cấp:</span> <span className="text-gray-800">{cv.cv_data.Education.Degree}</span></p>}
                                        {cv.cv_data.Education.Major && <p><span className="text-gray-600">Chuyên ngành:</span> <span className="text-gray-800">{cv.cv_data.Education.Major}</span></p>}
                                        {cv.cv_data.Education.University && <p><span className="text-gray-600">Trường:</span> <span className="text-gray-800">{cv.cv_data.Education.University}</span></p>}
                                        {cv.cv_data.Education.GPA && <p><span className="text-gray-600">GPA:</span> <span className="text-gray-800 font-medium">{cv.cv_data.Education.GPA}</span></p>}
                                      </div>
                                    </div>
                                  )}
                                </div>
                              </td>
                            </tr>
                          )}
                        </React.Fragment>
                      ))}
                  </tbody>
                </table>
              </div>
            </div>
          )}
        </div>

        {/* Footer */}
        <div className="px-6 py-4 border-t border-gray-200 flex justify-end gap-3">
          <button
            onClick={onClose}
            className="px-4 py-2 border border-gray-300 text-gray-700 rounded-lg hover:bg-gray-50 transition"
          >
            Đóng
          </button>
          <button
            onClick={handleSubmit}
            disabled={loading}
            className="px-6 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition font-medium disabled:opacity-50"
          >
            {loading ? "Đang phân tích..." : "Phân tích CV"}
          </button>
        </div>
      </div>
    </div>
  );
};

export default RecruiterApplicationManagement;

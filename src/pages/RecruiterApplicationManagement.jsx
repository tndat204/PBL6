import { useState, useEffect } from "react";
import { useAuth } from "../hooks/useAuth";
import { applicationService } from "../services";
import { FileText, Eye, Download } from "lucide-react";

export default function RecruiterApplicationManagement() {
  const { company } = useAuth();
  const [applications, setApplications] = useState([]);
  const [loading, setLoading] = useState(true);
  const [filterStatus, setFilterStatus] = useState("ALL");
  const [searchTerm, setSearchTerm] = useState("");

  useEffect(() => {
    if (company?.id) {
      fetchApplications();
    }
  }, [company]);

  const fetchApplications = async () => {
    try {
      setLoading(true);
      const data = await applicationService.getApplicationsByCompany(company.id);
      setApplications(Array.isArray(data) ? data : []);
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
      fetchApplications();
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

      {/* Filters */}
      <div className="bg-white rounded-lg shadow-sm p-4 mb-6">
        <div className="flex flex-wrap gap-4">
          <div className="flex-1 min-w-[200px]">
            <input
              type="text"
              placeholder="Tìm theo tên hoặc email ứng viên..."
              value={searchTerm}
              onChange={(e) => setSearchTerm(e.target.value)}
              className="w-full border border-gray-300 rounded-lg px-4 py-2 focus:ring-2 focus:ring-emerald-500 outline-none"
            />
          </div>
          <div className="flex gap-2 flex-wrap">
            {["ALL", "SUBMITTED", "REVIEWED", "INTERVIEW", "HIRED", "REJECTED"].map((status) => (
              <button
                key={status}
                onClick={() => setFilterStatus(status)}
                className={`px-3 py-2 rounded-lg text-sm transition ${
                  filterStatus === status
                    ? "bg-emerald-600 text-white"
                    : "bg-gray-100 text-gray-700 hover:bg-gray-200"
                }`}
              >
                {status === "ALL" ? "Tất cả" : getStatusLabel(status)}
              </button>
            ))}
          </div>
        </div>
      </div>

      {/* Applications Table */}
      <div className="bg-white rounded-lg shadow-sm overflow-hidden">
        <table className="w-full">
          <thead className="bg-gray-50 border-b">
            <tr>
              <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                Ứng viên
              </th>
              <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                Vị trí ứng tuyển
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
                      <div className="w-10 h-10 rounded-full bg-emerald-100 flex items-center justify-center">
                        <FileText className="text-emerald-600" size={20} />
                      </div>
                      <div>
                        <p className="text-sm font-medium text-gray-900">{app.candidateName || "N/A"}</p>
                        <p className="text-xs text-gray-500">{app.candidateEmail || "N/A"}</p>
                      </div>
                    </div>
                  </td>
                  <td className="px-6 py-4 text-sm text-gray-900">
                    {app.jobTitle || "N/A"}
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
    </div>
  );
}

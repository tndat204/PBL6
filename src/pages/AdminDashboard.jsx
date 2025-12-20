import { useState, useEffect } from "react";
import {
  UsersIcon,
  BriefcaseIcon,
  BuildingOfficeIcon,
  DocumentTextIcon,
  CheckCircleIcon,
  ChartBarIcon,
  CurrencyDollarIcon,
  AcademicCapIcon,
} from "@heroicons/react/24/outline";
import { statisticsService } from "../services";
import {
  BarChart,
  Bar,
  LineChart,
  Line,
  PieChart,
  Pie,
  Cell,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
  Legend,
  ResponsiveContainer,
} from "recharts";

export default function AdminDashboard() {
  const [summary, setSummary] = useState(null);
  const [topSkills, setTopSkills] = useState([]);
  const [salaryStats, setSalaryStats] = useState([]);
  const [growthStats, setGrowthStats] = useState([]);
  const [experienceStats, setExperienceStats] = useState([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    fetchAllStats();
  }, []);

  const fetchAllStats = async () => {
    try {
      setLoading(true);
      const [summaryData, skillsData, salaryData, growthData, experienceData] = await Promise.all([
        statisticsService.getSummary(),
        statisticsService.getTopSkills(),
        statisticsService.getSalaryStats(),
        statisticsService.getGrowthStats(),
        statisticsService.getExperienceStats(),
      ]);

      console.log("Summary:", summaryData);
      console.log("Skills:", skillsData);
      console.log("Salary:", salaryData);
      console.log("Growth:", growthData);
      console.log("Experience:", experienceData);

      // API trả về { code, message, result }, cần lấy result
      setSummary(summaryData?.result || summaryData);
      setTopSkills(Array.isArray(skillsData?.result) ? skillsData.result : Array.isArray(skillsData) ? skillsData : []);
      setSalaryStats(Array.isArray(salaryData?.result) ? salaryData.result : Array.isArray(salaryData) ? salaryData : []);
      setGrowthStats(Array.isArray(growthData?.result) ? growthData.result : Array.isArray(growthData) ? growthData : []);
      setExperienceStats(Array.isArray(experienceData?.result) ? experienceData.result : Array.isArray(experienceData) ? experienceData : []);
    } catch (error) {
      console.error("Lỗi khi tải thống kê:", error);
    } finally {
      setLoading(false);
    }
  };

  if (loading) {
    return (
      <div className="flex items-center justify-center min-h-screen">
        <div className="text-center">
          <div className="inline-block animate-spin rounded-full h-12 w-12 border-4 border-emerald-500 border-t-transparent mb-4"></div>
          <p className="text-slate-600">Đang tải thống kê...</p>
        </div>
      </div>
    );
  }

  const statCards = [
    {
      title: "Tổng Người Dùng",
      value: summary?.totalUsers || 0,
      icon: UsersIcon,
      color: "bg-blue-500",
      bgLight: "bg-blue-50",
      textColor: "text-blue-600",
    },
    {
      title: "Ứng Viên",
      value: summary?.totalApplicants || 0,
      icon: UsersIcon,
      color: "bg-emerald-500",
      bgLight: "bg-emerald-50",
      textColor: "text-emerald-600",
    },
    {
      title: "Nhà Tuyển Dụng",
      value: summary?.totalRecruiters || 0,
      icon: BriefcaseIcon,
      color: "bg-purple-500",
      bgLight: "bg-purple-50",
      textColor: "text-purple-600",
    },
    {
      title: "Quản Trị Viên",
      value: summary?.totalAdmin || 0,
      icon: AcademicCapIcon,
      color: "bg-orange-500",
      bgLight: "bg-orange-50",
      textColor: "text-orange-600",
    },
    {
      title: "Tổng Công Ty",
      value: summary?.totalCompanies || 0,
      icon: BuildingOfficeIcon,
      color: "bg-cyan-500",
      bgLight: "bg-cyan-50",
      textColor: "text-cyan-600",
    },
    {
      title: "Công Ty Hoạt Động",
      value: summary?.totalActiveCompanies || 0,
      icon: CheckCircleIcon,
      color: "bg-green-500",
      bgLight: "bg-green-50",
      textColor: "text-green-600",
    },
    {
      title: "Việc Làm Đang Tuyển",
      value: summary?.totalActiveJobs || 0,
      icon: BriefcaseIcon,
      color: "bg-indigo-500",
      bgLight: "bg-indigo-50",
      textColor: "text-indigo-600",
    },
    {
      title: "Tổng Đơn Ứng Tuyển",
      value: summary?.totalApplications || 0,
      icon: DocumentTextIcon,
      color: "bg-pink-500",
      bgLight: "bg-pink-50",
      textColor: "text-pink-600",
    },
    {
      title: "Việc Làm Đã Tuyển",
      value: summary?.totalJobsHired || 0,
      icon: CheckCircleIcon,
      color: "bg-teal-500",
      bgLight: "bg-teal-50",
      textColor: "text-teal-600",
    },
  ];

  // Colors for charts
  const COLORS = ['#10b981', '#3b82f6', '#8b5cf6', '#f59e0b', '#ef4444', '#06b6d4', '#ec4899', '#6366f1'];

  return (
    <div className="min-h-screen bg-slate-50 p-6">
      <div className="max-w-7xl mx-auto">
        {/* Header */}
        <div className="mb-8">
          <h1 className="text-3xl font-bold text-slate-900 mb-2">Tổng Quan Hệ Thống</h1>
          <p className="text-slate-600">Thống kê và phân tích dữ liệu tổng thể</p>
        </div>

        {/* Summary Cards */}
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6 mb-8">
          {statCards.map((stat, index) => (
            <div key={index} className="bg-white rounded-xl shadow-sm hover:shadow-md transition p-6">
              <div className="flex items-center justify-between">
                <div>
                  <p className="text-sm text-slate-600 mb-1">{stat.title}</p>
                  <p className="text-3xl font-bold text-slate-900">{stat.value.toLocaleString()}</p>
                </div>
                <div className={`${stat.bgLight} p-3 rounded-lg`}>
                  <stat.icon className={`w-8 h-8 ${stat.textColor}`} />
                </div>
              </div>
            </div>
          ))}
        </div>

        {/* Charts Grid */}
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
          {/* Top Skills Bar Chart */}
          <div className="bg-white rounded-xl shadow-sm p-6">
            <div className="flex items-center mb-6">
              <ChartBarIcon className="w-6 h-6 text-emerald-600 mr-2" />
              <h2 className="text-xl font-bold text-slate-900">Kỹ Năng Phổ Biến</h2>
            </div>
            <ResponsiveContainer width="100%" height={300}>
              <BarChart data={topSkills.slice(0, 8)}>
                <CartesianGrid strokeDasharray="3 3" stroke="#e2e8f0" />
                <XAxis
                  dataKey="skillName"
                  tick={{ fontSize: 12 }}
                  angle={-45}
                  textAnchor="end"
                  height={80}
                />
                <YAxis />
                <Tooltip
                  contentStyle={{
                    backgroundColor: '#fff',
                    border: '1px solid #e2e8f0',
                    borderRadius: '8px'
                  }}
                />
                <Bar dataKey="jobCount" fill="#10b981" radius={[8, 8, 0, 0]} />
              </BarChart>
            </ResponsiveContainer>
          </div>

          {/* Experience Distribution Pie Chart */}
          <div className="bg-white rounded-xl shadow-sm p-6">
            <div className="flex items-center mb-6">
              <AcademicCapIcon className="w-6 h-6 text-emerald-600 mr-2" />
              <h2 className="text-xl font-bold text-slate-900">Phân Bố Theo Kinh Nghiệm</h2>
            </div>
            <ResponsiveContainer width="100%" height={300}>
              <PieChart>
                <Pie
                  data={experienceStats}
                  cx="50%"
                  cy="50%"
                  labelLine={false}
                  label={({ level, percent }) => `${level}: ${(percent * 100).toFixed(0)}%`}
                  outerRadius={100}
                  fill="#8884d8"
                  dataKey="count"
                >
                  {experienceStats.map((entry, index) => (
                    <Cell key={`cell-${index}`} fill={COLORS[index % COLORS.length]} />
                  ))}
                </Pie>
                <Tooltip />
              </PieChart>
            </ResponsiveContainer>
          </div>

          {/* Salary Stats Bar Chart */}
          <div className="bg-white rounded-xl shadow-sm p-6">
            <div className="flex items-center mb-6">
              <CurrencyDollarIcon className="w-6 h-6 text-emerald-600 mr-2" />
              <h2 className="text-xl font-bold text-slate-900">Mức Lương Theo Kinh Nghiệm</h2>
            </div>
            <ResponsiveContainer width="100%" height={300}>
              <BarChart data={salaryStats}>
                <CartesianGrid strokeDasharray="3 3" stroke="#e2e8f0" />
                <XAxis
                  dataKey="experienceLevel"
                  tick={{ fontSize: 12 }}
                />
                <YAxis
                  tickFormatter={(value) => `${(value / 1000000).toFixed(0)}M`}
                />
                <Tooltip
                  formatter={(value) => `${value.toLocaleString()} VNĐ`}
                  contentStyle={{
                    backgroundColor: '#fff',
                    border: '1px solid #e2e8f0',
                    borderRadius: '8px'
                  }}
                />
                <Legend />
                <Bar dataKey="avgSalaryMin" fill="#3b82f6" name="Lương tối thiểu" radius={[8, 8, 0, 0]} />
                <Bar dataKey="avgSalaryMax" fill="#10b981" name="Lương tối đa" radius={[8, 8, 0, 0]} />
              </BarChart>
            </ResponsiveContainer>
          </div>

          {/* Growth Stats Line Chart */}
          <div className="bg-white rounded-xl shadow-sm p-6">
            <div className="flex items-center mb-6">
              <ChartBarIcon className="w-6 h-6 text-emerald-600 mr-2" />
              <h2 className="text-xl font-bold text-slate-900">Tăng Trưởng Theo Thời Gian</h2>
            </div>
            <ResponsiveContainer width="100%" height={300}>
              <LineChart data={growthStats}>
                <CartesianGrid strokeDasharray="3 3" stroke="#e2e8f0" />
                <XAxis
                  dataKey="id"
                  tick={{ fontSize: 12 }}
                />
                <YAxis />
                <Tooltip
                  contentStyle={{
                    backgroundColor: '#fff',
                    border: '1px solid #e2e8f0',
                    borderRadius: '8px'
                  }}
                />
                <Legend />
                <Line
                  type="monotone"
                  dataKey="newUsers"
                  stroke="#3b82f6"
                  strokeWidth={2}
                  name="Người dùng mới"
                  dot={{ r: 4 }}
                />
                <Line
                  type="monotone"
                  dataKey="newJobs"
                  stroke="#10b981"
                  strokeWidth={2}
                  name="Việc làm mới"
                  dot={{ r: 4 }}
                />
                <Line
                  type="monotone"
                  dataKey="newApplications"
                  stroke="#8b5cf6"
                  strokeWidth={2}
                  name="Đơn ứng tuyển"
                  dot={{ r: 4 }}
                />
              </LineChart>
            </ResponsiveContainer>
          </div>
        </div>
      </div>
    </div>
  );
}
// import { useState, useEffect } from "react";
// import { useAuth } from "../hooks/useAuth";

// function AdminDashboard() {
//   const { user } = useAuth();
//   const [stats, setStats] = useState({
//     totalUsers: 0,
//     totalCompanies: 0,
//     totalJobs: 0,
//     totalApplications: 0,
//     pendingJobs: 0,
//     activeJobs: 0
//   });

//   const [recentActivities, setRecentActivities] = useState([
//     { id: 1, type: "job_posted", message: "Công ty ABC đã đăng tin tuyển dụng mới", time: "2 giờ trước" },
//     { id: 2, type: "user_registered", message: "Người dùng mới đăng ký: Nguyễn Văn A", time: "3 giờ trước" },
//     { id: 3, type: "application", message: "Có 5 đơn ứng tuyển mới", time: "4 giờ trước" },
//   ]);

//   useEffect(() => {
//     // Fetch dashboard statistics
//     fetchDashboardStats();
//   }, []);

//   const fetchDashboardStats = async () => {
//     try {
//       // Gọi API để lấy thống kê
//       // const response = await adminService.getDashboardStats();
//       // setStats(response.data);

//       // Mock data for now
//       setStats({
//         totalUsers: 1250,
//         totalCompanies: 89,
//         totalJobs: 456,
//         totalApplications: 2340,
//         pendingJobs: 23,
//         activeJobs: 433
//       });
//     } catch (error) {
//       console.error("Lỗi khi lấy thống kê:", error);
//     }
//   };

//   const StatCard = ({ title, value, icon, color, trend }) => (
//     <div className="bg-white rounded-lg shadow-md p-6 border-l-4" style={{ borderLeftColor: color }}>
//       <div className="flex items-center justify-between">
//         <div>
//           <p className="text-sm font-medium text-gray-600 uppercase tracking-wider">{title}</p>
//           <p className="text-3xl font-bold text-gray-900 mt-2">{value}</p>
//           {trend && (
//             <p className={`text-sm mt-2 ${trend > 0 ? 'text-green-600' : 'text-red-600'}`}>
//               {trend > 0 ? '↗' : '↘'} {Math.abs(trend)}% so với tháng trước
//             </p>
//           )}
//         </div>
//         <div className="text-4xl" style={{ color }}>
//           {icon}
//         </div>
//       </div>
//     </div>
//   );

//   const QuickAction = ({ title, description, icon, color, onClick }) => (
//     <div 
//       onClick={onClick}
//       className="bg-white rounded-lg shadow-md p-4 cursor-pointer hover:shadow-lg transition-shadow border-l-4 hover:bg-gray-50"
//       style={{ borderLeftColor: color }}
//     >
//       <div className="flex items-center">
//         <div className="text-2xl mr-3" style={{ color }}>
//           {icon}
//         </div>
//         <div>
//           <h4 className="font-semibold text-gray-800">{title}</h4>
//           <p className="text-sm text-gray-600">{description}</p>
//         </div>
//       </div>
//     </div>
//   );

//   return (
//     <div className="min-h-screen bg-gray-50">
//       {/* Header */}
//       <div className="bg-white shadow-sm border-b">
//         <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
//           <div className="py-6">
//             <h1 className="text-3xl font-bold text-gray-900">
//               Bảng điều khiển quản trị
//             </h1>
//             <p className="mt-2 text-gray-600">
//               Chào mừng trở lại, {user?.fullName || user?.username}
//             </p>
//           </div>
//         </div>
//       </div>

//       <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
//         {/* Statistics Cards */}
//         <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6 mb-8">
//           <StatCard
//             title="Tổng người dùng"
//             value={stats.totalUsers.toLocaleString()}
//             icon="👥"
//             color="#3B82F6"
//             trend={12}
//           />
//           <StatCard
//             title="Tổng công ty"
//             value={stats.totalCompanies.toLocaleString()}
//             icon="🏢"
//             color="#10B981"
//             trend={8}
//           />
//           <StatCard
//             title="Tổng việc làm"
//             value={stats.totalJobs.toLocaleString()}
//             icon="💼"
//             color="#F59E0B"
//             trend={15}
//           />
//           <StatCard
//             title="Đơn ứng tuyển"
//             value={stats.totalApplications.toLocaleString()}
//             icon="📝"
//             color="#8B5CF6"
//             trend={25}
//           />
//           <StatCard
//             title="Việc làm chờ duyệt"
//             value={stats.pendingJobs.toLocaleString()}
//             icon="⏳"
//             color="#EF4444"
//           />
//           <StatCard
//             title="Việc làm đang hoạt động"
//             value={stats.activeJobs.toLocaleString()}
//             icon="✅"
//             color="#06B6D4"
//           />
//         </div>

//         <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
//           {/* Quick Actions */}
//           <div className="lg:col-span-1">
//             <div className="bg-white rounded-lg shadow-md p-6">
//               <h3 className="text-lg font-semibold text-gray-800 mb-4">Thao tác nhanh</h3>
//               <div className="space-y-3">
//                 <QuickAction
//                   title="Quản lý người dùng"
//                   description="Xem và quản lý tài khoản người dùng"
//                   icon="👤"
//                   color="#3B82F6"
//                   onClick={() => console.log("Navigate to user management")}
//                 />
//                 <QuickAction
//                   title="Duyệt tin tuyển dụng"
//                   description="Phê duyệt các tin tuyển dụng chờ duyệt"
//                   icon="📋"
//                   color="#F59E0B"
//                   onClick={() => console.log("Navigate to job approval")}
//                 />
//                 <QuickAction
//                   title="Báo cáo thống kê"
//                   description="Xem báo cáo chi tiết hệ thống"
//                   icon="📊"
//                   color="#10B981"
//                   onClick={() => console.log("Navigate to reports")}
//                 />
//                 <QuickAction
//                   title="Cài đặt hệ thống"
//                   description="Cấu hình và thiết lập hệ thống"
//                   icon="⚙️"
//                   color="#8B5CF6"
//                   onClick={() => console.log("Navigate to settings")}
//                 />
//               </div>
//             </div>
//           </div>

//           {/* Recent Activities */}
//           <div className="lg:col-span-2">
//             <div className="bg-white rounded-lg shadow-md p-6">
//               <h3 className="text-lg font-semibold text-gray-800 mb-4">Hoạt động gần đây</h3>
//               <div className="space-y-4">
//                 {recentActivities.map((activity) => (
//                   <div key={activity.id} className="flex items-start space-x-3 p-3 rounded-lg hover:bg-gray-50">
//                     <div className="flex-shrink-0">
//                       <div className="w-8 h-8 bg-blue-100 rounded-full flex items-center justify-center">
//                         {activity.type === 'job_posted' && '💼'}
//                         {activity.type === 'user_registered' && '👤'}
//                         {activity.type === 'application' && '📝'}
//                       </div>
//                     </div>
//                     <div className="flex-1 min-w-0">
//                       <p className="text-sm text-gray-900">{activity.message}</p>
//                       <p className="text-xs text-gray-500 mt-1">{activity.time}</p>
//                     </div>
//                   </div>
//                 ))}
//               </div>
//               <div className="mt-4 text-center">
//                 <button className="text-sm text-blue-600 hover:text-blue-800 font-medium">
//                   Xem tất cả hoạt động →
//                 </button>
//               </div>
//             </div>
//           </div>
//         </div>

//         {/* System Status */}
//         <div className="mt-8">
//           <div className="bg-white rounded-lg shadow-md p-6">
//             <h3 className="text-lg font-semibold text-gray-800 mb-4">Trạng thái hệ thống</h3>
//             <div className="grid grid-cols-1 md:grid-cols-4 gap-4">
//               <div className="flex items-center space-x-2">
//                 <div className="w-3 h-3 bg-green-500 rounded-full"></div>
//                 <span className="text-sm text-gray-600">Server: Hoạt động tốt</span>
//               </div>
//               <div className="flex items-center space-x-2">
//                 <div className="w-3 h-3 bg-green-500 rounded-full"></div>
//                 <span className="text-sm text-gray-600">Database: Hoạt động tốt</span>
//               </div>
//               <div className="flex items-center space-x-2">
//                 <div className="w-3 h-3 bg-yellow-500 rounded-full"></div>
//                 <span className="text-sm text-gray-600">Email: Chậm</span>
//               </div>
//               <div className="flex items-center space-x-2">
//                 <div className="w-3 h-3 bg-green-500 rounded-full"></div>
//                 <span className="text-sm text-gray-600">Storage: 78% còn trống</span>
//               </div>
//             </div>
//           </div>
//         </div>
//       </div>
//     </div>
//   );
// }

// export default AdminDashboard;


import React, {  } from 'react';
import {
  LayoutDashboard,
  Users,
  Building2,
  Briefcase,
  Star,
  Tags,
  LogOut,
  Bell,
  Search
} from 'lucide-react';

const AdminDashboard = () => {
  return (
    <div className="h-full flex flex-col">
      {/* CONTENT BODY */}
      <div className="flex-1 overflow-y-auto">

        {/* Stats Grid */}
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-8">
          <StatCard title="Tổng Ứng Viên" value="21" color="blue" icon={<Users />} trend="+12%" />
          <StatCard title="Nhà Tuyển Dụng" value="4" color="indigo" icon={<Building2 />} trend="+5%" />
          <StatCard title="Tin Đang Mở" value="20" color="green" icon={<Briefcase />} trend="+8%" />
          <StatCard title="Chờ Phê Duyệt" value="12" color="orange" icon={<Bell />} trend="Quan trọng" />
        </div>

        {/* Recent Jobs Table (Demo cho UC Quản lý tin tuyển dụng) */}
        <div className="bg-white rounded-xl shadow-sm border border-gray-100 overflow-hidden">
          <div className="p-6 border-b border-gray-100 flex justify-between items-center">
            <h3 className="font-bold text-gray-800">Tin tuyển dụng mới nhất (Cần duyệt)</h3>
            <button className="text-blue-600 text-sm font-medium hover:underline">Xem tất cả</button>
          </div>
          <div className="overflow-x-auto">
            <table className="w-full text-left border-collapse">
              <thead className="bg-gray-50 text-gray-600 uppercase text-xs font-semibold">
                <tr>
                  <th className="px-6 py-4">Công ty</th>
                  <th className="px-6 py-4">Vị trí</th>
                  <th className="px-6 py-4">Ngày đăng</th>
                  <th className="px-6 py-4">Trạng thái</th>
                  <th className="px-6 py-4">Hành động</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-gray-100 text-sm text-gray-700">
                {/* Mock Data */}
                <TableRow company="FPT Software" job="Senior React Dev" date="22/11/2025" status="Pending" />
                <TableRow company="Viettel Group" job="Java Spring Boot Lead" date="21/11/2025" status="Active" />
                <TableRow company="VNG Corp" job="Product Owner" date="20/11/2025" status="Pending" />
              </tbody>
            </table>
          </div>
        </div>

      </div>
    </div>
  );
};

// Component phụ cho thẻ Stats
const StatCard = ({ title, value, color, icon, trend }) => (
  <div className="bg-white p-6 rounded-xl shadow-sm border border-gray-100 hover:shadow-md transition-shadow">
    <div className="flex justify-between items-start">
      <div>
        <p className="text-gray-500 text-xs font-semibold uppercase tracking-wide">{title}</p>
        <h3 className="text-2xl font-bold text-gray-800 mt-2">{value}</h3>
      </div>
      <div className={`p-3 rounded-lg bg-${color}-50 text-${color}-600`}>
        {icon}
      </div>
    </div>
    <div className="mt-4 flex items-center text-sm">
      <span className="text-green-500 font-medium">{trend}</span>
      <span className="text-gray-400 ml-2">so với tháng trước</span>
    </div>
  </div>
);

// Component phụ cho dòng trong bảng
const TableRow = ({ company, job, date, status }) => (
  <tr className="hover:bg-gray-50 transition-colors">
    <td className="px-6 py-4 font-medium text-gray-800">{company}</td>
    <td className="px-6 py-4">{job}</td>
    <td className="px-6 py-4 text-gray-500">{date}</td>
    <td className="px-6 py-4">
      <span className={`px-3 py-1 rounded-full text-xs font-medium ${status === 'Active' ? 'bg-green-100 text-green-700' : 'bg-yellow-100 text-yellow-700'}`}>
        {status}
      </span>
    </td>
    <td className="px-6 py-4">
      <button className="text-blue-600 hover:text-blue-800 mr-3 font-medium">Chi tiết</button>
      {status === 'Pending' && <button className="text-green-600 hover:text-green-800 font-medium">Duyệt</button>}
    </td>
  </tr>
);

export default AdminDashboard;
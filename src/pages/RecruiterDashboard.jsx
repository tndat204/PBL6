// import { useState, useEffect } from 'react';
import { useAuth } from '../hooks/useAuth';
import { 
  Briefcase, 
  Users, 
  Eye,
  FileText,
  TrendingUp,
  Clock
} from 'lucide-react';

const RecruiterDashboard = () => {
  const { user, company } = useAuth();

  // Sample data - replace with actual API calls
  const stats = {
    activeJobs: 4,
    newApplications: 18,
    totalViews: 1294,
    expiringSoon: 2,
  };

  return (
    <div>
      {/* Welcome Header */}
      <div className="mb-6">
        <h1 className="text-2xl font-bold text-gray-900">
          Xin chào, {user?.fullName || 'Recruiter'} 👋
        </h1>
        <p className="text-gray-600 mt-1">
          Đây là tổng quan hoạt động tuyển dụng của bạn
        </p>
      </div>

      {/* Quick Stats */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-8">
        <StatCard 
          title="Tin đang tuyển" 
          value={stats.activeJobs} 
          icon={<Briefcase className="text-blue-600" size={24} />} 
          subtext={`${stats.expiringSoon} tin sắp hết hạn`}
          bgColor="bg-blue-50"
        />
        <StatCard 
          title="CV chưa xem" 
          value={stats.newApplications} 
          icon={<FileText className="text-purple-600" size={24} />} 
          subtext="+5 hồ sơ hôm nay"
          bgColor="bg-purple-50"
          highlight
        />
        <StatCard 
          title="Lượt xem hồ sơ" 
          value={stats.totalViews.toLocaleString()} 
          icon={<Eye className="text-green-600" size={24} />} 
          subtext="Tăng 12% tuần qua"
          bgColor="bg-green-50"
        />
        <StatCard 
          title="Tổng ứng viên" 
          value="87" 
          icon={<Users className="text-orange-600" size={24} />} 
          subtext="Tất cả các vị trí"
          bgColor="bg-orange-50"
        />
      </div>

      {/* Recent Activities Grid */}
      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        {/* Left Column: Recent Applications */}
        <div className="lg:col-span-2 bg-white rounded-lg shadow-sm p-6">
          <div className="flex items-center justify-between mb-4">
            <h2 className="text-lg font-bold text-gray-900">Ứng viên mới ứng tuyển</h2>
            <button className="text-sm text-emerald-600 hover:text-emerald-700 font-medium">
              Xem tất cả →
            </button>
          </div>
          
          <div className="space-y-4">
            <ApplicationItem 
              name="Nguyễn Văn A"
              position="React Developer"
              time="10 phút trước"
              status="new"
            />
            <ApplicationItem 
              name="Trần Thị B"
              position="Java Senior"
              time="2 giờ trước"
              status="new"
            />
            <ApplicationItem 
              name="Lê Hoàng C"
              position="Tester"
              time="Hôm qua"
              status="reviewed"
            />
            <ApplicationItem 
              name="Phạm Văn D"
              position="React Developer"
              time="Hôm qua"
              status="reviewed"
            />
          </div>
        </div>

        {/* Right Column: Top Performing Jobs */}
        <div className="bg-white rounded-lg shadow-sm p-6">
          <h2 className="text-lg font-bold text-gray-900 mb-4">Tin tuyển dụng hiệu quả</h2>
          
          <div className="space-y-4">
            <JobPerformanceItem 
              title="Senior ReactJS Developer"
              applications={15}
              views={142}
            />
            <JobPerformanceItem 
              title="Java Spring Boot Inter"
              applications={12}
              views={98}
            />
            <JobPerformanceItem 
              title="Manual Tester (QC)"
              applications={8}
              views={67}
            />
          </div>

          <button className="w-full mt-6 text-center text-sm text-emerald-600 hover:text-emerald-700 font-medium">
            Quản lý tất cả tin đăng →
          </button>
        </div>
      </div>

      {/* Quick Actions */}
      <div className="mt-6 grid grid-cols-1 md:grid-cols-3 gap-4">
        <QuickActionCard 
          icon={<Briefcase size={20} />}
          title="Đăng tin mới"
          description="Tạo tin tuyển dụng mới"
          color="blue"
        />
        <QuickActionCard 
          icon={<Users size={20} />}
          title="Xem hồ sơ"
          description="Quản lý CV đã nhận"
          color="purple"
        />
        <QuickActionCard 
          icon={<TrendingUp size={20} />}
          title="Báo cáo"
          description="Xem thống kê chi tiết"
          color="green"
        />
      </div>
    </div>
  );
};

// Stat Card Component
const StatCard = ({ title, value, icon, subtext, bgColor, highlight }) => (
  <div className={`bg-white rounded-lg shadow-sm p-6 ${highlight ? 'ring-2 ring-emerald-500' : ''}`}>
    <div className="flex items-center justify-between mb-3">
      <div className={`${bgColor} p-3 rounded-lg`}>
        {icon}
      </div>
    </div>
    <div>
      <p className="text-sm text-gray-600 mb-1">{title}</p>
      <p className="text-3xl font-bold text-gray-900">{value}</p>
      <p className="text-xs text-gray-500 mt-2">{subtext}</p>
    </div>
  </div>
);

// Application Item Component
const ApplicationItem = ({ name, position, time, status }) => {
  const statusColors = {
    new: 'bg-blue-100 text-blue-800',
    reviewed: 'bg-purple-100 text-purple-800',
  };

  const statusLabels = {
    new: 'Mới',
    reviewed: 'Đã xem',
  };

  return (
    <div className="flex items-center justify-between p-3 hover:bg-gray-50 rounded-lg transition">
      <div className="flex items-center gap-3">
        <div className="w-10 h-10 rounded-full bg-emerald-100 flex items-center justify-center text-emerald-600 font-bold">
          {name[0]}
        </div>
        <div>
          <p className="text-sm font-medium text-gray-900">{name}</p>
          <p className="text-xs text-gray-500">{position}</p>
        </div>
      </div>
      <div className="text-right">
        <span className={`text-xs px-2 py-1 rounded-full ${statusColors[status]}`}>
          {statusLabels[status]}
        </span>
        <p className="text-xs text-gray-400 mt-1">{time}</p>
      </div>
    </div>
  );
};

// Job Performance Item Component
const JobPerformanceItem = ({ title, applications, views }) => (
  <div className="p-3 border border-gray-200 rounded-lg hover:border-emerald-500 transition">
    <p className="text-sm font-medium text-gray-900 mb-2">{title}</p>
    <div className="flex items-center justify-between text-xs text-gray-600">
      <span className="flex items-center gap-1">
        <FileText size={14} className="text-emerald-600" />
        {applications} ứng tuyển
      </span>
      <span className="flex items-center gap-1">
        <Eye size={14} className="text-blue-600" />
        {views} lượt xem
      </span>
    </div>
  </div>
);

// Quick Action Card Component
const QuickActionCard = ({ icon, title, description, color }) => {
  const colors = {
    blue: 'bg-blue-50 text-blue-600 hover:bg-blue-100',
    purple: 'bg-purple-50 text-purple-600 hover:bg-purple-100',
    green: 'bg-green-50 text-green-600 hover:bg-green-100',
  };

  return (
    <button className={`${colors[color]} p-4 rounded-lg transition text-left w-full`}>
      <div className="flex items-center gap-3">
        <div>{icon}</div>
        <div>
          <p className="font-medium text-sm">{title}</p>
          <p className="text-xs opacity-75">{description}</p>
        </div>
      </div>
    </button>
  );
};

export default RecruiterDashboard;
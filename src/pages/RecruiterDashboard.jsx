import { useState, useEffect } from 'react';
import { useAuth } from '../hooks/useAuth';
import { jobService, applicationService } from '../services';
import { useNavigate } from 'react-router-dom';
import StatCard from '../components/StatCard';
import ApplicationItem from '../components/ApplicationItem';
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
  const navigate = useNavigate();
  const [loading, setLoading] = useState(true);
  const [stats, setStats] = useState({
    activeJobs: 0,
    totalApplications: 0,
  });
  const [recentApplications, setRecentApplications] = useState([]);

  useEffect(() => {
    if (company?.id) {
      fetchStats();
    }
  }, [company]);

  const fetchStats = async () => {
    try {
      setLoading(true);
      console.log('Fetching stats for company:', company);
      
      // Fetch jobs and count active ones
      const jobsData = await jobService.getJobsByCompany(company.id);
      console.log("jobsData", jobsData);
      const jobs = Array.isArray(jobsData) ? jobsData : [];
      const activeJobsCount = jobs.filter(job => job.status === 'ACTIVE').length;
      console.log("activeJobsCount", activeJobsCount);
      
      // Fetch applications for each job and sum them
      let totalApplicationsCount = 0;
      const allApplications = [];
      
      // Use Promise.all for parallel fetching
      const applicationPromises = jobs.map(async (job) => {
        try {
          const jobApplications = await applicationService.getApplicationsByJob(job.id);
          const apps = Array.isArray(jobApplications) ? jobApplications : [];
          
          // Add jobTitle to each application
          const appsWithJobTitle = apps.map(app => ({
            ...app,
            jobTitle: job.title
          }));
          
          totalApplicationsCount += apps.length;
          console.log(`Job ${job.id} (${job.title}): ${apps.length} applications`);
          
          return appsWithJobTitle;
        } catch (error) {
          console.error(`Error fetching applications for job ${job.id}:`, error);
          return [];
        }
      });
      
      const results = await Promise.all(applicationPromises);
      allApplications.push(...results.flat());
      
      // Sort by appliedDate (most recent first)
      const sortedApplications = allApplications.sort((a, b) => {
        const dateA = new Date(a.appliedDate || 0);
        const dateB = new Date(b.appliedDate || 0);
        return dateB - dateA;
      });
      
      // Get 4 most recent applications
      const recent = sortedApplications.slice(0, 4);
      setRecentApplications(recent);
      
      console.log("Total applications count:", totalApplicationsCount);
      console.log("Recent applications:", recent);
      
      const newStats = {
        activeJobs: activeJobsCount,
        totalApplications: totalApplicationsCount,
      };
      
      console.log("Setting stats to:", newStats);
      setStats(newStats);
    } catch (error) {
      console.error('Error fetching stats:', error);
    } finally {
      setLoading(false);
    }
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
      {/* Welcome Header */}
      <div className="mb-8">
        <h1 className="text-3xl font-bold text-slate-900 mb-2">
          Xin chào, {user?.fullName || 'Recruiter'} 👋
        </h1>
        <p className="text-slate-600">
          Đây là tổng quan hoạt động tuyển dụng của bạn
        </p>
      </div>

      {/* Quick Stats - 4 cards */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-8">
        <StatCard 
          title="Tin đang tuyển" 
          value={stats.activeJobs} 
          icon={<Briefcase className="w-6 h-6 text-blue-600" />} 
          bgLight="bg-blue-50"
        />
        <StatCard 
          title="CV chưa xem" 
          value={0}
          icon={<FileText className="w-6 h-6 text-purple-600" />} 
          bgLight="bg-purple-50"
          highlight
        />
        <StatCard 
          title="Lượt xem hồ sơ" 
          value={0}
          icon={<Eye className="w-6 h-6 text-green-600" />} 
          bgLight="bg-green-50"
        />
        <StatCard 
          title="Tổng ứng viên" 
          value={stats.totalApplications} 
          icon={<Users className="w-6 h-6 text-orange-600" />} 
          bgLight="bg-orange-50"
        />
      </div>

      {/* Recent Activities Grid */}
      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        {/* Left Column: Recent Applications */}
        <div className="lg:col-span-2 bg-white rounded-lg shadow-sm p-6">
          <div className="flex items-center justify-between mb-4">
            <h2 className="text-xl font-bold text-slate-900">Ứng viên mới ứng tuyển</h2>
            <button 
              onClick={() => navigate('/recruiter/applications')}
              className="text-sm text-emerald-600 hover:text-emerald-700 font-medium"
            >
              Xem tất cả →
            </button>
          </div>
          
          <div className="space-y-4">
            {recentApplications.length > 0 ? (
              recentApplications.map((app) => (
                <ApplicationItem key={app.id} application={app} />
              ))
            ) : (
              <p className="text-center text-gray-500 py-8">Chưa có ứng viên nào</p>
            )}
          </div>
        </div>

        {/* Right Column: Top Performing Jobs */}
        <div className="bg-white rounded-lg shadow-sm p-6">
          <h2 className="text-xl font-bold text-slate-900 mb-4">Tin tuyển dụng hiệu quả</h2>
          
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
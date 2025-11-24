import React, { useState } from 'react';
import { 
  LayoutGrid, 
  Briefcase, 
  Users, 
  FileText, 
  Settings, 
  PlusCircle, 
  Bell, 
  Search,
  MoreVertical,
  Eye,
  MessageSquare
} from 'lucide-react';

const RecruiterDashboard = () => {
  const [activeTab, setActiveTab] = useState('dashboard');

  return (
    <div className="flex h-screen bg-gray-50 font-sans text-slate-800">
      
      {/* --- SIDEBAR --- */}
      <aside className="w-64 bg-white border-r border-gray-200 flex flex-col fixed inset-y-0 left-0 z-10">
        <div className="h-16 flex items-center px-6 border-b border-gray-100">
          <span className="text-2xl font-bold text-blue-600">Tech<span className="text-slate-700">Jobs</span></span>
          <span className="ml-2 text-xs bg-blue-100 text-blue-600 px-2 py-0.5 rounded-full font-medium">HR</span>
        </div>

        <nav className="flex-1 py-6 px-3 space-y-1">
          <NavItem icon={<LayoutGrid size={20}/>} label="Tổng quan" active={activeTab === 'dashboard'} onClick={() => setActiveTab('dashboard')} />
          <NavItem icon={<Briefcase size={20}/>} label="Tin tuyển dụng" active={activeTab === 'jobs'} onClick={() => setActiveTab('jobs')} />
          <NavItem icon={<Users size={20}/>} label="Ứng viên" active={activeTab === 'candidates'} badge={5} onClick={() => setActiveTab('candidates')} />
          <NavItem icon={<FileText size={20}/>} label="Hồ sơ công ty" active={activeTab === 'profile'} onClick={() => setActiveTab('profile')} />
          <div className="pt-4 mt-4 border-t border-gray-100">
             <NavItem icon={<Settings size={20}/>} label="Cài đặt tài khoản" />
          </div>
        </nav>

        <div className="p-4">
            <div className="bg-blue-50 rounded-xl p-4">
                <p className="text-sm text-blue-800 font-medium mb-2">Gói doanh nghiệp</p>
                <div className="w-full bg-blue-200 h-2 rounded-full mb-2">
                    <div className="bg-blue-600 h-2 rounded-full w-3/4"></div>
                </div>
                <p className="text-xs text-blue-600">Còn 12 lượt đăng tin</p>
            </div>
        </div>
      </aside>

      {/* --- MAIN CONTENT --- */}
      <div className="flex-1 ml-64 flex flex-col">
        
        {/* HEADER */}
        <header className="h-16 bg-white border-b border-gray-200 flex items-center justify-between px-8 sticky top-0 z-20">
          <h2 className="text-xl font-bold text-slate-800">Xin chào, HR Manager 👋</h2>
          
          <div className="flex items-center gap-6">
            <button className="flex items-center gap-2 bg-blue-600 hover:bg-blue-700 text-white px-4 py-2 rounded-lg font-medium transition-colors shadow-sm shadow-blue-200">
                <PlusCircle size={18} />
                <span>Đăng tin mới</span>
            </button>
            <div className="h-8 w-[1px] bg-gray-200 mx-2"></div>
            <button className="relative text-gray-500 hover:text-blue-600">
              <Bell size={22} />
              <span className="absolute top-0 right-0 h-2.5 w-2.5 bg-red-500 rounded-full border-2 border-white"></span>
            </button>
            <div className="w-10 h-10 rounded-full bg-gray-200 overflow-hidden border border-gray-200">
                <img src="https://i.pravatar.cc/150?u=a042581f4e29026704d" alt="Profile" />
            </div>
          </div>
        </header>

        {/* BODY */}
        <main className="flex-1 overflow-y-auto p-8">
            
            {/* Quick Stats */}
            <div className="grid grid-cols-1 md:grid-cols-3 gap-6 mb-8">
                <StatCard 
                    title="Tin đang tuyển" 
                    value="4" 
                    icon={<Briefcase className="text-blue-600" />} 
                    subtext="2 tin sắp hết hạn"
                />
                <StatCard 
                    title="CV chưa xem" 
                    value="18" 
                    icon={<Users className="text-purple-600" />} 
                    subtext="+5 hồ sơ hôm nay"
                    highlight
                />
                 <StatCard 
                    title="Lượt xem hồ sơ" 
                    value="1,294" 
                    icon={<Eye className="text-green-600" />} 
                    subtext="Tăng 12% tuần qua"
                />
            </div>

            <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
                {/* Left Column: Recent Applications */}
                <div className="lg:col-span-2 bg-white rounded-xl shadow-sm border border-gray-200 overflow-hidden">
                    <div className="px-6 py-5 border-b border-gray-100 flex justify-between items-center">
                        <h3 className="font-bold text-slate-800">Ứng viên mới ứng tuyển</h3>
                        <a href="#" className="text-sm text-blue-600 font-medium hover:underline">Xem tất cả</a>
                    </div>
                    <div className="overflow-x-auto">
                        <table className="w-full text-left">
                            <thead className="bg-gray-50 text-gray-500 text-xs uppercase font-semibold">
                                <tr>
                                    <th className="px-6 py-3">Ứng viên</th>
                                    <th className="px-6 py-3">Vị trí</th>
                                    <th className="px-6 py-3">Ngày nộp</th>
                                    <th className="px-6 py-3">Hành động</th>
                                </tr>
                            </thead>
                            <tbody className="divide-y divide-gray-100 text-sm">
                                <CandidateRow name="Nguyễn Văn A" role="React Developer" date="10 phút trước" avatar="A" />
                                <CandidateRow name="Trần Thị B" role="Java Senior" date="2 giờ trước" avatar="B" />
                                <CandidateRow name="Lê Hoàng C" role="Tester" date="Hôm qua" avatar="C" />
                                <CandidateRow name="Phạm Văn D" role="React Developer" date="Hôm qua" avatar="D" />
                            </tbody>
                        </table>
                    </div>
                </div>

                {/* Right Column: Active Jobs Mini-List */}
                <div className="bg-white rounded-xl shadow-sm border border-gray-200 flex flex-col">
                     <div className="px-6 py-5 border-b border-gray-100">
                        <h3 className="font-bold text-slate-800">Tin tuyển dụng hiệu quả</h3>
                    </div>
                    <div className="p-4 space-y-4 flex-1">
                        <JobCard title="Senior ReactJS Developer" applicants={42} daysLeft={5} />
                        <JobCard title="Java Spring Boot Inter" applicants={12} daysLeft={12} />
                        <JobCard title="Manual Tester (QC)" applicants={8} daysLeft={2} isUrgent />
                    </div>
                    <div className="p-4 border-t border-gray-100 bg-gray-50 rounded-b-xl text-center">
                         <button className="text-sm font-medium text-slate-600 hover:text-blue-600">Quản lý tất cả tin đăng</button>
                    </div>
                </div>
            </div>

        </main>
      </div>
    </div>
  );
};

// --- Sub Components ---

const NavItem = ({ icon, label, active, badge, onClick }) => (
    <button 
        onClick={onClick}
        className={`w-full flex items-center justify-between px-4 py-3 rounded-lg transition-all mb-1 ${active ? 'bg-blue-50 text-blue-700 font-medium' : 'text-slate-500 hover:bg-gray-100 hover:text-slate-700'}`}
    >
        <div className="flex items-center gap-3">
            {icon}
            <span>{label}</span>
        </div>
        {badge && <span className="bg-red-500 text-white text-[10px] font-bold px-1.5 py-0.5 rounded-full">{badge}</span>}
    </button>
);

const StatCard = ({ title, value, icon, subtext, highlight }) => (
    <div className={`p-6 rounded-xl border ${highlight ? 'bg-blue-600 border-blue-600 text-white' : 'bg-white border-gray-200 text-slate-800'} shadow-sm`}>
        <div className="flex justify-between items-start mb-4">
            <div>
                <p className={`text-sm font-medium ${highlight ? 'text-blue-100' : 'text-slate-500'}`}>{title}</p>
                <h3 className="text-3xl font-bold mt-1">{value}</h3>
            </div>
            <div className={`p-3 rounded-lg ${highlight ? 'bg-white/20 text-white' : 'bg-gray-50'}`}>
                {icon}
            </div>
        </div>
        <p className={`text-xs ${highlight ? 'text-blue-100' : 'text-slate-400'}`}>{subtext}</p>
    </div>
);

const CandidateRow = ({ name, role, date, avatar }) => (
    <tr className="hover:bg-gray-50 transition-colors">
        <td className="px-6 py-4 flex items-center gap-3">
            <div className="w-8 h-8 rounded-full bg-blue-100 text-blue-600 flex items-center justify-center font-bold text-xs">
                {avatar}
            </div>
            <div>
                <p className="font-medium text-slate-800">{name}</p>
                <p className="text-xs text-slate-500">HN, Vietnam</p>
            </div>
        </td>
        <td className="px-6 py-4 text-slate-600">{role}</td>
        <td className="px-6 py-4 text-slate-500 text-xs">{date}</td>
        <td className="px-6 py-4">
            <div className="flex gap-2">
                <button title="Xem CV" className="p-2 text-blue-600 hover:bg-blue-50 rounded-lg"><FileText size={16}/></button>
                <button title="Nhắn tin" className="p-2 text-gray-500 hover:bg-gray-100 rounded-lg"><MessageSquare size={16}/></button>
            </div>
        </td>
    </tr>
);

const JobCard = ({ title, applicants, daysLeft, isUrgent }) => (
    <div className="p-4 border border-gray-100 rounded-lg hover:border-blue-300 transition-colors bg-white shadow-sm group cursor-pointer">
        <div className="flex justify-between items-start mb-2">
            <h4 className="font-semibold text-slate-800 text-sm group-hover:text-blue-600">{title}</h4>
            <MoreVertical size={16} className="text-gray-400" />
        </div>
        <div className="flex justify-between items-center text-xs mt-3">
            <div className="flex gap-3">
                <span className="text-slate-500 bg-slate-100 px-2 py-1 rounded">👥 {applicants} ứng tuyển</span>
            </div>
            <span className={`${isUrgent ? 'text-red-500 font-medium' : 'text-slate-400'}`}>
                {daysLeft} ngày nữa
            </span>
        </div>
    </div>
);

export default RecruiterDashboard;
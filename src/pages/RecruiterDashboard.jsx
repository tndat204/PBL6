// import React, { useState } from 'react';
// import { 
//   LayoutGrid, 
//   Briefcase, 
//   Users, 
//   FileText, 
//   Settings, 
//   PlusCircle, 
//   Bell, 
//   Search,
//   MoreVertical,
//   Eye,
//   MessageSquare
// } from 'lucide-react';

// const RecruiterDashboard = () => {
//   const [activeTab, setActiveTab] = useState('dashboard');

//   return (
//     <div className="flex h-screen bg-gray-50 font-sans text-slate-800">
      
//       {/* --- SIDEBAR --- */}
//       <aside className="w-64 bg-white border-r border-gray-200 flex flex-col fixed inset-y-0 left-0 z-10">
//         <div className="h-16 flex items-center px-6 border-b border-gray-100">
//           <span className="text-2xl font-bold text-blue-600">Tech<span className="text-slate-700">Jobs</span></span>
//           <span className="ml-2 text-xs bg-blue-100 text-blue-600 px-2 py-0.5 rounded-full font-medium">HR</span>
//         </div>

//         <nav className="flex-1 py-6 px-3 space-y-1">
//           <NavItem icon={<LayoutGrid size={20}/>} label="Tổng quan" active={activeTab === 'dashboard'} onClick={() => setActiveTab('dashboard')} />
//           <NavItem icon={<Briefcase size={20}/>} label="Tin tuyển dụng" active={activeTab === 'jobs'} onClick={() => setActiveTab('jobs')} />
//           <NavItem icon={<Users size={20}/>} label="Ứng viên" active={activeTab === 'candidates'} badge={5} onClick={() => setActiveTab('candidates')} />
//           <NavItem icon={<FileText size={20}/>} label="Hồ sơ công ty" active={activeTab === 'profile'} onClick={() => setActiveTab('profile')} />
//           <div className="pt-4 mt-4 border-t border-gray-100">
//              <NavItem icon={<Settings size={20}/>} label="Cài đặt tài khoản" />
//           </div>
//         </nav>

//         <div className="p-4">
//             <div className="bg-blue-50 rounded-xl p-4">
//                 <p className="text-sm text-blue-800 font-medium mb-2">Gói doanh nghiệp</p>
//                 <div className="w-full bg-blue-200 h-2 rounded-full mb-2">
//                     <div className="bg-blue-600 h-2 rounded-full w-3/4"></div>
//                 </div>
//                 <p className="text-xs text-blue-600">Còn 12 lượt đăng tin</p>
//             </div>
//         </div>
//       </aside>

//       {/* --- MAIN CONTENT --- */}
//       <div className="flex-1 ml-64 flex flex-col">
        
//         {/* HEADER */}
//         <header className="h-16 bg-white border-b border-gray-200 flex items-center justify-between px-8 sticky top-0 z-20">
//           <h2 className="text-xl font-bold text-slate-800">Xin chào, HR Manager 👋</h2>
          
//           <div className="flex items-center gap-6">
//             <button className="flex items-center gap-2 bg-blue-600 hover:bg-blue-700 text-white px-4 py-2 rounded-lg font-medium transition-colors shadow-sm shadow-blue-200">
//                 <PlusCircle size={18} />
//                 <span>Đăng tin mới</span>
//             </button>
//             <div className="h-8 w-[1px] bg-gray-200 mx-2"></div>
//             <button className="relative text-gray-500 hover:text-blue-600">
//               <Bell size={22} />
//               <span className="absolute top-0 right-0 h-2.5 w-2.5 bg-red-500 rounded-full border-2 border-white"></span>
//             </button>
//             <div className="w-10 h-10 rounded-full bg-gray-200 overflow-hidden border border-gray-200">
//                 <img src="https://i.pravatar.cc/150?u=a042581f4e29026704d" alt="Profile" />
//             </div>
//           </div>
//         </header>

//         {/* BODY */}
//         <main className="flex-1 overflow-y-auto p-8">
            
//             {/* Quick Stats */}
//             <div className="grid grid-cols-1 md:grid-cols-3 gap-6 mb-8">
//                 <StatCard 
//                     title="Tin đang tuyển" 
//                     value="4" 
//                     icon={<Briefcase className="text-blue-600" />} 
//                     subtext="2 tin sắp hết hạn"
//                 />
//                 <StatCard 
//                     title="CV chưa xem" 
//                     value="18" 
//                     icon={<Users className="text-purple-600" />} 
//                     subtext="+5 hồ sơ hôm nay"
//                     highlight
//                 />
//                  <StatCard 
//                     title="Lượt xem hồ sơ" 
//                     value="1,294" 
//                     icon={<Eye className="text-green-600" />} 
//                     subtext="Tăng 12% tuần qua"
//                 />
//             </div>

//             <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
//                 {/* Left Column: Recent Applications */}
//                 <div className="lg:col-span-2 bg-white rounded-xl shadow-sm border border-gray-200 overflow-hidden">
//                     <div className="px-6 py-5 border-b border-gray-100 flex justify-between items-center">
//                         <h3 className="font-bold text-slate-800">Ứng viên mới ứng tuyển</h3>
//                         <a href="#" className="text-sm text-blue-600 font-medium hover:underline">Xem tất cả</a>
//                     </div>
//                     <div className="overflow-x-auto">
//                         <table className="w-full text-left">
//                             <thead className="bg-gray-50 text-gray-500 text-xs uppercase font-semibold">
//                                 <tr>
//                                     <th className="px-6 py-3">Ứng viên</th>
//                                     <th className="px-6 py-3">Vị trí</th>
//                                     <th className="px-6 py-3">Ngày nộp</th>
//                                     <th className="px-6 py-3">Hành động</th>
//                                 </tr>
//                             </thead>
//                             <tbody className="divide-y divide-gray-100 text-sm">
//                                 <CandidateRow name="Nguyễn Văn A" role="React Developer" date="10 phút trước" avatar="A" />
//                                 <CandidateRow name="Trần Thị B" role="Java Senior" date="2 giờ trước" avatar="B" />
//                                 <CandidateRow name="Lê Hoàng C" role="Tester" date="Hôm qua" avatar="C" />
//                                 <CandidateRow name="Phạm Văn D" role="React Developer" date="Hôm qua" avatar="D" />
//                             </tbody>
//                         </table>
//                     </div>
//                 </div>

//                 {/* Right Column: Active Jobs Mini-List */}
//                 <div className="bg-white rounded-xl shadow-sm border border-gray-200 flex flex-col">
//                      <div className="px-6 py-5 border-b border-gray-100">
//                         <h3 className="font-bold text-slate-800">Tin tuyển dụng hiệu quả</h3>
//                     </div>
//                     <div className="p-4 space-y-4 flex-1">
//                         <JobCard title="Senior ReactJS Developer" applicants={42} daysLeft={5} />
//                         <JobCard title="Java Spring Boot Inter" applicants={12} daysLeft={12} />
//                         <JobCard title="Manual Tester (QC)" applicants={8} daysLeft={2} isUrgent />
//                     </div>
//                     <div className="p-4 border-t border-gray-100 bg-gray-50 rounded-b-xl text-center">
//                          <button className="text-sm font-medium text-slate-600 hover:text-blue-600">Quản lý tất cả tin đăng</button>
//                     </div>
//                 </div>
//             </div>

//         </main>
//       </div>
//     </div>
//   );
// };

// // --- Sub Components ---

// const NavItem = ({ icon, label, active, badge, onClick }) => (
//     <button 
//         onClick={onClick}
//         className={`w-full flex items-center justify-between px-4 py-3 rounded-lg transition-all mb-1 ${active ? 'bg-blue-50 text-blue-700 font-medium' : 'text-slate-500 hover:bg-gray-100 hover:text-slate-700'}`}
//     >
//         <div className="flex items-center gap-3">
//             {icon}
//             <span>{label}</span>
//         </div>
//         {badge && <span className="bg-red-500 text-white text-[10px] font-bold px-1.5 py-0.5 rounded-full">{badge}</span>}
//     </button>
// );

// const StatCard = ({ title, value, icon, subtext, highlight }) => (
//     <div className={`p-6 rounded-xl border ${highlight ? 'bg-blue-600 border-blue-600 text-white' : 'bg-white border-gray-200 text-slate-800'} shadow-sm`}>
//         <div className="flex justify-between items-start mb-4">
//             <div>
//                 <p className={`text-sm font-medium ${highlight ? 'text-blue-100' : 'text-slate-500'}`}>{title}</p>
//                 <h3 className="text-3xl font-bold mt-1">{value}</h3>
//             </div>
//             <div className={`p-3 rounded-lg ${highlight ? 'bg-white/20 text-white' : 'bg-gray-50'}`}>
//                 {icon}
//             </div>
//         </div>
//         <p className={`text-xs ${highlight ? 'text-blue-100' : 'text-slate-400'}`}>{subtext}</p>
//     </div>
// );

// const CandidateRow = ({ name, role, date, avatar }) => (
//     <tr className="hover:bg-gray-50 transition-colors">
//         <td className="px-6 py-4 flex items-center gap-3">
//             <div className="w-8 h-8 rounded-full bg-blue-100 text-blue-600 flex items-center justify-center font-bold text-xs">
//                 {avatar}
//             </div>
//             <div>
//                 <p className="font-medium text-slate-800">{name}</p>
//                 <p className="text-xs text-slate-500">HN, Vietnam</p>
//             </div>
//         </td>
//         <td className="px-6 py-4 text-slate-600">{role}</td>
//         <td className="px-6 py-4 text-slate-500 text-xs">{date}</td>
//         <td className="px-6 py-4">
//             <div className="flex gap-2">
//                 <button title="Xem CV" className="p-2 text-blue-600 hover:bg-blue-50 rounded-lg"><FileText size={16}/></button>
//                 <button title="Nhắn tin" className="p-2 text-gray-500 hover:bg-gray-100 rounded-lg"><MessageSquare size={16}/></button>
//             </div>
//         </td>
//     </tr>
// );

// const JobCard = ({ title, applicants, daysLeft, isUrgent }) => (
//     <div className="p-4 border border-gray-100 rounded-lg hover:border-blue-300 transition-colors bg-white shadow-sm group cursor-pointer">
//         <div className="flex justify-between items-start mb-2">
//             <h4 className="font-semibold text-slate-800 text-sm group-hover:text-blue-600">{title}</h4>
//             <MoreVertical size={16} className="text-gray-400" />
//         </div>
//         <div className="flex justify-between items-center text-xs mt-3">
//             <div className="flex gap-3">
//                 <span className="text-slate-500 bg-slate-100 px-2 py-1 rounded">👥 {applicants} ứng tuyển</span>
//             </div>
//             <span className={`${isUrgent ? 'text-red-500 font-medium' : 'text-slate-400'}`}>
//                 {daysLeft} ngày nữa
//             </span>
//         </div>
//     </div>
// );

// export default RecruiterDashboard;

import React, { useState } from 'react';
import { 
  LayoutDashboard, 
  Briefcase, 
  Users, 
  Settings, 
  Plus, 
  Bell, 
  Search, 
  MoreHorizontal,
  ChevronDown,
  Building,
  FileText
} from 'lucide-react';

// Giả lập màu chủ đạo lấy từ ảnh trang Home của bạn
const BRAND_COLOR = "bg-[#2A437C]"; // Màu xanh Navy

const RecruiterDashboard = () => {
  const [activeTab, setActiveTab] = useState('dashboard');

  return (
    <div className="flex h-screen bg-slate-50 font-sans text-slate-600">
      
      {/* --- SIDEBAR: Tinh tế & Clean --- */}
      <aside className="w-72 bg-white border-r border-slate-100 flex flex-col shadow-[4px_0_24px_rgba(0,0,0,0.02)] z-10">
        <div className="h-20 flex items-center px-8 border-b border-slate-50">
          {/* Logo đồng bộ với trang Home */}
          <h1 className="text-2xl font-bold text-[#2A437C]">IT Job Hunt</h1>
        </div>

        <nav className="flex-1 py-8 px-4 space-y-2">
          <p className="px-4 text-xs font-semibold text-slate-400 uppercase tracking-wider mb-2">Quản lý</p>
          <NavItem icon={<LayoutDashboard size={20} />} label="Tổng quan" active={activeTab === 'dashboard'} onClick={() => setActiveTab('dashboard')} />
          <NavItem icon={<Briefcase size={20} />} label="Tin tuyển dụng" active={activeTab === 'jobs'} onClick={() => setActiveTab('jobs')} />
          <NavItem icon={<Users size={20} />} label="Ứng viên" badge="12" active={activeTab === 'candidates'} onClick={() => setActiveTab('candidates')} />
          
          <p className="px-4 text-xs font-semibold text-slate-400 uppercase tracking-wider mb-2 mt-8">Doanh nghiệp</p>
          <NavItem icon={<Building size={20} />} label="Hồ sơ công ty" active={activeTab === 'company'} onClick={() => setActiveTab('company')} />
          <NavItem icon={<Settings size={20} />} label="Cài đặt" active={activeTab === 'settings'} onClick={() => setActiveTab('settings')} />
        </nav>

        {/* User Mini Profile ở dưới cùng Sidebar */}
        <div className="p-4 border-t border-slate-50">
          <div className="flex items-center gap-3 p-3 rounded-xl hover:bg-slate-50 cursor-pointer transition-colors">
            <div className="w-10 h-10 rounded-full bg-indigo-100 flex items-center justify-center text-[#2A437C] font-bold">T</div>
            <div className="flex-1">
              <p className="text-sm font-semibold text-slate-800">thchanh12</p>
              <p className="text-xs text-slate-400">HR Manager</p>
            </div>
            <ChevronDown size={16} />
          </div>
        </div>
      </aside>

      {/* --- MAIN CONTENT --- */}
      <div className="flex-1 flex flex-col overflow-hidden">
        
        {/* HEADER: Đơn giản, focus vào hành động */}
        <header className="h-20 flex items-center justify-between px-10 bg-white/80 backdrop-blur-sm sticky top-0 z-0">
          <div>
            <h2 className="text-xl font-bold text-slate-800">Dashboard</h2>
            <p className="text-sm text-slate-400">Chào mừng trở lại, hôm nay có gì mới?</p>
          </div>
          
          <div className="flex items-center gap-6">
            <div className="relative">
                <Search className="absolute left-3 top-1/2 -translate-y-1/2 text-slate-300" size={18} />
                <input 
                    type="text" 
                    placeholder="Tìm ứng viên, Job..." 
                    className="pl-10 pr-4 py-2.5 rounded-full bg-slate-100 text-sm focus:outline-none focus:ring-2 focus:ring-[#2A437C]/20 w-64 transition-all"
                />
            </div>
            <button className="relative p-2 text-slate-400 hover:text-[#2A437C] transition-colors">
              <Bell size={22} />
              <span className="absolute top-1.5 right-1.5 w-2 h-2 bg-red-500 rounded-full border border-white"></span>
            </button>
            <button className={`${BRAND_COLOR} text-white px-5 py-2.5 rounded-lg text-sm font-medium flex items-center gap-2 shadow-lg shadow-blue-900/20 hover:shadow-blue-900/30 transition-all transform active:scale-95`}>
                <Plus size={18} />
                <span>Đăng tin mới</span>
            </button>
          </div>
        </header>

        {/* SCROLLABLE CONTENT */}
        <main className="flex-1 overflow-y-auto p-10">
            
            {/* 1. STATS SECTION (Các chỉ số quan trọng) */}
            <div className="grid grid-cols-1 md:grid-cols-4 gap-6 mb-10">
                <StatCard title="Tin đang hiển thị" value="08" icon={<Briefcase />} trend="+2" />
                <StatCard title="Hồ sơ mới nhận" value="142" icon={<FileText />} trend="+12%" highlight />
                <StatCard title="Lượt phỏng vấn" value="12" icon={<Users />} trend="Hôm nay" />
                <StatCard title="Tỉ lệ phản hồi" value="85%" icon={<Settings />} subtext="Rất tốt" />
            </div>

            {/* 2. SPLIT SECTION */}
            <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
                
                {/* Left: Ứng viên mới nhất (Chiếm 2/3) */}
                <div className="lg:col-span-2 space-y-6">
                    <div className="flex items-center justify-between">
                        <h3 className="font-bold text-lg text-slate-800">Ứng viên cần duyệt</h3>
                        <a href="#" className="text-sm font-medium text-[#2A437C] hover:underline">Xem tất cả</a>
                    </div>

                    <div className="bg-white rounded-2xl shadow-sm border border-slate-100 overflow-hidden">
                        {/* Candidate Item 1 */}
                        <CandidateItem 
                            name="Nguyễn Văn A" 
                            role="Senior ReactJS Developer" 
                            exp="4 năm kinh nghiệm"
                            applied="Vừa xong"
                            tags={['ReactJS', 'Tailwind', 'NodeJS']}
                        />
                        {/* Candidate Item 2 */}
                        <CandidateItem 
                            name="Trần Thị B" 
                            role="Java Spring Boot Backend" 
                            exp="2 năm kinh nghiệm"
                            applied="2 giờ trước"
                            tags={['Java', 'Spring Boot', 'MySQL']}
                        />
                         {/* Candidate Item 3 */}
                        <CandidateItem 
                            name="Lê Hoàng C" 
                            role="UI/UX Designer" 
                            exp="3 năm kinh nghiệm"
                            applied="Hôm qua"
                            tags={['Figma', 'Adobe XD']}
                            isLast
                        />
                    </div>
                </div>

                {/* Right: Tin tuyển dụng & Action (Chiếm 1/3) */}
                <div className="space-y-6">
                    <div className="flex items-center justify-between">
                        <h3 className="font-bold text-lg text-slate-800">Job hiệu quả nhất</h3>
                    </div>
                    
                    {/* Job List Minimal */}
                    <div className="bg-white rounded-2xl shadow-sm border border-slate-100 p-2">
                        <JobMiniItem title="Frontend Developer" views="1,204" applies="45" />
                        <JobMiniItem title="Backend Java" views="892" applies="21" />
                        <JobMiniItem title="Tester (Manual)" views="500" applies="32" />
                    </div>

                    {/* Promo Banner / Upgrade */}
                    <div className="bg-gradient-to-br from-[#2A437C] to-[#1e3a8a] rounded-2xl p-6 text-white text-center shadow-xl shadow-blue-900/20">
                        <div className="w-12 h-12 bg-white/20 rounded-full flex items-center justify-center mx-auto mb-4 text-2xl">🚀</div>
                        <h4 className="font-bold text-lg mb-2">Đẩy tin tuyển dụng?</h4>
                        <p className="text-blue-100 text-sm mb-4">Tiếp cận nhiều ứng viên hơn với gói Premium.</p>
                        <button className="w-full py-2 bg-white text-[#2A437C] font-bold rounded-lg text-sm hover:bg-blue-50 transition-colors">Nâng cấp ngay</button>
                    </div>
                </div>
            </div>

        </main>
      </div>
    </div>
  );
};

// --- Sub-components để code gọn và tái sử dụng ---

const NavItem = ({ icon, label, active, badge, onClick }) => (
    <button 
        onClick={onClick}
        className={`w-full flex items-center justify-between px-4 py-3 rounded-xl transition-all mb-1 group ${
            active 
            ? 'bg-[#2A437C]/5 text-[#2A437C] font-semibold' 
            : 'text-slate-500 hover:bg-slate-50 hover:text-slate-700'
        }`}
    >
        <div className="flex items-center gap-3">
            <span className={`${active ? 'text-[#2A437C]' : 'text-slate-400 group-hover:text-slate-600'}`}>{icon}</span>
            <span>{label}</span>
        </div>
        {badge && <span className="bg-red-50 text-red-600 text-[10px] font-bold px-2 py-0.5 rounded-full">{badge}</span>}
    </button>
);

const StatCard = ({ title, value, icon, trend, subtext, highlight }) => (
    <div className="bg-white p-6 rounded-2xl shadow-[0_2px_10px_rgba(0,0,0,0.03)] border border-slate-100 hover:-translate-y-1 transition-transform duration-300">
        <div className="flex justify-between items-start mb-4">
            <div className={`p-3 rounded-xl ${highlight ? 'bg-blue-100 text-blue-700' : 'bg-slate-50 text-slate-500'}`}>
                {icon}
            </div>
            {trend && <span className="text-xs font-bold text-green-600 bg-green-50 px-2 py-1 rounded-full">{trend}</span>}
        </div>
        <h3 className="text-3xl font-bold text-slate-800 mb-1">{value}</h3>
        <p className="text-sm text-slate-400">{title}</p>
        {subtext && <p className="text-xs text-slate-400 mt-2">{subtext}</p>}
    </div>
);

const CandidateItem = ({ name, role, exp, applied, tags, isLast }) => (
    <div className={`p-5 flex items-center justify-between hover:bg-slate-50 transition-colors group ${!isLast && 'border-b border-slate-50'}`}>
        <div className="flex items-center gap-4">
            <div className="w-12 h-12 rounded-full bg-slate-100 flex items-center justify-center text-slate-500 font-bold text-lg">
                {name.charAt(0)}
            </div>
            <div>
                <h4 className="font-bold text-slate-800 group-hover:text-[#2A437C] transition-colors">{name}</h4>
                <p className="text-sm text-slate-500">{role} • <span className="text-slate-400">{exp}</span></p>
                <div className="flex gap-2 mt-2">
                    {tags.map((tag, i) => (
                        <span key={i} className="px-2 py-0.5 bg-slate-100 text-slate-500 text-[10px] rounded font-medium">{tag}</span>
                    ))}
                </div>
            </div>
        </div>
        <div className="text-right">
            <p className="text-xs text-slate-400 mb-2">{applied}</p>
            <button className="p-2 text-slate-400 hover:bg-white hover:shadow-sm hover:text-[#2A437C] rounded-lg transition-all border border-transparent hover:border-slate-100">
                <MoreHorizontal size={18} />
            </button>
        </div>
    </div>
);

const JobMiniItem = ({ title, views, applies }) => (
    <div className="p-4 rounded-xl hover:bg-slate-50 transition-colors flex items-center justify-between group cursor-pointer">
        <div>
            <h4 className="font-semibold text-slate-700 text-sm group-hover:text-[#2A437C]">{title}</h4>
            <div className="flex items-center gap-3 mt-1 text-xs text-slate-400">
                <span className="flex items-center gap-1"><Users size={12}/> {applies}</span>
                <span className="flex items-center gap-1"><Search size={12}/> {views}</span>
            </div>
        </div>
        <ChevronDown size={16} className="-rotate-90 text-slate-300 group-hover:text-[#2A437C] transition-transform group-hover:translate-x-1" />
    </div>
);

export default RecruiterDashboard;
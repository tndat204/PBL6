import React, { useState } from 'react';
import {
    LayoutDashboard,
    Users,
    Building2,
    Briefcase,
    Star,
    Tags,
    LogOut,
    Bell,
    Shield
} from 'lucide-react';
import { useNavigate, useLocation, Outlet } from 'react-router-dom';

const AdminLayout = () => {
    const [isSidebarOpen, setSidebarOpen] = useState(true);
    const navigate = useNavigate();
    const location = useLocation();

    const menuItems = [
        { name: 'Tổng quan', icon: <LayoutDashboard size={20} />, path: '/admin' },
        { name: 'Quản lý người dùng', icon: <Users size={20} />, path: '/admin/users' },
        { name: 'Quản lý công ty', icon: <Building2 size={20} />, path: '/admin/companies' },
        { name: 'Tin tuyển dụng', icon: <Briefcase size={20} />, path: '/admin/jobs' },
        { name: 'Đánh giá & Review', icon: <Star size={20} />, path: '/admin/reviews' },
        { name: 'Kỹ năng & Danh mục', icon: <Tags size={20} />, path: '/admin/categories' },
        { name: 'Vai trò & Quyền hạn', icon: <Shield size={20} />, path: '/admin/permissions' },
    ];

    const handleLogout = () => {
        localStorage.removeItem('token');
        navigate('/login');
    };

    return (
        <div className="flex h-screen bg-gray-100 font-sans">
            {/* --- SIDEBAR --- */}
            <aside className={`bg-slate-900 text-white transition-all duration-300 ${isSidebarOpen ? 'w-64' : 'w-20'} flex flex-col fixed inset-y-0 left-0 z-20`}>
                <div className="h-16 flex items-center justify-center border-b border-slate-700">
                    <h1 className={`font-bold text-xl ${!isSidebarOpen && 'hidden'}`}>IT JOBS ADMIN</h1>
                    {!isSidebarOpen && <span className="font-bold text-xl">IT</span>}
                </div>

                <nav className="flex-1 py-6">
                    <ul className="space-y-2 px-3">
                        {menuItems.map((item, index) => {
                            const isActive = location.pathname === item.path;
                            return (
                                <li key={index}>
                                    <button
                                        onClick={() => navigate(item.path)}
                                        className={`w-full flex items-center gap-4 px-4 py-3 rounded-lg transition-colors ${isActive ? 'bg-blue-600 text-white' : 'text-slate-400 hover:bg-slate-800 hover:text-white'}`}
                                    >
                                        {item.icon}
                                        <span className={`${!isSidebarOpen && 'hidden'}`}>{item.name}</span>
                                    </button>
                                </li>
                            );
                        })}
                    </ul>
                </nav>

                <div className="p-4 border-t border-slate-700">
                    <button
                        onClick={handleLogout}
                        className="flex items-center gap-4 px-4 py-2 text-red-400 hover:text-red-300 transition-colors w-full"
                    >
                        <LogOut size={20} />
                        <span className={`${!isSidebarOpen && 'hidden'}`}>Đăng xuất</span>
                    </button>
                </div>
            </aside>

            {/* --- MAIN CONTENT --- */}
            <div className={`flex-1 flex flex-col overflow-hidden transition-all duration-300 ${isSidebarOpen ? 'ml-64' : 'ml-20'}`}>

                {/* HEADER */}
                <header className="h-16 bg-white shadow-sm flex items-center justify-between px-6 z-10">
                    <div className="flex items-center gap-4">
                        <button onClick={() => setSidebarOpen(!isSidebarOpen)} className="text-gray-500 hover:text-gray-700 focus:outline-none">
                            <svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M4 6h16M4 12h16M4 18h16" /></svg>
                        </button>
                        <h2 className="text-xl font-semibold text-gray-800">
                            {menuItems.find(item => item.path === location.pathname)?.name || 'Admin Dashboard'}
                        </h2>
                    </div>

                    <div className="flex items-center gap-6">
                        <button className="relative text-gray-500 hover:text-blue-600">
                            <Bell size={24} />
                            <span className="absolute -top-1 -right-1 h-4 w-4 bg-red-500 rounded-full text-[10px] text-white flex items-center justify-center">3</span>
                        </button>
                        <div className="flex items-center gap-3 cursor-pointer">
                            <div className="w-8 h-8 rounded-full bg-blue-500 flex items-center justify-center text-white font-bold">A</div>
                            <span className="text-sm font-medium text-gray-700">Admin User</span>
                        </div>
                    </div>
                </header>

                {/* PAGE CONTENT */}
                <main className="flex-1 overflow-y-auto p-6 bg-gray-100">
                    <Outlet />
                </main>
            </div>
        </div>
    );
};

export default AdminLayout;

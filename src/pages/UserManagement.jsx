import React, { useState, useEffect } from 'react';
import {
    LayoutDashboard,
    Users,
    Building2,
    Briefcase,
    Star,
    Tags,
    LogOut,
    Bell,
    Search,
    Filter,
    MoreVertical,
    Edit,
    Trash2,
    Ban,
    CheckCircle,
    X,
    Mail,
    Calendar,
    Shield,
    UserCheck,
    UserX,
    ChevronLeft,
    ChevronRight,
    Loader2,
    UserPlus,
    Phone,
    MapPin,
    Globe
} from 'lucide-react';
import userService from '../services/userService';
import Toast from '../components/Toast';
import CreateUserModal from '../components/CreateUserModal';
import ConfirmModal from '../components/ConfirmModal';

const UserManagement = () => {
    const [isSidebarOpen, setSidebarOpen] = useState(true);
    const [searchQuery, setSearchQuery] = useState('');
    const [roleFilter, setRoleFilter] = useState('ALL');
    const [statusFilter, setStatusFilter] = useState('ALL');
    const [currentPage, setCurrentPage] = useState(1);
    const [itemsPerPage, setItemsPerPage] = useState(10);
    const [selectedUser, setSelectedUser] = useState(null);
    const [showUserModal, setShowUserModal] = useState(false);
    const [showCreateModal, setShowCreateModal] = useState(false);
    const [toast, setToast] = useState(null);
    const [confirmModal, setConfirmModal] = useState({
        isOpen: false,
        userId: null,
        title: '',
        message: ''
    });

    const showToast = (message, type = 'info') => {
        setToast({ message, type, id: Date.now() });
    };

    // API state
    const [users, setUsers] = useState([]);
    const [loading, setLoading] = useState(true);
    const [error, setError] = useState(null);

    // Fetch users from API
    useEffect(() => {
        fetchUsers();
    }, []);

    const fetchUsers = async () => {
        try {
            setLoading(true);
            setError(null);

            // Check if token exists
            const token = localStorage.getItem('token');
            if (!token) {
                setError('Bạn chưa đăng nhập. Vui lòng đăng nhập để tiếp tục.');
                setTimeout(() => {
                    window.location.href = '/login';
                }, 2000);
                return;
            }

            const response = await userService.getAllUsers();
            console.log('Fetched users response:', response);

            // Check for successful response (code 200 or code 0)
            if ((response.code === 200 || response.code === 0) && response.result) {
                // Transform backend data to frontend format
                const transformedUsers = userService.transformUsers(response.result);
                console.log('Transformed users:', transformedUsers);
                setUsers(transformedUsers);
            } else if (response.code === 1004 || response.code === 401) {
                // Authentication error
                setError('Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.');
                setTimeout(() => {
                    localStorage.removeItem('token');
                    window.location.href = '/login';
                }, 2000);
            } else {
                setError(response.message || 'Không thể tải danh sách người dùng.');
            }
        } catch (err) {
            console.error('Error fetching users:', err);

            // Check if it's a network error
            if (err.message.includes('Failed to fetch') || err.message.includes('NetworkError')) {
                setError('Không thể kết nối đến server. Vui lòng kiểm tra kết nối mạng hoặc đảm bảo backend đang chạy trên port 8082.');
            } else if (err.message.includes('401')) {
                setError('Phiên đăng nhập đã hết hạn. Đang chuyển đến trang đăng nhập...');
                setTimeout(() => {
                    localStorage.removeItem('token');
                    window.location.href = '/login';
                }, 2000);
            } else {
                setError('Không thể tải danh sách người dùng. Vui lòng thử lại.');
            }
        } finally {
            setLoading(false);
        }
    };

    // Filter users based on search and filters
    const filteredUsers = users.filter(user => {
        const matchesSearch = user.name.toLowerCase().includes(searchQuery.toLowerCase()) ||
            user.email.toLowerCase().includes(searchQuery.toLowerCase());
        const matchesRole = roleFilter === 'ALL' || user.role === roleFilter;
        const matchesStatus = statusFilter === 'ALL' || user.status === statusFilter;
        return matchesSearch && matchesRole && matchesStatus;
    });

    // Pagination
    const totalPages = Math.ceil(filteredUsers.length / itemsPerPage);
    const startIndex = (currentPage - 1) * itemsPerPage;
    const paginatedUsers = filteredUsers.slice(startIndex, startIndex + itemsPerPage);

    // Statistics
    const stats = {
        totalUsers: users.length,
        activeUsers: users.filter(u => u.status === 'Active').length,
        bannedUsers: users.filter(u => u.status === 'Banned').length,
        usersByRole: {
            USER: users.filter(u => u.role === 'USER').length,
            RECRUITER: users.filter(u => u.role === 'RECRUITER').length,
            ADMIN: users.filter(u => u.role === 'ADMIN').length,
        }
    };

    // Menu Items
    const menuItems = [
        { name: 'Tổng quan', icon: <LayoutDashboard size={20} />, active: false, path: '/admin' },
        { name: 'Quản lý người dùng', icon: <Users size={20} />, active: true, path: '/admin/users' },
        { name: 'Quản lý công ty', icon: <Building2 size={20} />, active: false },
        { name: 'Tin tuyển dụng', icon: <Briefcase size={20} />, active: false },
        { name: 'Đánh giá & Review', icon: <Star size={20} />, active: false },
        { name: 'Kỹ năng & Danh mục', icon: <Tags size={20} />, active: false },
    ];

    const handleViewUser = (user) => {
        setSelectedUser(user);
        setShowUserModal(true);
    };

    const handleBanUser = async (userId) => {
        try {
            const user = users.find(u => u.id === userId);
            if (!user) return;

            const newStatus = !user.isEnabled;
            await userService.toggleUserStatus(userId, newStatus);

            // Refresh user list
            await fetchUsers();
            showToast(`Người dùng đã được ${newStatus ? 'kích hoạt' : 'cấm'} thành công!`, 'success');
        } catch (error) {
            console.error('Error toggling user status:', error);
            showToast('Không thể thay đổi trạng thái người dùng. Vui lòng thử lại.', 'error');
        }
    };

    const handleDeleteClick = (userId) => {
        setConfirmModal({
            isOpen: true,
            userId: userId,
            title: 'Xóa người dùng',
            message: 'Bạn có chắc chắn muốn xóa người dùng này? Hành động này không thể hoàn tác.'
        });
    };

    const handleConfirmDelete = async () => {
        if (!confirmModal.userId) return;

        try {
            await userService.deleteUser(confirmModal.userId);
            // Refresh user list
            await fetchUsers();
            showToast('Người dùng đã được xóa thành công!', 'success');
        } catch (error) {
            console.error('Error deleting user:', error);
            showToast('Không thể xóa người dùng. Vui lòng thử lại.', 'error');
        } finally {
            setConfirmModal(prev => ({ ...prev, isOpen: false, userId: null }));
        }
    };

    const handleCreateUser = async (userData) => {
        try {
            console.log('user sent: ', userData)
            const response = await userService.createUser(userData);
            if (response.code === 200 || response.code === 0) {
                // Refresh user list
                await fetchUsers();
                setShowCreateModal(false);
                showToast('Người dùng đã được tạo thành công!', 'success');
            } else {
                throw new Error(response.message || 'Không thể tạo người dùng.');
            }
        } catch (error) {
            console.error('Error creating user:', error);
            throw error;
        }
    };

    return (
        <div className="h-full flex flex-col">
            {/* CONTENT BODY */}
            <div className="flex-1 overflow-y-auto">

                {/* Loading State */}
                {loading && (
                    <div className="flex items-center justify-center h-64">
                        <Loader2 className="animate-spin text-blue-600" size={48} />
                        <span className="ml-3 text-gray-600">Đang tải dữ liệu...</span>
                    </div>
                )}

                {/* Error State */}
                {error && (
                    <div className="bg-red-50 border border-red-200 rounded-lg p-4 mb-6">
                        <p className="text-red-800 font-medium">❌ {error}</p>
                        <button
                            onClick={fetchUsers}
                            className="mt-2 px-4 py-2 bg-red-600 text-white rounded-lg hover:bg-red-700 transition-colors"
                        >
                            Thử lại
                        </button>
                    </div>
                )}

                {/* Content - only show when not loading */}
                {!loading && !error && (
                    <>
                        {/* Stats Grid */}
                        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6 mb-8">
                            <StatCard title="Tổng người dùng" value={stats.totalUsers} color="blue" icon={<Users />} />
                            <StatCard title="Đang hoạt động" value={stats.activeUsers} color="green" icon={<UserCheck />} />
                            <StatCard title="Bị cấm" value={stats.bannedUsers} color="red" icon={<UserX />} />
                        </div>

                        {/* Role Distribution */}
                        <div className="grid grid-cols-1 md:grid-cols-3 gap-6 mb-8">
                            <RoleCard title="Ứng viên" count={stats.usersByRole.USER} gradient="blue" />
                            <RoleCard title="Nhà tuyển dụng" count={stats.usersByRole.RECRUITER} gradient="blue" />
                            <RoleCard title="Quản trị viên" count={stats.usersByRole.ADMIN} gradient="blue" />
                        </div>
                    </>
                )}

                {/* User Table - only show when not loading */}
                {!loading && !error && (
                    <div className="bg-white rounded-xl shadow-sm border border-gray-100 overflow-hidden">
                        {/* Table Header with Filters */}
                        <div className="p-6 border-b border-gray-100">
                            <div className="flex flex-col md:flex-row md:items-center md:justify-between gap-4">
                                <div className="flex items-center gap-4">
                                    <h3 className="font-bold text-gray-800">Danh sách người dùng</h3>
                                    <button
                                        onClick={() => setShowCreateModal(true)}
                                        className="
                                                flex items-center gap-2 px-5 py-2.5 
                                                bg-gradient-to-r from-blue-500 via-indigo-500 to-blue-600
                                                text-white font-semibold text-sm
                                                rounded-xl shadow-md 
                                                hover:shadow-lg hover:scale-[1.03]
                                                active:scale-95
                                                transition-all duration-300
                                            "
                                    >
                                        <UserPlus size={18} className="drop-shadow-sm" />
                                        <span>Tạo người dùng</span>
                                    </button>

                                </div>

                                <div className="flex flex-col md:flex-row gap-3">
                                    {/* Search */}
                                    <div className="relative">
                                        <Search className="absolute left-3 top-1/2 -translate-y-1/2 text-gray-400" size={18} />
                                        <input
                                            type="text"
                                            placeholder="Tìm kiếm tên, email..."
                                            className="pl-10 pr-4 py-2 rounded-lg bg-gray-50 text-sm focus:outline-none focus:ring-2 focus:ring-blue-500 w-full md:w-64"
                                            value={searchQuery}
                                            onChange={(e) => setSearchQuery(e.target.value)}
                                        />
                                    </div>

                                    {/* Role Filter */}
                                    <select
                                        className="px-4 py-2 rounded-lg bg-gray-50 text-sm focus:outline-none focus:ring-2 focus:ring-blue-500"
                                        value={roleFilter}
                                        onChange={(e) => setRoleFilter(e.target.value)}
                                    >
                                        <option value="ALL">Tất cả vai trò</option>
                                        <option value="USER">Ứng viên</option>
                                        <option value="RECRUITER">Nhà tuyển dụng</option>
                                        <option value="ADMIN">Quản trị viên</option>
                                    </select>

                                    {/* Status Filter */}
                                    <select
                                        className="px-4 py-2 rounded-lg bg-gray-50 text-sm focus:outline-none focus:ring-2 focus:ring-blue-500"
                                        value={statusFilter}
                                        onChange={(e) => setStatusFilter(e.target.value)}
                                    >
                                        <option value="ALL">Tất cả trạng thái</option>
                                        <option value="Active">Hoạt động</option>
                                        <option value="Banned">Bị cấm</option>
                                    </select>
                                </div>
                            </div>
                        </div>

                        {/* Table */}
                        <div className="overflow-x-auto">
                            <table className="w-full text-left border-collapse">
                                <thead className="bg-gray-50 text-gray-600 uppercase text-xs font-semibold">
                                    <tr>
                                        <th className="px-6 py-4">Người dùng</th>
                                        <th className="px-6 py-4">Email</th>
                                        <th className="px-6 py-4">Vai trò</th>
                                        <th className="px-6 py-4">Trạng thái</th>
                                        <th className="px-6 py-4">Hành động</th>
                                    </tr>
                                </thead>
                                <tbody className="divide-y divide-gray-100 text-sm text-gray-700">
                                    {paginatedUsers.map((user) => (
                                        <UserRow
                                            key={user.id}
                                            user={user}
                                            onView={handleViewUser}
                                            onBan={handleBanUser}
                                            onDelete={handleDeleteClick}
                                        />
                                    ))}
                                </tbody>
                            </table>
                        </div>

                        {/* Pagination */}
                        <div className="p-4 border-t border-gray-100 flex items-center justify-between">
                            <div className="flex items-center gap-2 text-sm text-gray-600">
                                <span>Hiển thị</span>
                                <select
                                    className="px-2 py-1 rounded border border-gray-300 focus:outline-none focus:ring-2 focus:ring-blue-500"
                                    value={itemsPerPage}
                                    onChange={(e) => {
                                        setItemsPerPage(Number(e.target.value));
                                        setCurrentPage(1);
                                    }}
                                >
                                    <option value={10}>10</option>
                                    <option value={25}>25</option>
                                    <option value={50}>50</option>
                                </select>
                                <span>trên {filteredUsers.length} kết quả</span>
                            </div>

                            <div className="flex items-center gap-2">
                                <button
                                    onClick={() => setCurrentPage(prev => Math.max(1, prev - 1))}
                                    disabled={currentPage === 1}
                                    className="p-2 rounded hover:bg-gray-100 disabled:opacity-50 disabled:cursor-not-allowed"
                                >
                                    <ChevronLeft size={20} />
                                </button>
                                <span className="text-sm text-gray-600">
                                    Trang {currentPage} / {totalPages}
                                </span>
                                <button
                                    onClick={() => setCurrentPage(prev => Math.min(totalPages, prev + 1))}
                                    disabled={currentPage === totalPages}
                                    className="p-2 rounded hover:bg-gray-100 disabled:opacity-50 disabled:cursor-not-allowed"
                                >
                                    <ChevronRight size={20} />
                                </button>
                            </div>
                        </div>
                    </div>
                )}

                {/* User Detail Modal */}
                {showUserModal && selectedUser && (
                    <UserDetailModal
                        user={selectedUser}
                        onClose={() => setShowUserModal(false)}
                    />
                )}

                {/* Create User Modal */}
                {showCreateModal && (
                    <CreateUserModal
                        onClose={() => setShowCreateModal(false)}
                        onCreate={handleCreateUser}
                    />
                )}

                <ConfirmModal
                    isOpen={confirmModal.isOpen}
                    onClose={() => setConfirmModal(prev => ({ ...prev, isOpen: false }))}
                    onConfirm={handleConfirmDelete}
                    title={confirmModal.title}
                    message={confirmModal.message}
                />

                {/* Toast Notification */}
                {toast && (
                    <Toast
                        message={toast.message}
                        type={toast.type}
                        onClose={() => setToast(null)}
                    />
                )}
            </div>
        </div>
    );
};

// --- Sub Components ---

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
        {trend && (
            <div className="mt-4 flex items-center text-sm">
                <span className="text-green-500 font-medium">{trend}</span>
                <span className="text-gray-400 ml-2">so với tháng trước</span>
            </div>
        )}
    </div>
);

const RoleCard = ({ title, count, gradient = "blue" }) => {
    const gradients = {
        blue: "from-indigo-400 via-blue-500 to-cyan-500",
        purple: "from-purple-500 via-violet-500 to-fuchsia-500",
        green: "from-emerald-400 via-green-500 to-lime-500",
        orange: "from-amber-400 via-orange-500 to-red-500",
        pink: "from-rose-400 via-pink-500 to-fuchsia-500",
    };

    return (
        <div className={`
      p-6 rounded-2xl shadow-lg bg-gradient-to-br 
      ${gradients[gradient]}
      text-white transition-all duration-300 
      hover:scale-105 hover:shadow-xl backdrop-blur-sm
    `}>
            <p className="text-sm font-medium opacity-90 tracking-wide">{title}</p>
            <h3 className="text-4xl font-extrabold mt-2 drop-shadow">{count}</h3>
        </div>
    );
};


const UserRow = ({ user, onView, onBan, onDelete }) => {
    const getRoleBadge = (role) => {
        const styles = {
            USER: 'bg-blue-100 text-blue-700',
            RECRUITER: 'bg-purple-100 text-purple-700',
            ADMIN: 'bg-red-100 text-red-700'
        };
        const labels = {
            USER: 'Ứng viên',
            RECRUITER: 'NTD',
            ADMIN: 'Admin'
        };
        return <span className={`px-3 py-1 rounded-full text-xs font-medium ${styles[role]}`}>{labels[role]}</span>;
    };

    const getStatusBadge = (status) => {
        return status === 'Active'
            ? <span className="px-3 py-1 rounded-full text-xs font-medium bg-green-100 text-green-700">Hoạt động</span>
            : <span className="px-3 py-1 rounded-full text-xs font-medium bg-red-100 text-red-700">Bị cấm</span>;
    };

    return (
        <tr className="hover:bg-gray-50 transition-colors">
            <td className="px-6 py-4">
                <div className="flex items-center gap-3">
                    <div className="w-10 h-10 rounded-full bg-gradient-to-br from-blue-400 to-blue-600 flex items-center justify-center text-white font-bold">
                        {user.avatar}
                    </div>
                    <div>
                        <p className="font-medium text-gray-800">{user.name}</p>
                        <p className="text-xs text-gray-500">{user.location}</p>
                    </div>
                </div>
            </td>
            <td className="px-6 py-4 text-gray-600">{user.email}</td>
            <td className="px-6 py-4">{getRoleBadge(user.role)}</td>
            <td className="px-6 py-4">{getStatusBadge(user.status)}</td>
            <td className="px-6 py-4">
                <div className="flex gap-2">
                    <button
                        onClick={() => onView(user)}
                        className="p-2 text-blue-600 hover:bg-blue-50 rounded-lg transition-colors"
                        title="Xem chi tiết"
                    >
                        <Search size={16} />
                    </button>
                    {user.role !== 'ADMIN' && (
                        <button
                            onClick={() => onBan(user.id)}
                            className={`p-2 ${user.status === 'Active' ? 'text-orange-600 hover:bg-orange-50' : 'text-green-600 hover:bg-green-50'} rounded-lg transition-colors`}
                            title={user.status === 'Active' ? 'Cấm người dùng' : 'Bỏ cấm'}
                        >
                            {user.status === 'Active' ? <Ban size={16} /> : <CheckCircle size={16} />}
                        </button>
                    )}
                    {user.role !== 'ADMIN' && (
                        <button
                            onClick={() => onDelete(user.id)}
                            className="p-2 text-red-600 hover:bg-red-50 rounded-lg transition-colors"
                            title="Xóa người dùng"
                        >
                            <Trash2 size={18} />
                        </button>
                    )}
                </div>
            </td>
        </tr>
    );
};

const UserDetailModal = ({ user, onClose }) => (
    <div className="fixed inset-0 bg-black/60 backdrop-blur-sm flex items-center justify-center z-50 p-4 animate-fade-in">
        <div className="bg-white rounded-3xl shadow-2xl w-full max-w-md overflow-hidden transform transition-all animate-scale-in relative">

            {/* Decorative Background Pattern */}
            <div className="absolute top-0 left-0 w-full h-32 bg-gradient-to-r from-blue-600 to-purple-600 opacity-10"></div>

            {/* Close Button */}
            <button
                onClick={onClose}
                className="absolute top-4 right-4 p-2 bg-white/80 hover:bg-white rounded-full text-gray-500 hover:text-gray-800 transition-all shadow-sm z-10"
            >
                <X size={20} />
            </button>

            {/* Modal Body */}
            <div className="px-8 pb-8 pt-12 relative">

                {/* Profile Header */}
                <div className="flex flex-col items-center mb-8">
                    <div className="w-24 h-24 rounded-full bg-gradient-to-br from-blue-500 to-purple-600 flex items-center justify-center text-white font-bold text-3xl shadow-xl border-4 border-white mb-4">
                        {user.avatar}
                    </div>
                    <h4 className="text-2xl font-bold text-gray-900 text-center">{user.name}</h4>
                    <p className="text-gray-500 text-sm mb-4">{user.email}</p>

                    <div className="flex gap-2">
                        <span className={`px-3 py-1 rounded-full text-xs font-semibold tracking-wide ${user.role === 'USER' ? 'bg-blue-100 text-blue-700' :
                            user.role === 'RECRUITER' ? 'bg-purple-100 text-purple-700' :
                                'bg-red-100 text-red-700'
                            }`}>
                            {user.role === 'USER' ? 'Ứng viên' : user.role === 'RECRUITER' ? 'Nhà tuyển dụng' : 'Quản trị viên'}
                        </span>
                        <span className={`px-3 py-1 rounded-full text-xs font-semibold tracking-wide ${user.status === 'Active' ? 'bg-green-100 text-green-700' : 'bg-red-100 text-red-700'
                            }`}>
                            {user.status === 'Active' ? 'Hoạt động' : 'Bị cấm'}
                        </span>
                    </div>
                </div>

                {/* Info Grid */}
                <div className="bg-gray-50 rounded-2xl p-6 space-y-5 mb-8">
                    <InfoRow icon={<Mail className="text-blue-500" size={18} />} label="Email" value={user.email} />
                    <InfoRow icon={<Phone className="text-green-500" size={18} />} label="Số điện thoại" value={user.phone} />
                    <InfoRow icon={<MapPin className="text-red-500" size={18} />} label="Địa chỉ" value={user.address} />
                </div>

                {/* Actions */}
                <button className="w-full py-3 bg-slate-900 text-white rounded-xl font-semibold hover:bg-slate-800 transition-all shadow-lg shadow-slate-900/20 flex items-center justify-center gap-2">
                    <Edit size={18} />
                    Chỉnh sửa thông tin
                </button>
            </div>
        </div>
    </div>
);

const InfoRow = ({ icon, label, value }) => (
    <div className="flex items-center gap-4">
        <div className="w-10 h-10 rounded-full bg-white flex items-center justify-center shadow-sm text-gray-600 shrink-0">
            {icon}
        </div>
        <div className="flex-1 min-w-0">
            <p className="text-xs text-gray-500 font-medium uppercase tracking-wider mb-0.5">{label}</p>
            <p className="text-sm font-semibold text-gray-900 truncate">{value}</p>
        </div>
    </div>
);





export default UserManagement;

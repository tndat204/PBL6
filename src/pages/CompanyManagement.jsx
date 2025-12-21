import React, { useState, useEffect } from 'react';
import {
    Building2,
    Search,
    MapPin,
    Phone,
    Mail,
    Globe,
    AlertCircle,
    ChevronLeft,
    ChevronRight,
    Loader2,
    MoreVertical,
    CheckCircle,
    X,
    Eye,
    Plus,
    Trash2,
    Ban,
    MessageSquare,
    Star,
    Edit,
    Upload
} from 'lucide-react';
import { companyService } from '../services/companyService';
import { reviewService } from '../services/reviewService';
import userService from '../services/userService';
import Toast from '../components/Toast';
import ConfirmModal from '../components/ConfirmModal';

const CompanyManagement = () => {
    const [companies, setCompanies] = useState([]);
    const [loading, setLoading] = useState(true);
    const [error, setError] = useState(null);
    const [searchTerm, setSearchTerm] = useState('');
    const [statusFilter, setStatusFilter] = useState('ALL');
    const [currentPage, setCurrentPage] = useState(1);
    const [itemsPerPage, setItemsPerPage] = useState(10);
    const [selectedCompany, setSelectedCompany] = useState(null);
    const [showDetailModal, setShowDetailModal] = useState(false);
    const [showCreateModal, setShowCreateModal] = useState(false);
    const [users, setUsers] = useState([]);
    const [toast, setToast] = useState(null);
    const [refreshKey, setRefreshKey] = useState(0); // Force re-render counter
    const [confirmModal, setConfirmModal] = useState({
        isOpen: false,
        companyId: null,
        action: null,
        title: '',
        message: ''
    });
    const [showReviewsModal, setShowReviewsModal] = useState(false);
    const [selectedCompanyForReviews, setSelectedCompanyForReviews] = useState(null);
    const [reviews, setReviews] = useState([]);
    const [reviewsLoading, setReviewsLoading] = useState(false);
    const [reviewsPagination, setReviewsPagination] = useState({
        currentPage: 0,
        totalPages: 0,
        totalElements: 0,
        size: 10
    });
    const [showEditModal, setShowEditModal] = useState(false);
    const [selectedCompanyForEdit, setSelectedCompanyForEdit] = useState(null);

    useEffect(() => {
        fetchCompanies();
        fetchUsers();
    }, []);

    const fetchCompanies = async (showLoading = true) => {
        try {
            if (showLoading) {
                setLoading(true);
            }
            console.log('Fetching companies...');
            const data = await companyService.getAllCompanies();
            const companyList = Array.isArray(data) ? data : (data.result || []);
            console.log('Fetched companies:', companyList);
            console.log('Setting companies state...');
            // Force new array to trigger re-render
            setCompanies([...companyList]);
            console.log('Companies state updated');
        } catch (err) {
            setError('Không thể tải danh sách công ty.');
            console.error(err);
        } finally {
            if (showLoading) {
                setLoading(false);
            }
        }
    };

    const fetchUsers = async () => {
        try {
            const data = await userService.getAllUsers();
            const userList = Array.isArray(data) ? data : (data.result || []);
            setUsers(userList);
        } catch (err) {
            console.error('Error fetching users:', err);
        }
    };

    const showToast = (message, type = 'info') => {
        setToast({ message, type, id: Date.now() });
    };

    // Filter companies
    const filteredCompanies = companies.filter(company => {
        const matchesSearch = company.name?.toLowerCase().includes(searchTerm.toLowerCase()) ||
            company.email?.toLowerCase().includes(searchTerm.toLowerCase());
        const matchesStatus = statusFilter === 'ALL' ||
            (statusFilter === 'Active' && company.active) ||
            (statusFilter === 'Inactive' && !company.active);
        return matchesSearch && matchesStatus;
    });

    // Pagination
    const totalPages = Math.ceil(filteredCompanies.length / itemsPerPage);
    const startIndex = (currentPage - 1) * itemsPerPage;
    const paginatedCompanies = filteredCompanies.slice(startIndex, startIndex + itemsPerPage);

    // Stats
    const stats = {
        total: companies.length,
        active: companies.filter(c => c.active).length,
        inactive: companies.filter(c => !c.active).length
    };

    const handleViewCompany = (company) => {
        setSelectedCompany(company);
        setShowDetailModal(true);
    };

    const handleToggleStatus = (company) => {
        const action = company.active ? 'deactivate' : 'activate';
        setConfirmModal({
            isOpen: true,
            companyId: company.id,
            action: action,
            title: company.active ? 'Tắt hoạt động' : 'Mở hoạt động',
            message: company.active
                ? `Bạn có chắc chắn muốn tắt hoạt động cho công ty "${company.name}"? Công ty sẽ không thể hoạt động trên hệ thống.`
                : `Bạn có chắc chắn muốn mở hoạt động cho công ty "${company.name}"?`
        });
    };

    const handleConfirmToggleStatus = async () => {
        if (!confirmModal.companyId) return;

        const company = companies.find(c => c.id === confirmModal.companyId);
        if (!company) return;

        try {
            console.log('Toggling status for company:', confirmModal.companyId, 'Action:', confirmModal.action);

            if (confirmModal.action === 'deactivate') {
                await companyService.deactivateCompany(confirmModal.companyId, {});
            } else if (confirmModal.action === 'activate') {
                await companyService.activateCompany(confirmModal.companyId, {});
            } else if (confirmModal.action === 'delete') {
                await companyService.deleteCompany(confirmModal.companyId);
            }

            console.log('API call successful, fetching companies...');
            // Fetch fresh data and force full reload with loading state
            setLoading(true);
            await fetchCompanies(false); // Don't use loading inside fetchCompanies
            setLoading(false);
            console.log('Fetch completed');

            // Force re-render by updating refresh key
            setRefreshKey(prev => prev + 1);
            console.log('Refresh key updated');

            let successMessage = '';
            if (confirmModal.action === 'deactivate') {
                successMessage = 'Công ty đã được tắt hoạt động thành công!';
            } else if (confirmModal.action === 'activate') {
                successMessage = 'Công ty đã được mở hoạt động thành công!';
            } else if (confirmModal.action === 'delete') {
                successMessage = 'Công ty đã được xóa thành công!';
            }

            showToast(successMessage, 'success');
        } catch (error) {
            console.error('Error performing action:', error);
            let errorMessage = 'Không thể thực hiện hành động. Vui lòng thử lại.';
            if (confirmModal.action === 'delete') {
                errorMessage = 'Không thể xóa công ty. Vui lòng thử lại.';
            } else {
                errorMessage = 'Không thể thay đổi trạng thái công ty. Vui lòng thử lại.';
            }
            showToast(errorMessage, 'error');
            setLoading(false); // Ensure loading is turned off on error
        }

        // Close modal after everything is done
        setConfirmModal(prev => ({ ...prev, isOpen: false, companyId: null }));
    };

    const handleCreateCompany = () => {
        setShowCreateModal(true);
    };

    const handleSubmitNewCompany = async (companyData) => {
        try {
            await companyService.createCompany(companyData);
            setShowCreateModal(false);
            await fetchCompanies(false); // Refresh the list without loading spinner
        } catch (error) {
            console.error('Error creating company:', error);
            throw error; // Let the modal handle the error display
        }
    };

    const handleDeleteCompany = (company) => {
        setConfirmModal({
            isOpen: true,
            companyId: company.id,
            action: 'delete',
            title: 'Xóa công ty',
            message: `Bạn có chắc chắn muốn xóa công ty "${company.name}"? Hành động này không thể hoàn tác.`
        });
    };

    const handleViewReviews = async (company) => {
        setSelectedCompanyForReviews(company);
        setShowReviewsModal(true);
        setReviewsLoading(true);
        try {
            const data = await reviewService.getCompanyReviews(company.id, 0, 10);
            setReviews(data.content || []);
            setReviewsPagination({
                currentPage: data.pageable?.pageNumber || 0,
                totalPages: data.totalPages || 0,
                totalElements: data.totalElements || 0,
                size: data.size || 10
            });
        } catch (error) {
            console.error('Error fetching reviews:', error);
            showToast('Không thể tải danh sách đánh giá', 'error');
        } finally {
            setReviewsLoading(false);
        }
    };

    const handleReviewsPageChange = async (newPage) => {
        if (!selectedCompanyForReviews) return;
        setReviewsLoading(true);
        try {
            const data = await reviewService.getCompanyReviews(
                selectedCompanyForReviews.id,
                newPage,
                reviewsPagination.size
            );
            setReviews(data.content || []);
            setReviewsPagination({
                currentPage: data.pageable?.pageNumber || 0,
                totalPages: data.totalPages || 0,
                totalElements: data.totalElements || 0,
                size: data.size || 10
            });
        } catch (error) {
            console.error('Error fetching reviews:', error);
            showToast('Không thể tải danh sách đánh giá', 'error');
        } finally {
            setReviewsLoading(false);
        }
    };

    const handleEditCompany = async (company) => {
        try {
            setLoading(true);
            const fullCompany = await companyService.getCompanyById(company.id);
            setSelectedCompanyForEdit(fullCompany);
            setShowEditModal(true);
        } catch (error) {
            console.error('Error fetching company details:', error);
            showToast('Không thể lấy thông tin chi tiết công ty', 'error');
        } finally {
            setLoading(false);
        }
    };

    const handleSubmitEditCompany = async (id, data, logoFile) => {
        try {
            // 1. Update company info
            await companyService.updateCompany(id, data);

            // 2. Upload logo if exists
            if (logoFile) {
                await companyService.uploadLogo(id, logoFile);
            }

            setShowEditModal(false);
            setSelectedCompanyForEdit(null);
            showToast('Cập nhật công ty thành công!', 'success');

            // Refresh list
            await fetchCompanies(false);
        } catch (error) {
            console.error('Error updating company:', error);
            throw error;
        }
    };

    return (
        <div className="h-full flex flex-col">
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
                        <button onClick={fetchCompanies} className="mt-2 px-4 py-2 bg-red-600 text-white rounded-lg hover:bg-red-700 transition-colors">
                            Thử lại
                        </button>
                    </div>
                )}

                {!loading && !error && (
                    <>
                        {/* Stats Grid */}
                        <div className="grid grid-cols-1 md:grid-cols-3 gap-6 mb-8">
                            <StatCard title="Tổng số công ty" value={stats.total} color="blue" icon={<Building2 />} />
                            <StatCard title="Đang hoạt động" value={stats.active} color="green" icon={<CheckCircle />} />
                            <StatCard title="Không hoạt động" value={stats.inactive} color="red" icon={<AlertCircle />} />
                        </div>

                        {/* Table Container */}
                        <div className="bg-white rounded-xl shadow-sm border border-gray-100 overflow-hidden">
                            {/* Header & Filters */}
                            <div className="p-6 border-b border-gray-100">
                                <div className="flex flex-col md:flex-row md:items-center md:justify-between gap-4">
                                    <h3 className="font-bold text-gray-800">Danh sách công ty</h3>

                                    <div className="flex flex-col md:flex-row gap-3">
                                        {/* Search */}
                                        <div className="relative">
                                            <Search className="absolute left-3 top-1/2 -translate-y-1/2 text-gray-400" size={18} />
                                            <input
                                                type="text"
                                                placeholder="Tìm kiếm công ty, email..."
                                                className="pl-10 pr-4 py-2 rounded-lg bg-gray-50 text-sm focus:outline-none focus:ring-2 focus:ring-blue-500 w-full md:w-64"
                                                value={searchTerm}
                                                onChange={(e) => setSearchTerm(e.target.value)}
                                            />
                                        </div>

                                        {/* Status Filter */}
                                        <select
                                            className="px-4 py-2 rounded-lg bg-gray-50 text-sm focus:outline-none focus:ring-2 focus:ring-blue-500"
                                            value={statusFilter}
                                            onChange={(e) => setStatusFilter(e.target.value)}
                                        >
                                            <option value="ALL">Tất cả trạng thái</option>
                                            <option value="Active">Hoạt động</option>
                                            <option value="Inactive">Không hoạt động</option>
                                        </select>

                                        {/* Create New Button */}
                                        <button
                                            onClick={handleCreateCompany}
                                            className="flex items-center gap-2 px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition-colors text-sm font-medium"
                                        >
                                            <Plus size={18} />
                                            <span>Thêm mới</span>
                                        </button>
                                    </div>
                                </div>
                            </div>

                            {/* Table */}
                            <div className="overflow-x-auto">
                                <table className="w-full text-left border-collapse">
                                    <thead className="bg-gray-50 text-gray-600 uppercase text-xs font-semibold">
                                        <tr>
                                            <th className="px-6 py-4">Công ty</th>
                                            <th className="px-6 py-4">Liên hệ</th>
                                            <th className="px-6 py-4">Website</th>
                                            <th className="px-6 py-4">Trạng thái</th>
                                            <th className="px-6 py-4">Hành động</th>
                                        </tr>
                                    </thead>
                                    <tbody key={refreshKey} className="divide-y divide-gray-100 text-sm text-gray-700">
                                        {paginatedCompanies.map((company) => (
                                            <CompanyRow
                                                key={company.id}
                                                company={company}
                                                onView={handleViewCompany}
                                                onViewReviews={handleViewReviews}
                                                onToggleStatus={handleToggleStatus}
                                                onDelete={handleDeleteCompany}
                                                onEdit={handleEditCompany}
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
                                    <span>trên {filteredCompanies.length} kết quả</span>
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
                                        Trang {currentPage} / {totalPages || 1}
                                    </span>
                                    <button
                                        onClick={() => setCurrentPage(prev => Math.min(totalPages, prev + 1))}
                                        disabled={currentPage === totalPages || totalPages === 0}
                                        className="p-2 rounded hover:bg-gray-100 disabled:opacity-50 disabled:cursor-not-allowed"
                                    >
                                        <ChevronRight size={20} />
                                    </button>
                                </div>
                            </div>
                        </div>
                    </>
                )}

                {/* Detail Modal */}
                {showDetailModal && selectedCompany && (
                    <CompanyDetailModal
                        company={selectedCompany}
                        onClose={() => setShowDetailModal(false)}
                    />
                )}

                {/* Create Modal */}
                {showCreateModal && (
                    <CreateCompanyModal
                        users={users}
                        onClose={() => setShowCreateModal(false)}
                        onSubmit={handleSubmitNewCompany}
                    />
                )}

                {/* Reviews Modal */}
                {showReviewsModal && selectedCompanyForReviews && (
                    <ReviewsModal
                        company={selectedCompanyForReviews}
                        reviews={reviews}
                        loading={reviewsLoading}
                        pagination={reviewsPagination}
                        onClose={() => {
                            setShowReviewsModal(false);
                            setSelectedCompanyForReviews(null);
                            setReviews([]);
                        }}
                        onPageChange={handleReviewsPageChange}
                    />
                )}

                {/* Edit Modal */}
                {showEditModal && selectedCompanyForEdit && (
                    <EditCompanyModal
                        company={selectedCompanyForEdit}
                        onClose={() => {
                            setShowEditModal(false);
                            setSelectedCompanyForEdit(null);
                        }}
                        onSubmit={handleSubmitEditCompany}
                    />
                )}

                {/* Confirm Modal */}
                <ConfirmModal
                    isOpen={confirmModal.isOpen}
                    onClose={() => setConfirmModal(prev => ({ ...prev, isOpen: false }))}
                    onConfirm={handleConfirmToggleStatus}
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

const StatCard = ({ title, value, color, icon }) => (
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
    </div>
);

const CompanyRow = ({ company, onView, onToggleStatus, onDelete, onViewReviews, onEdit }) => (
    <tr className="hover:bg-gray-50 transition-colors">
        <td className="px-6 py-4">
            <div className="flex items-center gap-3">
                <div className="w-10 h-10 rounded-lg bg-gray-100 flex items-center justify-center overflow-hidden shrink-0">
                    {company.logoUrl ? (
                        <img src={company.logoUrl} alt={company.name} className="w-full h-full object-cover" />
                    ) : (
                        <Building2 className="text-gray-400" size={20} />
                    )}
                </div>
                <div>
                    <p className="font-medium text-gray-800 line-clamp-1" title={company.name}>{company.name}</p>
                    <p className="text-xs text-gray-500 line-clamp-1" title={company.address}>{company.address || 'Chưa cập nhật địa chỉ'}</p>
                </div>
            </div>
        </td>
        <td className="px-6 py-4 text-gray-600">
            <div className="flex flex-col text-xs">
                <span className="flex items-center gap-1"><Mail size={12} /> {company.email}</span>
                <span className="flex items-center gap-1 mt-1"><Phone size={12} /> {company.phone}</span>
            </div>
        </td>
        <td className="px-6 py-4">
            {company.website ? (
                <a href={company.website} target="_blank" rel="noopener noreferrer" className="text-blue-600 hover:underline text-xs flex items-center gap-1">
                    <Globe size={12} /> {company.website}
                </a>
            ) : (
                <span className="text-gray-400 text-xs">N/A</span>
            )}
        </td>
        <td className="px-6 py-4">
            <span className={`px-3 py-1 rounded-full text-xs font-medium ${company.active ? 'bg-green-100 text-green-700' : 'bg-red-100 text-red-700'
                }`}>
                {company.active ? 'Hoạt động' : 'Không hoạt động'}
            </span>
        </td>
        <td className="px-6 py-4">
            <div className="flex gap-2">
                <button
                    onClick={() => onView(company)}
                    className="p-2 text-blue-600 hover:bg-blue-50 rounded-lg transition-colors"
                    title="Xem chi tiết"
                >
                    <Eye size={18} />
                </button>
                <button
                    onClick={() => onEdit(company)}
                    className="p-2 text-indigo-600 hover:bg-indigo-50 rounded-lg transition-colors"
                    title="Chỉnh sửa"
                >
                    <Edit size={18} />
                </button>
                <button
                    onClick={() => onViewReviews(company)}
                    className="p-2 text-purple-600 hover:bg-purple-50 rounded-lg transition-colors"
                    title="Xem đánh giá"
                >
                    <MessageSquare size={18} />
                </button>
                <button
                    onClick={() => onToggleStatus(company)}
                    className={`p-2 ${company.active ? 'text-orange-600 hover:bg-orange-50' : 'text-green-600 hover:bg-green-50'} rounded-lg transition-colors`}
                    title={company.active ? 'Tắt hoạt động' : 'Mở hoạt động'}
                >
                    {company.active ? <Ban size={18} /> : <CheckCircle size={18} />}
                </button>
                <button
                    onClick={() => onDelete(company)}
                    className="p-2 text-red-600 hover:bg-red-50 rounded-lg transition-colors"
                    title="Xóa công ty"
                >
                    <Trash2 size={18} />
                </button>
            </div>
        </td>
    </tr>
);

const CompanyDetailModal = ({ company, onClose }) => (
    <div className="fixed inset-0 bg-black/60 backdrop-blur-sm flex items-center justify-center z-50 p-4 animate-fade-in">
        <div className="bg-white rounded-3xl shadow-2xl w-full max-w-md overflow-hidden transform transition-all animate-scale-in relative">
            {/* Decorative Background Pattern */}
            <div className="absolute top-0 left-0 w-full h-32 bg-gradient-to-r from-blue-600 to-cyan-600 opacity-10"></div>

            <button onClick={onClose} className="absolute top-4 right-4 p-2 bg-white/80 hover:bg-white rounded-full text-gray-500 hover:text-gray-800 transition-all shadow-sm z-10">
                <X size={20} />
            </button>

            <div className="px-8 pb-8 pt-12 relative">
                <div className="flex flex-col items-center mb-8">
                    <div className="w-24 h-24 rounded-2xl bg-white shadow-xl border-4 border-white mb-4 overflow-hidden flex items-center justify-center">
                        {company.logoUrl ? (
                            <img src={company.logoUrl} alt={company.name} className="w-full h-full object-cover" />
                        ) : (
                            <Building2 className="text-gray-300" size={48} />
                        )}
                    </div>
                    <h4 className="text-xl font-bold text-gray-900 text-center">{company.name}</h4>
                    <div className="mt-2">
                        <span className={`px-3 py-1 rounded-full text-xs font-semibold tracking-wide ${company.active ? 'bg-green-100 text-green-700' : 'bg-red-100 text-red-700'
                            }`}>
                            {company.active ? 'Hoạt động' : 'Không hoạt động'}
                        </span>
                    </div>
                </div>

                <div className="bg-gray-50 rounded-2xl p-6 space-y-5">
                    <InfoRow icon={<Mail className="text-blue-500" size={18} />} label="Email" value={company.email} />
                    <InfoRow icon={<Phone className="text-green-500" size={18} />} label="Số điện thoại" value={company.phone} />
                    <InfoRow icon={<MapPin className="text-red-500" size={18} />} label="Địa chỉ" value={company.address} />
                    <InfoRow icon={<Globe className="text-purple-500" size={18} />} label="Website" value={company.website} isLink />
                </div>
            </div>
        </div>
    </div>
);

const InfoRow = ({ icon, label, value, isLink }) => (
    <div className="flex items-center gap-4">
        <div className="w-10 h-10 rounded-full bg-white flex items-center justify-center shadow-sm text-gray-600 shrink-0">
            {icon}
        </div>
        <div className="flex-1 min-w-0">
            <p className="text-xs text-gray-500 font-medium uppercase tracking-wider mb-0.5">{label}</p>
            {isLink && value ? (
                <a href={value} target="_blank" rel="noopener noreferrer" className="text-sm font-semibold text-blue-600 hover:underline truncate block">
                    {value}
                </a>
            ) : (
                <p className="text-sm font-semibold text-gray-900 truncate">{value || 'N/A'}</p>
            )}
        </div>
    </div>
);

const CreateCompanyModal = ({ users, onClose, onSubmit }) => {
    const [formData, setFormData] = useState({
        name: '',
        ownerID: '',
        taxCode: '',
        address: '',
        phone: '',
        email: '',
        description: ''
    });
    const [searchTerm, setSearchTerm] = useState('');
    const [showDropdown, setShowDropdown] = useState(false);
    const [errors, setErrors] = useState({});
    const [submitting, setSubmitting] = useState(false);
    const [submitError, setSubmitError] = useState('');

    // Close dropdown when clicking outside
    useEffect(() => {
        const handleClickOutside = (event) => {
            if (showDropdown && !event.target.closest('.user-dropdown-container')) {
                setShowDropdown(false);
            }
        };

        document.addEventListener('mousedown', handleClickOutside);
        return () => document.removeEventListener('mousedown', handleClickOutside);
    }, [showDropdown]);

    // Filter users based on search term
    const filteredUsers = users.filter(user => {
        const searchLower = searchTerm.toLowerCase();
        return (
            user.username?.toLowerCase().includes(searchLower) ||
            user.email?.toLowerCase().includes(searchLower) ||
            user.fullName?.toLowerCase().includes(searchLower)
        );
    });

    // Get selected user display name
    const selectedUser = users.find(u => u.id === formData.ownerID);
    const selectedUserDisplay = selectedUser
        ? `${selectedUser.fullName || selectedUser.username} (${selectedUser.email})`
        : '';

    const handleInputChange = (e) => {
        const { name, value } = e.target;
        setFormData(prev => ({ ...prev, [name]: value }));
        // Clear error for this field
        if (errors[name]) {
            setErrors(prev => ({ ...prev, [name]: '' }));
        }
    };

    const handleUserSelect = (user) => {
        setFormData(prev => ({ ...prev, ownerID: user.id }));
        setSearchTerm('');
        setShowDropdown(false);
        if (errors.ownerID) {
            setErrors(prev => ({ ...prev, ownerID: '' }));
        }
    };

    const validateForm = () => {
        const newErrors = {};
        if (!formData.name.trim()) newErrors.name = 'Tên công ty là bắt buộc';
        if (!formData.ownerID) newErrors.ownerID = 'Vui lòng chọn chủ sở hữu';
        if (!formData.email.trim()) {
            newErrors.email = 'Email là bắt buộc';
        } else if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(formData.email)) {
            newErrors.email = 'Email không hợp lệ';
        }
        if (!formData.phone.trim()) {
            newErrors.phone = 'Số điện thoại là bắt buộc';
        }

        setErrors(newErrors);
        return Object.keys(newErrors).length === 0;
    };

    const handleSubmit = async (e) => {
        e.preventDefault();
        setSubmitError('');

        if (!validateForm()) return;

        setSubmitting(true);
        try {
            await onSubmit(formData);
        } catch (error) {
            setSubmitError(error.message || 'Có lỗi xảy ra khi tạo công ty');
        } finally {
            setSubmitting(false);
        }
    };

    return (
        <div className="fixed inset-0 bg-black/60 backdrop-blur-sm flex items-center justify-center z-50 p-4 animate-fade-in">
            <div className="bg-white rounded-3xl shadow-2xl w-full max-w-2xl overflow-hidden transform transition-all animate-scale-in relative max-h-[90vh] flex flex-col">
                {/* Header */}
                <div className="bg-gradient-to-r from-blue-600 to-cyan-600 px-8 py-6 relative">
                    <button
                        onClick={onClose}
                        className="absolute top-4 right-4 p-2 bg-white/20 hover:bg-white/30 rounded-full text-white transition-all"
                    >
                        <X size={20} />
                    </button>
                    <h3 className="text-2xl font-bold text-white flex items-center gap-3">
                        <Building2 size={28} />
                        Tạo công ty mới
                    </h3>
                </div>

                {/* Form */}
                <form onSubmit={handleSubmit} className="flex-1 overflow-y-auto px-8 py-6">
                    {submitError && (
                        <div className="mb-4 p-3 bg-red-50 border border-red-200 rounded-lg text-red-700 text-sm">
                            {submitError}
                        </div>
                    )}

                    <div className="space-y-4">
                        {/* Company Name */}
                        <div>
                            <label className="block text-sm font-semibold text-gray-700 mb-2">
                                Tên công ty <span className="text-red-500">*</span>
                            </label>
                            <input
                                type="text"
                                name="name"
                                value={formData.name}
                                onChange={handleInputChange}
                                className={`w-full px-4 py-2.5 rounded-lg border ${errors.name ? 'border-red-500' : 'border-gray-300'} focus:outline-none focus:ring-2 focus:ring-blue-500`}
                                placeholder="Nhập tên công ty"
                            />
                            {errors.name && <p className="mt-1 text-sm text-red-500">{errors.name}</p>}
                        </div>

                        {/* Owner ID - Searchable Dropdown */}
                        <div className="user-dropdown-container">
                            <label className="block text-sm font-semibold text-gray-700 mb-2">
                                Chủ sở hữu <span className="text-red-500">*</span>
                            </label>
                            <div className="relative">
                                <input
                                    type="text"
                                    value={selectedUserDisplay || searchTerm}
                                    onChange={(e) => {
                                        setSearchTerm(e.target.value);
                                        setShowDropdown(true);
                                        if (selectedUserDisplay) {
                                            setFormData(prev => ({ ...prev, ownerID: '' }));
                                        }
                                    }}
                                    onFocus={() => setShowDropdown(true)}
                                    className={`w-full px-4 py-2.5 rounded-lg border ${errors.ownerID ? 'border-red-500' : 'border-gray-300'} focus:outline-none focus:ring-2 focus:ring-blue-500`}
                                    placeholder="Tìm kiếm và chọn chủ sở hữu..."
                                />
                                {showDropdown && (
                                    <div className="absolute z-10 w-full mt-1 bg-white border border-gray-300 rounded-lg shadow-lg max-h-60 overflow-y-auto">
                                        {filteredUsers.length > 0 ? (
                                            filteredUsers.map(user => (
                                                <div
                                                    key={user.id}
                                                    onClick={() => handleUserSelect(user)}
                                                    className="px-4 py-3 hover:bg-blue-50 cursor-pointer border-b border-gray-100 last:border-b-0"
                                                >
                                                    <p className="font-medium text-gray-800">{user.fullName || user.username}</p>
                                                    <p className="text-sm text-gray-500">{user.email}</p>
                                                </div>
                                            ))
                                        ) : (
                                            <div className="px-4 py-3 text-gray-500 text-sm">
                                                Không tìm thấy người dùng
                                            </div>
                                        )}
                                    </div>
                                )}
                            </div>
                            {errors.ownerID && <p className="mt-1 text-sm text-red-500">{errors.ownerID}</p>}
                        </div>

                        {/* Tax Code */}
                        <div>
                            <label className="block text-sm font-semibold text-gray-700 mb-2">
                                Mã số thuế
                            </label>
                            <input
                                type="text"
                                name="taxCode"
                                value={formData.taxCode}
                                onChange={handleInputChange}
                                className="w-full px-4 py-2.5 rounded-lg border border-gray-300 focus:outline-none focus:ring-2 focus:ring-blue-500"
                                placeholder="Nhập mã số thuế"
                            />
                        </div>

                        {/* Address */}
                        <div>
                            <label className="block text-sm font-semibold text-gray-700 mb-2">
                                Địa chỉ
                            </label>
                            <input
                                type="text"
                                name="address"
                                value={formData.address}
                                onChange={handleInputChange}
                                className="w-full px-4 py-2.5 rounded-lg border border-gray-300 focus:outline-none focus:ring-2 focus:ring-blue-500"
                                placeholder="Nhập địa chỉ công ty"
                            />
                        </div>

                        {/* Phone */}
                        <div>
                            <label className="block text-sm font-semibold text-gray-700 mb-2">
                                Số điện thoại <span className="text-red-500">*</span>
                            </label>
                            <input
                                type="tel"
                                name="phone"
                                value={formData.phone}
                                onChange={handleInputChange}
                                className={`w-full px-4 py-2.5 rounded-lg border ${errors.phone ? 'border-red-500' : 'border-gray-300'} focus:outline-none focus:ring-2 focus:ring-blue-500`}
                                placeholder="Nhập số điện thoại"
                            />
                            {errors.phone && <p className="mt-1 text-sm text-red-500">{errors.phone}</p>}
                        </div>

                        {/* Email */}
                        <div>
                            <label className="block text-sm font-semibold text-gray-700 mb-2">
                                Email <span className="text-red-500">*</span>
                            </label>
                            <input
                                type="email"
                                name="email"
                                value={formData.email}
                                onChange={handleInputChange}
                                className={`w-full px-4 py-2.5 rounded-lg border ${errors.email ? 'border-red-500' : 'border-gray-300'} focus:outline-none focus:ring-2 focus:ring-blue-500`}
                                placeholder="Nhập email công ty"
                            />
                            {errors.email && <p className="mt-1 text-sm text-red-500">{errors.email}</p>}
                        </div>

                        {/* Description */}
                        <div>
                            <label className="block text-sm font-semibold text-gray-700 mb-2">
                                Mô tả
                            </label>
                            <textarea
                                name="description"
                                value={formData.description}
                                onChange={handleInputChange}
                                rows={3}
                                className="w-full px-4 py-2.5 rounded-lg border border-gray-300 focus:outline-none focus:ring-2 focus:ring-blue-500 resize-none"
                                placeholder="Nhập mô tả về công ty"
                            />
                        </div>
                    </div>
                </form>

                {/* Footer */}
                <div className="px-8 py-4 bg-gray-50 border-t border-gray-200 flex justify-end gap-3">
                    <button
                        type="button"
                        onClick={onClose}
                        className="px-6 py-2.5 rounded-lg border border-gray-300 text-gray-700 font-medium hover:bg-gray-100 transition-colors"
                        disabled={submitting}
                    >
                        Hủy
                    </button>
                    <button
                        type="submit"
                        onClick={handleSubmit}
                        disabled={submitting}
                        className="px-6 py-2.5 rounded-lg bg-blue-600 text-white font-medium hover:bg-blue-700 transition-colors disabled:opacity-50 disabled:cursor-not-allowed flex items-center gap-2"
                    >
                        {submitting ? (
                            <>
                                <Loader2 className="animate-spin" size={18} />
                                Đang tạo...
                            </>
                        ) : (
                            <>
                                <Plus size={18} />
                                Tạo công ty
                            </>
                        )}
                    </button>
                </div>
            </div>
        </div>
    );
};

const ReviewsModal = ({ company, reviews, loading, pagination, onClose, onPageChange }) => {
    const formatDate = (dateString) => {
        const date = new Date(dateString);
        return date.toLocaleDateString('vi-VN', {
            year: 'numeric',
            month: 'long',
            day: 'numeric',
            hour: '2-digit',
            minute: '2-digit'
        });
    };

    const renderStars = (rating) => {
        const stars = [];
        const fullStars = Math.floor(rating);
        const hasHalfStar = rating % 1 !== 0;

        for (let i = 0; i < fullStars; i++) {
            stars.push(<Star key={`full-${i}`} size={16} className="fill-yellow-400 text-yellow-400" />);
        }
        if (hasHalfStar) {
            stars.push(<Star key="half" size={16} className="fill-yellow-400 text-yellow-400" style={{ clipPath: 'inset(0 50% 0 0)' }} />);
        }
        const emptyStars = 5 - Math.ceil(rating);
        for (let i = 0; i < emptyStars; i++) {
            stars.push(<Star key={`empty-${i}`} size={16} className="text-gray-300" />);
        }
        return stars;
    };

    return (
        <div className="fixed inset-0 bg-black/60 backdrop-blur-sm flex items-center justify-center z-50 p-4 animate-fade-in">
            <div className="bg-white rounded-3xl shadow-2xl w-full max-w-4xl overflow-hidden transform transition-all animate-scale-in relative max-h-[90vh] flex flex-col">
                {/* Header */}
                <div className="bg-gradient-to-r from-purple-600 to-pink-600 px-8 py-6 relative">
                    <button
                        onClick={onClose}
                        className="absolute top-4 right-4 p-2 bg-white/20 hover:bg-white/30 rounded-full text-white transition-all"
                    >
                        <X size={20} />
                    </button>
                    <h3 className="text-2xl font-bold text-white flex items-center gap-3">
                        <MessageSquare size={28} />
                        Đánh giá của {company.name}
                    </h3>
                    <p className="text-white/80 text-sm mt-1">
                        Tổng số: {pagination.totalElements} đánh giá
                    </p>
                </div>

                {/* Content */}
                <div className="flex-1 overflow-y-auto px-8 py-6">
                    {loading ? (
                        <div className="flex items-center justify-center h-64">
                            <Loader2 className="animate-spin text-purple-600" size={48} />
                            <span className="ml-3 text-gray-600">Đang tải đánh giá...</span>
                        </div>
                    ) : reviews.length === 0 ? (
                        <div className="flex flex-col items-center justify-center h-64 text-gray-500">
                            <MessageSquare size={64} className="text-gray-300 mb-4" />
                            <p className="text-lg font-medium">Chưa có đánh giá nào</p>
                            <p className="text-sm">Công ty này chưa nhận được đánh giá từ người dùng.</p>
                        </div>
                    ) : (
                        <div className="space-y-4">
                            {reviews.map((review) => (
                                <div key={review.reviewId} className="bg-gray-50 rounded-2xl p-6 hover:shadow-md transition-shadow">
                                    {/* Reviewer Info */}
                                    <div className="flex items-start gap-4 mb-4">
                                        <div className="w-12 h-12 rounded-full bg-gradient-to-br from-purple-400 to-pink-400 flex items-center justify-center text-white font-bold text-lg shrink-0 overflow-hidden">
                                            {review.reviewerInfo.reviewerAvatar ? (
                                                <img
                                                    src={review.reviewerInfo.reviewerAvatar}
                                                    alt={review.reviewerInfo.reviewerName}
                                                    className="w-full h-full object-cover"
                                                />
                                            ) : (
                                                review.reviewerInfo.reviewerName.charAt(0).toUpperCase()
                                            )}
                                        </div>
                                        <div className="flex-1">
                                            <div className="flex items-center justify-between">
                                                <div>
                                                    <p className="font-semibold text-gray-900">{review.reviewerInfo.reviewerName}</p>
                                                    <div className="flex items-center gap-2 mt-1">
                                                        <div className="flex gap-0.5">
                                                            {renderStars(review.rating)}
                                                        </div>
                                                        <span className="text-sm font-medium text-gray-700">{review.rating.toFixed(1)}</span>
                                                    </div>
                                                </div>
                                                <span className="text-xs text-gray-500">
                                                    {formatDate(review.createdAt)}
                                                </span>
                                            </div>
                                        </div>
                                    </div>

                                    {/* Review Content */}
                                    <div className="ml-16">
                                        {review.title && (
                                            <h4 className="font-semibold text-gray-900 mb-2">{review.title}</h4>
                                        )}
                                        <p className="text-gray-700 text-sm leading-relaxed mb-3">{review.comment}</p>

                                        {/* Images */}
                                        {review.imageUrls && review.imageUrls.length > 0 && (
                                            <div className="flex gap-2 mb-3 flex-wrap">
                                                {review.imageUrls.map((url, index) => (
                                                    <img
                                                        key={index}
                                                        src={url}
                                                        alt={`Review image ${index + 1}`}
                                                        className="w-20 h-20 rounded-lg object-cover border border-gray-200"
                                                    />
                                                ))}
                                            </div>
                                        )}

                                        {/* Footer */}
                                        <div className="flex items-center gap-4 text-xs text-gray-500">
                                            <span className="flex items-center gap-1">
                                                👍 {review.likeCount} lượt thích
                                            </span>
                                            <span className={`px-2 py-1 rounded-full text-xs font-medium ${review.status === 'ACTIVE'
                                                ? 'bg-green-100 text-green-700'
                                                : 'bg-gray-100 text-gray-700'
                                                }`}>
                                                {review.status === 'ACTIVE' ? 'Đang hiển thị' : review.status}
                                            </span>
                                        </div>
                                    </div>
                                </div>
                            ))}
                        </div>
                    )}
                </div>

                {/* Pagination Footer */}
                {!loading && reviews.length > 0 && pagination.totalPages > 1 && (
                    <div className="px-8 py-4 bg-gray-50 border-t border-gray-200 flex items-center justify-between">
                        <div className="text-sm text-gray-600">
                            Trang {pagination.currentPage + 1} / {pagination.totalPages}
                        </div>
                        <div className="flex items-center gap-2">
                            <button
                                onClick={() => onPageChange(pagination.currentPage - 1)}
                                disabled={pagination.currentPage === 0}
                                className="p-2 rounded hover:bg-gray-200 disabled:opacity-50 disabled:cursor-not-allowed transition-colors"
                            >
                                <ChevronLeft size={20} />
                            </button>
                            <button
                                onClick={() => onPageChange(pagination.currentPage + 1)}
                                disabled={pagination.currentPage >= pagination.totalPages - 1}
                                className="p-2 rounded hover:bg-gray-200 disabled:opacity-50 disabled:cursor-not-allowed transition-colors"
                            >
                                <ChevronRight size={20} />
                            </button>
                        </div>
                    </div>
                )}
            </div>
        </div>
    );
};

const EditCompanyModal = ({ company, onClose, onSubmit }) => {
    const [formData, setFormData] = useState({
        name: company.name || '',
        ownerID: company.ownerID || company.owner?.id || '',
        taxCode: company.taxCode || '',
        address: company.address || '',
        phone: company.phone || '',
        email: company.email || '',
        description: company.description || ''
    });
    const [logoFile, setLogoFile] = useState(null);
    const [previewLogo, setPreviewLogo] = useState(company.logoUrl);
    const [errors, setErrors] = useState({});
    const [submitting, setSubmitting] = useState(false);
    const [submitError, setSubmitError] = useState('');

    const handleInputChange = (e) => {
        const { name, value } = e.target;
        setFormData(prev => ({ ...prev, [name]: value }));
        if (errors[name]) {
            setErrors(prev => ({ ...prev, [name]: '' }));
        }
    };

    const handleFileChange = (e) => {
        const file = e.target.files[0];
        if (file) {
            setLogoFile(file);
            setPreviewLogo(URL.createObjectURL(file));
        }
    };

    const validateForm = () => {
        const newErrors = {};
        if (!formData.name.trim()) newErrors.name = 'Tên công ty là bắt buộc';
        if (!formData.email.trim()) {
            newErrors.email = 'Email là bắt buộc';
        } else if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(formData.email)) {
            newErrors.email = 'Email không hợp lệ';
        }
        if (!formData.phone.trim()) {
            newErrors.phone = 'Số điện thoại là bắt buộc';
        }

        setErrors(newErrors);
        return Object.keys(newErrors).length === 0;
    };

    const handleSubmit = async (e) => {
        e.preventDefault();
        setSubmitError('');

        if (!validateForm()) return;

        setSubmitting(true);
        try {
            await onSubmit(company.id, formData, logoFile);
        } catch (error) {
            setSubmitError(error.message || 'Có lỗi xảy ra khi cập nhật công ty');
        } finally {
            setSubmitting(false);
        }
    };

    return (
        <div className="fixed inset-0 bg-black/60 backdrop-blur-sm flex items-center justify-center z-50 p-4 animate-fade-in">
            <div className="bg-white rounded-3xl shadow-2xl w-full max-w-2xl overflow-hidden transform transition-all animate-scale-in relative max-h-[90vh] flex flex-col">
                {/* Header */}
                <div className="bg-gradient-to-r from-indigo-600 to-purple-600 px-8 py-6 relative">
                    <button
                        onClick={onClose}
                        className="absolute top-4 right-4 p-2 bg-white/20 hover:bg-white/30 rounded-full text-white transition-all"
                    >
                        <X size={20} />
                    </button>
                    <h3 className="text-2xl font-bold text-white flex items-center gap-3">
                        <Edit size={28} />
                        Chỉnh sửa công ty
                    </h3>
                </div>

                {/* Form */}
                <form onSubmit={handleSubmit} className="flex-1 overflow-y-auto px-8 py-6">
                    {submitError && (
                        <div className="mb-4 p-3 bg-red-50 border border-red-200 rounded-lg text-red-700 text-sm">
                            {submitError}
                        </div>
                    )}

                    <div className="space-y-6">
                        {/* Logo Upload */}
                        <div className="flex flex-col items-center">
                            <div className="w-32 h-32 rounded-2xl bg-gray-100 border-2 border-dashed border-gray-300 flex items-center justify-center overflow-hidden relative group cursor-pointer hover:border-indigo-500 transition-colors">
                                {previewLogo ? (
                                    <img src={previewLogo} alt="Preview" className="w-full h-full object-cover" />
                                ) : (
                                    <div className="text-center p-4">
                                        <Upload className="mx-auto text-gray-400 mb-2" size={24} />
                                        <span className="text-xs text-gray-500">Tải ảnh lên</span>
                                    </div>
                                )}
                                <input
                                    type="file"
                                    accept="image/*"
                                    onChange={handleFileChange}
                                    className="absolute inset-0 opacity-0 cursor-pointer z-50"
                                />
                                <div className="absolute inset-0 bg-black/40 flex items-center justify-center opacity-0 group-hover:opacity-100 transition-opacity">
                                    <Edit className="text-white" size={24} />
                                </div>
                            </div>
                            <p className="text-sm text-gray-500 mt-2">Nhấn để thay đổi logo</p>
                        </div>

                        {/* Company Name */}
                        <div>
                            <label className="block text-sm font-semibold text-gray-700 mb-2">
                                Tên công ty <span className="text-red-500">*</span>
                            </label>
                            <input
                                type="text"
                                name="name"
                                value={formData.name}
                                onChange={handleInputChange}
                                className={`w-full px-4 py-2.5 rounded-lg border ${errors.name ? 'border-red-500' : 'border-gray-300'} focus:outline-none focus:ring-2 focus:ring-indigo-500`}
                                placeholder="Nhập tên công ty"
                            />
                            {errors.name && <p className="mt-1 text-sm text-red-500">{errors.name}</p>}
                        </div>

                        {/* Tax Code */}
                        <div>
                            <label className="block text-sm font-semibold text-gray-700 mb-2">
                                Mã số thuế
                            </label>
                            <input
                                type="text"
                                name="taxCode"
                                value={formData.taxCode}
                                onChange={handleInputChange}
                                className="w-full px-4 py-2.5 rounded-lg border border-gray-300 focus:outline-none focus:ring-2 focus:ring-indigo-500"
                                placeholder="Nhập mã số thuế"
                            />
                        </div>

                        {/* Address */}
                        <div>
                            <label className="block text-sm font-semibold text-gray-700 mb-2">
                                Địa chỉ
                            </label>
                            <input
                                type="text"
                                name="address"
                                value={formData.address}
                                onChange={handleInputChange}
                                className="w-full px-4 py-2.5 rounded-lg border border-gray-300 focus:outline-none focus:ring-2 focus:ring-indigo-500"
                                placeholder="Nhập địa chỉ công ty"
                            />
                        </div>

                        {/* Phone & Email */}
                        <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                            <div>
                                <label className="block text-sm font-semibold text-gray-700 mb-2">
                                    Số điện thoại <span className="text-red-500">*</span>
                                </label>
                                <input
                                    type="text"
                                    name="phone"
                                    value={formData.phone}
                                    onChange={handleInputChange}
                                    className={`w-full px-4 py-2.5 rounded-lg border ${errors.phone ? 'border-red-500' : 'border-gray-300'} focus:outline-none focus:ring-2 focus:ring-indigo-500`}
                                    placeholder="Nhập số điện thoại"
                                />
                                {errors.phone && <p className="mt-1 text-sm text-red-500">{errors.phone}</p>}
                            </div>
                            <div>
                                <label className="block text-sm font-semibold text-gray-700 mb-2">
                                    Email <span className="text-red-500">*</span>
                                </label>
                                <input
                                    type="email"
                                    name="email"
                                    value={formData.email}
                                    onChange={handleInputChange}
                                    className={`w-full px-4 py-2.5 rounded-lg border ${errors.email ? 'border-red-500' : 'border-gray-300'} focus:outline-none focus:ring-2 focus:ring-indigo-500`}
                                    placeholder="Nhập email công ty"
                                />
                                {errors.email && <p className="mt-1 text-sm text-red-500">{errors.email}</p>}
                            </div>
                        </div>

                        {/* Description */}
                        <div>
                            <label className="block text-sm font-semibold text-gray-700 mb-2">
                                Mô tả
                            </label>
                            <textarea
                                name="description"
                                value={formData.description}
                                onChange={handleInputChange}
                                rows="4"
                                className="w-full px-4 py-2.5 rounded-lg border border-gray-300 focus:outline-none focus:ring-2 focus:ring-indigo-500 resize-none"
                                placeholder="Nhập mô tả về công ty..."
                            ></textarea>
                        </div>
                    </div>

                    {/* Footer */}
                    <div className="px-8 py-6 bg-gray-50 border-t border-gray-100 flex justify-end gap-3">
                        <button
                            type="button"
                            onClick={onClose}
                            className="px-6 py-2.5 rounded-lg border border-gray-300 text-gray-700 font-medium hover:bg-gray-100 transition-colors"
                            disabled={submitting}
                        >
                            Hủy bỏ
                        </button>
                        <button
                            type="submit"
                            className="px-6 py-2.5 rounded-lg bg-gradient-to-r from-indigo-600 to-purple-600 text-white font-medium hover:shadow-lg hover:scale-[1.02] transition-all disabled:opacity-70 disabled:cursor-not-allowed flex items-center gap-2"
                            disabled={submitting}
                        >
                            {submitting ? (
                                <>
                                    <Loader2 className="animate-spin" size={20} />
                                    Đang lưu...
                                </>
                            ) : (
                                <>
                                    <CheckCircle size={20} />
                                    Lưu thay đổi
                                </>
                            )}
                        </button>
                    </div>
                </form>
            </div>
        </div>
    );
};

export default CompanyManagement;

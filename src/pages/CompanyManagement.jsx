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
    Eye
} from 'lucide-react';
import { companyService } from '../services/companyService';

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

    useEffect(() => {
        fetchCompanies();
    }, []);

    const fetchCompanies = async () => {
        try {
            setLoading(true);
            const data = await companyService.getAllCompanies();
            const companyList = Array.isArray(data) ? data : (data.result || []);
            console.log('Fetched companies:', companyList);
            setCompanies(companyList);
        } catch (err) {
            setError('Không thể tải danh sách công ty.');
            console.error(err);
        } finally {
            setLoading(false);
        }
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

    const handleToggleStatus = async (company) => {
        console.log('Toggling status for:', company.id, 'Current status:', company.active);
        try {
            if (company.active) {
                await companyService.deactivateCompany(company.id, {});
            } else {
                await companyService.activateCompany(company.id, {});
            }

            // Update local state immediately
            setCompanies(prevCompanies => {
                const index = prevCompanies.findIndex(c => c.id === company.id);
                if (index !== -1) {
                    const newCompanies = [...prevCompanies];
                    newCompanies[index] = {
                        ...newCompanies[index],
                        active: !newCompanies[index].active
                    };
                    console.log('Updated company locally:', newCompanies[index]);
                    return newCompanies;
                }
                return prevCompanies;
            });

            // Optional: Show success message
            // showToast('Cập nhật trạng thái thành công', 'success');
        } catch (error) {
            console.error('Error toggling company status:', error);
            // You might want to show a toast here
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
                                    <tbody className="divide-y divide-gray-100 text-sm text-gray-700">
                                        {paginatedCompanies.map((company) => (
                                            <CompanyRow
                                                key={`${company.id}-${company.active}`}
                                                company={company}
                                                onView={handleViewCompany}
                                                onToggleStatus={handleToggleStatus}
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

const CompanyRow = ({ company, onView, onToggleStatus }) => (
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
                    onClick={() => onToggleStatus(company)}
                    className={`p-2 ${company.active ? 'text-red-600 hover:bg-red-50' : 'text-green-600 hover:bg-green-50'} rounded-lg transition-colors`}
                    title={company.active ? 'Vô hiệu hóa' : 'Kích hoạt'}
                >
                    {company.active ? <AlertCircle size={18} /> : <CheckCircle size={18} />}
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

export default CompanyManagement;

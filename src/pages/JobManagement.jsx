import React, { useState, useEffect } from 'react';
import {
    Briefcase,
    Search,
    MapPin,
    DollarSign,
    Calendar,
    AlertCircle,
    ChevronLeft,
    ChevronRight,
    Loader2,
    CheckCircle,
    X,
    Eye,
    Plus,
    Trash2,
    Ban,
    Building2,
    Clock,
    Upload,
    FileText,
    Pencil
} from 'lucide-react';
import { jobService } from '../services/jobService';
import { companyService } from '../services/companyService';
import { categoryService } from '../services/categoryService';
import { skillService } from '../services/skillService';
import Toast from '../components/Toast';
import ConfirmModal from '../components/ConfirmModal';

const JobManagement = () => {
    const [jobs, setJobs] = useState([]);
    const [companies, setCompanies] = useState([]);
    const [categories, setCategories] = useState([]);
    const [skills, setSkills] = useState([]);
    const [loading, setLoading] = useState(true);
    const [error, setError] = useState(null);
    const [searchTerm, setSearchTerm] = useState('');
    const [statusFilter, setStatusFilter] = useState('ALL');
    const [currentPage, setCurrentPage] = useState(1);
    const [itemsPerPage, setItemsPerPage] = useState(10);
    const [selectedJob, setSelectedJob] = useState(null);
    const [showDetailModal, setShowDetailModal] = useState(false);
    // const [showCreateModal, setShowCreateModal] = useState(false); // Removed create functionality
    const [showEditModal, setShowEditModal] = useState(false);
    const [editingJob, setEditingJob] = useState(null);
    const [toast, setToast] = useState(null);
    const [refreshKey, setRefreshKey] = useState(0);
    const [confirmModal, setConfirmModal] = useState({
        isOpen: false,
        jobId: null,
        action: null,
        title: '',
        message: ''
    });

    useEffect(() => {
        fetchJobs();
        fetchCompanies();
        fetchCategories();
        fetchSkills();
    }, []);

    const fetchJobs = async (showLoading = true) => {
        try {
            if (showLoading) {
                setLoading(true);
            }
            const data = await jobService.getAllJobs();
            const jobList = Array.isArray(data) ? data : (data.result || []);
            setJobs([...jobList]);
        } catch (err) {
            setError('Không thể tải danh sách công việc.');
            console.error(err);
        } finally {
            if (showLoading) {
                setLoading(false);
            }
        }
    };

    const fetchCompanies = async () => {
        try {
            const data = await companyService.getAllCompanies();
            const companyList = Array.isArray(data) ? data : (data.result || []);
            setCompanies(companyList);
        } catch (err) {
            console.error('Error fetching companies:', err);
        }
    };

    const fetchCategories = async () => {
        try {
            const data = await categoryService.getAllCategories();
            const categoryList = Array.isArray(data) ? data : (data.result || []);
            setCategories(categoryList);
        } catch (err) {
            console.error('Error fetching categories:', err);
        }
    };

    const fetchSkills = async () => {
        try {
            const data = await skillService.getAllSkills();
            const skillList = Array.isArray(data) ? data : (data.result || []);
            setSkills(skillList);
        } catch (err) {
            console.error('Error fetching skills:', err);
        }
    };

    const showToast = (message, type = 'info') => {
        setToast({ message, type, id: Date.now() });
    };

    // Get company name by ID
    const getCompanyName = (companyId) => {
        const company = companies.find(c => c.id === companyId);
        return company?.name || 'N/A';
    };

    // Get category name by ID
    const getCategoryName = (categoryId) => {
        const category = categories.find(c => c.id === categoryId);
        return category?.name || 'N/A';
    };

    // Filter jobs
    const filteredJobs = jobs.filter(job => {
        const matchesSearch = job.title?.toLowerCase().includes(searchTerm.toLowerCase()) ||
            getCompanyName(job.companyId)?.toLowerCase().includes(searchTerm.toLowerCase());
        const matchesStatus = statusFilter === 'ALL' ||
            (statusFilter === 'Active' && job.active) ||
            (statusFilter === 'Inactive' && !job.active);
        return matchesSearch && matchesStatus;
    });

    // Pagination
    const totalPages = Math.ceil(filteredJobs.length / itemsPerPage);
    const startIndex = (currentPage - 1) * itemsPerPage;
    const paginatedJobs = filteredJobs.slice(startIndex, startIndex + itemsPerPage);

    // Stats
    const stats = {
        total: jobs.length,
        active: jobs.filter(j => j.active).length,
        inactive: jobs.filter(j => !j.active).length
    };

    const handleViewJob = (job) => {
        setSelectedJob(job);
        setShowDetailModal(true);
    };



    const handleEditJob = (job) => {
        setEditingJob(job);
        setShowEditModal(true);
    };



    const handleSubmitEditJob = async (jobData) => {
        try {
            await jobService.updateJob(editingJob.id, jobData);
            setShowEditModal(false);
            setEditingJob(null);
            await fetchJobs(false);
            showToast('Công việc đã được cập nhật thành công!', 'success');
        } catch (error) {
            console.error('Error updating job:', error);
            throw error;
        }
    };

    const handleDeleteJob = (job) => {
        setConfirmModal({
            isOpen: true,
            jobId: job.id,
            action: 'delete',
            title: 'Xóa công việc',
            message: `Bạn có chắc chắn muốn xóa công việc "${job.title}"? Hành động này không thể hoàn tác.`
        });
    };

    const handleConfirmAction = async () => {
        if (!confirmModal.jobId) return;

        try {
            if (confirmModal.action === 'delete') {
                await jobService.deleteJob(confirmModal.jobId);
            }

            setLoading(true);
            await fetchJobs(false);
            setLoading(false);

            setRefreshKey(prev => prev + 1);

            showToast('Công việc đã được xóa thành công!', 'success');
        } catch (error) {
            console.error('Error performing action:', error);
            const errorMessage = error.message || 'Không thể xóa công việc. Vui lòng thử lại.';
            showToast(errorMessage, 'error');
            setLoading(false);
        }

        setConfirmModal(prev => ({ ...prev, isOpen: false, jobId: null }));
    };

    const formatSalary = (min, max) => {
        if (!min && !max) return 'Thỏa thuận';
        if (min && max) return `${min.toLocaleString()} - ${max.toLocaleString()} VNĐ`;
        if (min) return `Từ ${min.toLocaleString()} VNĐ`;
        if (max) return `Đến ${max.toLocaleString()} VNĐ`;
    };

    const formatDate = (dateString) => {
        if (!dateString) return 'N/A';
        return new Date(dateString).toLocaleDateString('vi-VN');
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
                        <button onClick={fetchJobs} className="mt-2 px-4 py-2 bg-red-600 text-white rounded-lg hover:bg-red-700 transition-colors">
                            Thử lại
                        </button>
                    </div>
                )}

                {!loading && !error && (
                    <>
                        {/* Stats Grid */}
                        <div className="grid grid-cols-1 md:grid-cols-3 gap-6 mb-8">
                            <StatCard title="Tổng số công việc" value={stats.total} color="blue" icon={<Briefcase />} />
                            <StatCard title="Đang hoạt động" value={stats.active} color="green" icon={<CheckCircle />} />
                            <StatCard title="Không hoạt động" value={stats.inactive} color="red" icon={<AlertCircle />} />
                        </div>

                        {/* Table Container */}
                        <div className="bg-white rounded-xl shadow-sm border border-gray-100 overflow-hidden">
                            {/* Header & Filters */}
                            <div className="p-6 border-b border-gray-100">
                                <div className="flex flex-col md:flex-row md:items-center md:justify-between gap-4">
                                    <h3 className="font-bold text-gray-800">Danh sách công việc</h3>

                                    <div className="flex flex-col md:flex-row gap-3">
                                        {/* Search */}
                                        <div className="relative">
                                            <Search className="absolute left-3 top-1/2 -translate-y-1/2 text-gray-400" size={18} />
                                            <input
                                                type="text"
                                                placeholder="Tìm kiếm công việc, công ty..."
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

                                    </div>
                                </div>
                            </div>

                            {/* Table */}
                            <div className="overflow-x-auto">
                                <table className="w-full text-left border-collapse">
                                    <thead className="bg-gray-50 text-gray-600 uppercase text-xs font-semibold">
                                        <tr>
                                            <th className="px-6 py-4">Công việc</th>
                                            <th className="px-6 py-4">Công ty</th>
                                            <th className="px-6 py-4">Mức lương</th>
                                            <th className="px-6 py-4">Hạn nộp</th>
                                            <th className="px-6 py-4">Trạng thái</th>
                                            <th className="px-6 py-4">Hành động</th>
                                        </tr>
                                    </thead>
                                    <tbody key={refreshKey} className="divide-y divide-gray-100 text-sm text-gray-700">
                                        {paginatedJobs.map((job) => (
                                            <JobRow
                                                key={job.id}
                                                job={job}
                                                companyName={getCompanyName(job.companyId)}
                                                categoryName={getCategoryName(job.categoryId)}
                                                onView={handleViewJob}
                                                onEdit={handleEditJob}
                                                onDelete={handleDeleteJob}
                                                formatSalary={formatSalary}
                                                formatDate={formatDate}
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
                                    <span>trên {filteredJobs.length} kết quả</span>
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
                {showDetailModal && selectedJob && (
                    <JobDetailModal
                        job={selectedJob}
                        companyName={getCompanyName(selectedJob.companyId)}
                        categoryName={getCategoryName(selectedJob.categoryId)}
                        formatSalary={formatSalary}
                        formatDate={formatDate}
                        onClose={() => setShowDetailModal(false)}
                    />
                )}

                {/* Create Modal */}


                {/* Edit Modal */}
                {showEditModal && editingJob && (
                    <CreateJobModal
                        companies={companies}
                        categories={categories}
                        skills={skills}
                        editMode={true}
                        initialData={editingJob}
                        onClose={() => {
                            setShowEditModal(false);
                            setEditingJob(null);
                        }}
                        onSubmit={handleSubmitEditJob}
                    />
                )}

                {/* Confirm Modal */}
                <ConfirmModal
                    isOpen={confirmModal.isOpen}
                    onClose={() => setConfirmModal(prev => ({ ...prev, isOpen: false }))}
                    onConfirm={handleConfirmAction}
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

const JobRow = ({ job, companyName, categoryName, onView, onEdit, onDelete, formatSalary, formatDate }) => (
    <tr className="hover:bg-gray-50 transition-colors">
        <td className="px-6 py-4">
            <div className="flex items-center gap-3">
                <div className="w-10 h-10 rounded-lg bg-blue-50 flex items-center justify-center shrink-0">
                    <Briefcase className="text-blue-600" size={20} />
                </div>
                <div>
                    <p className="font-medium text-gray-800 line-clamp-1" title={job.title}>{job.title}</p>
                    <p className="text-xs text-gray-500 line-clamp-1">{categoryName}</p>
                </div>
            </div>
        </td>
        <td className="px-6 py-4">
            <div className="flex items-center gap-2">
                <Building2 size={14} className="text-gray-400" />
                <span className="text-gray-700">{companyName}</span>
            </div>
        </td>
        <td className="px-6 py-4 text-gray-600">
            <div className="flex items-center gap-1">
                <DollarSign size={14} className="text-green-500" />
                <span className="text-xs">{formatSalary(job.minSalary, job.maxSalary)}</span>
            </div>
        </td>
        <td className="px-6 py-4 text-gray-600">
            <div className="flex items-center gap-1">
                <Calendar size={14} className="text-orange-500" />
                <span className="text-xs">{formatDate(job.deadline)}</span>
            </div>
        </td>
        <td className="px-6 py-4">
            <span className={`px-3 py-1 rounded-full text-xs font-medium ${job.active ? 'bg-green-100 text-green-700' : 'bg-red-100 text-red-700'
                }`}>
                {job.active ? 'Hoạt động' : 'Không hoạt động'}
            </span>
        </td>
        <td className="px-6 py-4">
            <div className="flex gap-2">
                <button
                    onClick={() => onView(job)}
                    className="p-2 text-blue-600 hover:bg-blue-50 rounded-lg transition-colors"
                    title="Xem chi tiết"
                >
                    <Eye size={18} />
                </button>
                <button
                    onClick={() => onEdit(job)}
                    className="p-2 text-green-600 hover:bg-green-50 rounded-lg transition-colors"
                    title="Chỉnh sửa"
                >
                    <Pencil size={18} />
                </button>
                <button
                    onClick={() => onDelete(job)}
                    className="p-2 text-red-600 hover:bg-red-50 rounded-lg transition-colors"
                    title="Xóa công việc"
                >
                    <Trash2 size={18} />
                </button>
            </div>
        </td>
    </tr>
);

const JobDetailModal = ({ job, companyName, categoryName, formatSalary, formatDate, onClose }) => (
    <div className="fixed inset-0 bg-black/60 backdrop-blur-sm flex items-center justify-center z-50 p-4 animate-fade-in">
        <div className="bg-white rounded-3xl shadow-2xl w-full max-w-2xl overflow-hidden transform transition-all animate-scale-in relative max-h-[90vh] flex flex-col">
            {/* Decorative Background Pattern */}
            <div className="absolute top-0 left-0 w-full h-32 bg-gradient-to-r from-blue-600 to-cyan-600 opacity-10"></div>

            <button onClick={onClose} className="absolute top-4 right-4 p-2 bg-white/80 hover:bg-white rounded-full text-gray-500 hover:text-gray-800 transition-all shadow-sm z-10">
                <X size={20} />
            </button>

            <div className="px-8 pb-8 pt-12 relative overflow-y-auto">
                <div className="flex flex-col items-center mb-8">
                    <div className="w-24 h-24 rounded-2xl bg-white shadow-xl border-4 border-white mb-4 overflow-hidden flex items-center justify-center">
                        <Briefcase className="text-blue-600" size={48} />
                    </div>
                    <h4 className="text-xl font-bold text-gray-900 text-center">{job.title}</h4>
                    <p className="text-sm text-gray-500 mt-1">{companyName}</p>
                    <div className="mt-2">
                        <span className={`px-3 py-1 rounded-full text-xs font-semibold tracking-wide ${job.active ? 'bg-green-100 text-green-700' : 'bg-red-100 text-red-700'
                            }`}>
                            {job.active ? 'Hoạt động' : 'Không hoạt động'}
                        </span>
                    </div>
                </div>

                <div className="bg-gray-50 rounded-2xl p-6 space-y-5">
                    <InfoRow icon={<Briefcase className="text-blue-500" size={18} />} label="Danh mục" value={categoryName} />
                    <InfoRow icon={<MapPin className="text-red-500" size={18} />} label="Địa điểm" value={job.location || 'N/A'} />
                    <InfoRow icon={<DollarSign className="text-green-500" size={18} />} label="Mức lương" value={formatSalary(job.minSalary, job.maxSalary)} />
                    <InfoRow icon={<Calendar className="text-orange-500" size={18} />} label="Hạn nộp" value={formatDate(job.deadline)} />
                    <InfoRow icon={<Clock className="text-purple-500" size={18} />} label="Ngày đăng" value={formatDate(job.createdAt)} />

                    {job.description && (
                        <div className="pt-4 border-t border-gray-200">
                            <p className="text-xs text-gray-500 font-medium uppercase tracking-wider mb-2">Mô tả công việc</p>
                            <p className="text-sm text-gray-700 whitespace-pre-wrap">{job.description}</p>
                        </div>
                    )}
                </div>
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
            <p className="text-sm font-semibold text-gray-900 truncate">{value || 'N/A'}</p>
        </div>
    </div>
);

const CreateJobModal = ({ companies, categories, skills, editMode = false, initialData = null, onClose, onSubmit }) => {
    const [formData, setFormData] = useState({
        companyId: initialData?.companyId || '',
        title: initialData?.title || '',
        description: initialData?.description || '',
        status: initialData?.status || 'ACTIVE',
        salaryMin: initialData?.salaryMin || '',
        salaryMax: initialData?.salaryMax || '',
        jobType: initialData?.jobType || 'FULL_TIME',
        experienceLevel: initialData?.experienceLevel || 'ANY',
        requiredYearsOfExpMin: initialData?.requiredYearsOfExpMin || '',
        requiredYearsOfExpMax: initialData?.requiredYearsOfExpMax || '',
        jdFile: null,
        categoryIds: initialData?.categoryIds || [],
        skillIds: initialData?.skillIds || [],
        location: initialData?.location || '',
        expiryDate: initialData?.expiryDate ? initialData.expiryDate.split('T')[0] : ''
    });
    const [errors, setErrors] = useState({});
    const [submitting, setSubmitting] = useState(false);
    const [submitError, setSubmitError] = useState('');
    const [fileName, setFileName] = useState('');

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
            setFormData(prev => ({ ...prev, jdFile: file }));
            setFileName(file.name);
            if (errors.jdFile) {
                setErrors(prev => ({ ...prev, jdFile: '' }));
            }
        }
    };

    const handleMultiSelect = (name, value) => {
        const currentValues = formData[name];
        const newValues = currentValues.includes(value)
            ? currentValues.filter(v => v !== value)
            : [...currentValues, value];
        setFormData(prev => ({ ...prev, [name]: newValues }));
        if (errors[name]) {
            setErrors(prev => ({ ...prev, [name]: '' }));
        }
    };

    const validateForm = () => {
        const newErrors = {};
        if (!formData.title.trim()) newErrors.title = 'Tiêu đề công việc là bắt buộc';
        if (!formData.companyId) newErrors.companyId = 'Vui lòng chọn công ty';
        if (!formData.description.trim()) newErrors.description = 'Mô tả công việc là bắt buộc';
        if (!formData.location.trim()) newErrors.location = 'Địa điểm là bắt buộc';
        if (!formData.expiryDate) newErrors.expiryDate = 'Ngày hết hạn là bắt buộc';
        if (formData.categoryIds.length === 0) newErrors.categoryIds = 'Vui lòng chọn ít nhất một danh mục';
        if (formData.skillIds.length === 0) newErrors.skillIds = 'Vui lòng chọn ít nhất một kỹ năng';

        // Validate salary
        if (formData.salaryMin && formData.salaryMax) {
            if (Number(formData.salaryMin) > Number(formData.salaryMax)) {
                newErrors.salaryMin = 'Lương tối thiểu không được lớn hơn lương tối đa';
            }
        }

        // Validate years of experience
        if (formData.requiredYearsOfExpMin && formData.requiredYearsOfExpMax) {
            if (Number(formData.requiredYearsOfExpMin) > Number(formData.requiredYearsOfExpMax)) {
                newErrors.requiredYearsOfExpMin = 'Số năm kinh nghiệm tối thiểu không được lớn hơn tối đa';
            }
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
            const jobData = {
                companyId: formData.companyId,
                title: formData.title,
                description: formData.description,
                status: formData.status,
                salaryMin: formData.salaryMin ? Number(formData.salaryMin) : undefined,
                salaryMax: formData.salaryMax ? Number(formData.salaryMax) : undefined,
                jobType: formData.jobType,
                experienceLevel: formData.experienceLevel,
                requiredYearsOfExpMin: formData.requiredYearsOfExpMin ? Number(formData.requiredYearsOfExpMin) : undefined,
                requiredYearsOfExpMax: formData.requiredYearsOfExpMax ? Number(formData.requiredYearsOfExpMax) : undefined,
                jdFile: formData.jdFile,
                categoryIds: formData.categoryIds,
                skillIds: formData.skillIds,
                location: formData.location,
                expiryDate: formData.expiryDate
            };
            await onSubmit(jobData);
        } catch (error) {
            setSubmitError(error.message || 'Có lỗi xảy ra khi tạo công việc');
        } finally {
            setSubmitting(false);
        }
    };

    return (
        <div className="fixed inset-0 bg-black/60 backdrop-blur-sm flex items-center justify-center z-50 p-4 animate-fade-in">
            <div className="bg-white rounded-3xl shadow-2xl w-full max-w-3xl overflow-hidden transform transition-all animate-scale-in relative max-h-[90vh] flex flex-col">
                {/* Header */}
                <div className="bg-gradient-to-r from-blue-600 to-cyan-600 px-8 py-6 relative">
                    <button
                        onClick={onClose}
                        className="absolute top-4 right-4 p-2 bg-white/20 hover:bg-white/30 rounded-full text-white transition-all"
                    >
                        <X size={20} />
                    </button>
                    <h3 className="text-2xl font-bold text-white flex items-center gap-3">
                        <Briefcase size={28} />
                        {editMode ? 'Chỉnh sửa công việc' : 'Tạo công việc mới'}
                    </h3>
                </div>

                {/* Form */}
                <form onSubmit={handleSubmit} className="flex-1 overflow-y-auto px-8 py-6">
                    {submitError && (
                        <div className="mb-4 p-3 bg-red-50 border border-red-200 rounded-lg text-red-700 text-sm">
                            {submitError}
                        </div>
                    )}

                    <div className="space-y-5">
                        {/* Title */}
                        <div>
                            <label className="block text-sm font-semibold text-gray-700 mb-2">
                                Tiêu đề công việc <span className="text-red-500">*</span>
                            </label>
                            <input
                                type="text"
                                name="title"
                                value={formData.title}
                                onChange={handleInputChange}
                                className={`w-full px-4 py-2.5 rounded-lg border ${errors.title ? 'border-red-500' : 'border-gray-300'} focus:outline-none focus:ring-2 focus:ring-blue-500`}
                                placeholder="Nhập tiêu đề công việc"
                            />
                            {errors.title && <p className="mt-1 text-sm text-red-500">{errors.title}</p>}
                        </div>

                        {/* Company */}
                        <div>
                            <label className="block text-sm font-semibold text-gray-700 mb-2">
                                Công ty <span className="text-red-500">*</span>
                            </label>
                            <select
                                name="companyId"
                                value={formData.companyId}
                                onChange={handleInputChange}
                                className={`w-full px-4 py-2.5 rounded-lg border ${errors.companyId ? 'border-red-500' : 'border-gray-300'} focus:outline-none focus:ring-2 focus:ring-blue-500`}
                            >
                                <option value="">Chọn công ty</option>
                                {companies.map(company => (
                                    <option key={company.id} value={company.id}>{company.name}</option>
                                ))}
                            </select>
                            {errors.companyId && <p className="mt-1 text-sm text-red-500">{errors.companyId}</p>}
                        </div>

                        {/* Description */}
                        <div>
                            <label className="block text-sm font-semibold text-gray-700 mb-2">
                                Mô tả công việc <span className="text-red-500">*</span>
                            </label>
                            <textarea
                                name="description"
                                value={formData.description}
                                onChange={handleInputChange}
                                rows={4}
                                className={`w-full px-4 py-2.5 rounded-lg border ${errors.description ? 'border-red-500' : 'border-gray-300'} focus:outline-none focus:ring-2 focus:ring-blue-500 resize-none`}
                                placeholder="Nhập mô tả chi tiết về công việc"
                            />
                            {errors.description && <p className="mt-1 text-sm text-red-500">{errors.description}</p>}
                        </div>

                        {/* Status, Job Type, Experience Level */}
                        <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
                            <div>
                                <label className="block text-sm font-semibold text-gray-700 mb-2">
                                    Trạng thái
                                </label>
                                <select
                                    name="status"
                                    value={formData.status}
                                    onChange={handleInputChange}
                                    className="w-full px-4 py-2.5 rounded-lg border border-gray-300 focus:outline-none focus:ring-2 focus:ring-blue-500"
                                >
                                    <option value="ACTIVE">Đang hoạt động</option>
                                    <option value="INACTIVE">Không hoạt động</option>
                                    <option value="CLOSED">Đã đóng</option>
                                </select>
                            </div>

                            <div>
                                <label className="block text-sm font-semibold text-gray-700 mb-2">
                                    Loại công việc
                                </label>
                                <select
                                    name="jobType"
                                    value={formData.jobType}
                                    onChange={handleInputChange}
                                    className="w-full px-4 py-2.5 rounded-lg border border-gray-300 focus:outline-none focus:ring-2 focus:ring-blue-500"
                                >
                                    <option value="FULL_TIME">Toàn thời gian</option>
                                    <option value="PART_TIME">Bán thời gian</option>
                                    <option value="CONTRACT">Hợp đồng</option>
                                    <option value="REMOTE">Từ xa</option>
                                </select>
                            </div>

                            <div>
                                <label className="block text-sm font-semibold text-gray-700 mb-2">
                                    Cấp độ kinh nghiệm
                                </label>
                                <select
                                    name="experienceLevel"
                                    value={formData.experienceLevel}
                                    onChange={handleInputChange}
                                    className="w-full px-4 py-2.5 rounded-lg border border-gray-300 focus:outline-none focus:ring-2 focus:ring-blue-500"
                                >
                                    <option value="ANY">Tất cả</option>
                                    <option value="INTERN">Thực tập sinh</option>
                                    <option value="FRESHER">Fresher</option>
                                    <option value="JUNIOR">Junior</option>
                                    <option value="SENIOR">Senior</option>
                                    <option value="PRINCIPAL">Principal</option>
                                    <option value="MANAGER">Manager</option>
                                </select>
                            </div>
                        </div>

                        {/* Salary Range */}
                        <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                            <div>
                                <label className="block text-sm font-semibold text-gray-700 mb-2">
                                    Lương tối thiểu (VNĐ)
                                </label>
                                <input
                                    type="number"
                                    name="salaryMin"
                                    value={formData.salaryMin}
                                    onChange={handleInputChange}
                                    className={`w-full px-4 py-2.5 rounded-lg border ${errors.salaryMin ? 'border-red-500' : 'border-gray-300'} focus:outline-none focus:ring-2 focus:ring-blue-500`}
                                    placeholder="Nhập lương tối thiểu"
                                />
                                {errors.salaryMin && <p className="mt-1 text-sm text-red-500">{errors.salaryMin}</p>}
                            </div>

                            <div>
                                <label className="block text-sm font-semibold text-gray-700 mb-2">
                                    Lương tối đa (VNĐ)
                                </label>
                                <input
                                    type="number"
                                    name="salaryMax"
                                    value={formData.salaryMax}
                                    onChange={handleInputChange}
                                    className={`w-full px-4 py-2.5 rounded-lg border ${errors.salaryMax ? 'border-red-500' : 'border-gray-300'} focus:outline-none focus:ring-2 focus:ring-blue-500`}
                                    placeholder="Nhập lương tối đa"
                                />
                                {errors.salaryMax && <p className="mt-1 text-sm text-red-500">{errors.salaryMax}</p>}
                            </div>
                        </div>

                        {/* Years of Experience */}
                        <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                            <div>
                                <label className="block text-sm font-semibold text-gray-700 mb-2">
                                    Số năm kinh nghiệm tối thiểu
                                </label>
                                <input
                                    type="number"
                                    name="requiredYearsOfExpMin"
                                    value={formData.requiredYearsOfExpMin}
                                    onChange={handleInputChange}
                                    className={`w-full px-4 py-2.5 rounded-lg border ${errors.requiredYearsOfExpMin ? 'border-red-500' : 'border-gray-300'} focus:outline-none focus:ring-2 focus:ring-blue-500`}
                                    placeholder="Số năm tối thiểu"
                                    min="0"
                                />
                                {errors.requiredYearsOfExpMin && <p className="mt-1 text-sm text-red-500">{errors.requiredYearsOfExpMin}</p>}
                            </div>

                            <div>
                                <label className="block text-sm font-semibold text-gray-700 mb-2">
                                    Số năm kinh nghiệm tối đa
                                </label>
                                <input
                                    type="number"
                                    name="requiredYearsOfExpMax"
                                    value={formData.requiredYearsOfExpMax}
                                    onChange={handleInputChange}
                                    className={`w-full px-4 py-2.5 rounded-lg border ${errors.requiredYearsOfExpMax ? 'border-red-500' : 'border-gray-300'} focus:outline-none focus:ring-2 focus:ring-blue-500`}
                                    placeholder="Số năm tối đa"
                                    min="0"
                                />
                                {errors.requiredYearsOfExpMax && <p className="mt-1 text-sm text-red-500">{errors.requiredYearsOfExpMax}</p>}
                            </div>
                        </div>

                        {/* Location and Expiry Date */}
                        <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                            <div>
                                <label className="block text-sm font-semibold text-gray-700 mb-2">
                                    Địa điểm <span className="text-red-500">*</span>
                                </label>
                                <input
                                    type="text"
                                    name="location"
                                    value={formData.location}
                                    onChange={handleInputChange}
                                    className={`w-full px-4 py-2.5 rounded-lg border ${errors.location ? 'border-red-500' : 'border-gray-300'} focus:outline-none focus:ring-2 focus:ring-blue-500`}
                                    placeholder="Nhập địa điểm làm việc"
                                />
                                {errors.location && <p className="mt-1 text-sm text-red-500">{errors.location}</p>}
                            </div>

                            <div>
                                <label className="block text-sm font-semibold text-gray-700 mb-2">
                                    Ngày hết hạn <span className="text-red-500">*</span>
                                </label>
                                <input
                                    type="date"
                                    name="expiryDate"
                                    value={formData.expiryDate}
                                    onChange={handleInputChange}
                                    className={`w-full px-4 py-2.5 rounded-lg border ${errors.expiryDate ? 'border-red-500' : 'border-gray-300'} focus:outline-none focus:ring-2 focus:ring-blue-500`}
                                />
                                {errors.expiryDate && <p className="mt-1 text-sm text-red-500">{errors.expiryDate}</p>}
                            </div>
                        </div>

                        {/* JD File Upload */}
                        <div>
                            <label className="block text-sm font-semibold text-gray-700 mb-2">
                                Tệp mô tả công việc (JD)
                            </label>
                            <div className="flex items-center gap-3">
                                <label className="flex-1 cursor-pointer">
                                    <div className={`w-full px-4 py-2.5 rounded-lg border ${errors.jdFile ? 'border-red-500' : 'border-gray-300'} bg-gray-50 hover:bg-gray-100 transition-colors flex items-center gap-2`}>
                                        <Upload size={18} className="text-gray-500" />
                                        <span className="text-sm text-gray-600">
                                            {fileName || 'Chọn tệp...'}
                                        </span>
                                    </div>
                                    <input
                                        type="file"
                                        onChange={handleFileChange}
                                        className="hidden"
                                        accept=".pdf,.doc,.docx"
                                    />
                                </label>
                                {fileName && (
                                    <button
                                        type="button"
                                        onClick={() => {
                                            setFormData(prev => ({ ...prev, jdFile: null }));
                                            setFileName('');
                                        }}
                                        className="p-2 text-red-600 hover:bg-red-50 rounded-lg transition-colors"
                                    >
                                        <X size={18} />
                                    </button>
                                )}
                            </div>
                            {errors.jdFile && <p className="mt-1 text-sm text-red-500">{errors.jdFile}</p>}
                        </div>

                        {/* Categories Multi-Select */}
                        <div>
                            <label className="block text-sm font-semibold text-gray-700 mb-2">
                                Danh mục <span className="text-red-500">*</span>
                            </label>
                            <div className={`max-h-40 overflow-y-auto border ${errors.categoryIds ? 'border-red-500' : 'border-gray-300'} rounded-lg p-3 bg-gray-50`}>
                                {categories.length === 0 ? (
                                    <p className="text-sm text-gray-500">Không có danh mục nào</p>
                                ) : (
                                    <div className="space-y-2">
                                        {categories.map(category => (
                                            <label key={category.id} className="flex items-center gap-2 cursor-pointer hover:bg-gray-100 p-2 rounded">
                                                <input
                                                    type="checkbox"
                                                    checked={formData.categoryIds.includes(category.id)}
                                                    onChange={() => handleMultiSelect('categoryIds', category.id)}
                                                    className="w-4 h-4 text-blue-600 rounded focus:ring-2 focus:ring-blue-500"
                                                />
                                                <span className="text-sm text-gray-700">{category.name}</span>
                                            </label>
                                        ))}
                                    </div>
                                )}
                            </div>
                            {errors.categoryIds && <p className="mt-1 text-sm text-red-500">{errors.categoryIds}</p>}
                            {formData.categoryIds.length > 0 && (
                                <p className="mt-1 text-xs text-gray-500">Đã chọn: {formData.categoryIds.length} danh mục</p>
                            )}
                        </div>

                        {/* Skills Multi-Select */}
                        <div>
                            <label className="block text-sm font-semibold text-gray-700 mb-2">
                                Kỹ năng <span className="text-red-500">*</span>
                            </label>
                            <div className={`max-h-40 overflow-y-auto border ${errors.skillIds ? 'border-red-500' : 'border-gray-300'} rounded-lg p-3 bg-gray-50`}>
                                {skills.length === 0 ? (
                                    <p className="text-sm text-gray-500">Không có kỹ năng nào</p>
                                ) : (
                                    <div className="space-y-2">
                                        {skills.map(skill => (
                                            <label key={skill.id} className="flex items-center gap-2 cursor-pointer hover:bg-gray-100 p-2 rounded">
                                                <input
                                                    type="checkbox"
                                                    checked={formData.skillIds.includes(skill.id)}
                                                    onChange={() => handleMultiSelect('skillIds', skill.id)}
                                                    className="w-4 h-4 text-blue-600 rounded focus:ring-2 focus:ring-blue-500"
                                                />
                                                <span className="text-sm text-gray-700">{skill.name}</span>
                                            </label>
                                        ))}
                                    </div>
                                )}
                            </div>
                            {errors.skillIds && <p className="mt-1 text-sm text-red-500">{errors.skillIds}</p>}
                            {formData.skillIds.length > 0 && (
                                <p className="mt-1 text-xs text-gray-500">Đã chọn: {formData.skillIds.length} kỹ năng</p>
                            )}
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
                                {editMode ? 'Đang cập nhật...' : 'Đang tạo...'}
                            </>
                        ) : (
                            <>
                                <Plus size={18} />
                                {editMode ? 'Cập nhật công việc' : 'Tạo công việc'}
                            </>
                        )}
                    </button>
                </div>
            </div>
        </div>
    );
};

export default JobManagement;

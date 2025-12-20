import React, { useState, useEffect } from 'react';
import {
    Tags,
    Search,
    ChevronLeft,
    ChevronRight,
    Loader2,
    X,
    Eye,
    Plus,
    Trash2,
    Edit,
    AlertCircle,
    CheckCircle
} from 'lucide-react';
import { skillService } from '../services/skillService';
import { categoryService } from '../services/categoryService';
import Toast from '../components/Toast';
import ConfirmModal from '../components/ConfirmModal';

const SkillCategoryManagement = () => {
    const [activeTab, setActiveTab] = useState('skills'); // 'skills' or 'categories'
    const [skills, setSkills] = useState([]);
    const [categories, setCategories] = useState([]);
    const [loading, setLoading] = useState(true);
    const [error, setError] = useState(null);
    const [searchTerm, setSearchTerm] = useState('');
    const [currentPage, setCurrentPage] = useState(1);
    const [itemsPerPage, setItemsPerPage] = useState(10);
    const [showCreateModal, setShowCreateModal] = useState(false);
    const [showEditModal, setShowEditModal] = useState(false);
    const [editingItem, setEditingItem] = useState(null);
    const [toast, setToast] = useState(null);
    const [refreshKey, setRefreshKey] = useState(0);
    const [confirmModal, setConfirmModal] = useState({
        isOpen: false,
        itemId: null,
        action: null,
        title: '',
        message: ''
    });

    useEffect(() => {
        fetchData();
    }, []);

    const fetchData = async () => {
        setLoading(true);
        try {
            const [skillsData, categoriesData] = await Promise.all([
                skillService.getAllSkills(),
                categoryService.getAllCategories()
            ]);

            const skillList = Array.isArray(skillsData) ? skillsData : (skillsData.result || []);
            setSkills([...skillList]);

            const categoryList = Array.isArray(categoriesData) ? categoriesData : (categoriesData.result || []);
            setCategories([...categoryList]);
        } catch (err) {
            setError('Không thể tải dữ liệu.');
            console.error(err);
        } finally {
            setLoading(false);
        }
    };

    const showToast = (message, type = 'info') => {
        setToast({ message, type, id: Date.now() });
    };

    // Filter items
    const currentItems = activeTab === 'skills' ? skills : categories;
    const filteredItems = currentItems.filter(item =>
        item.name?.toLowerCase().includes(searchTerm.toLowerCase())
    );

    // Pagination
    const totalPages = Math.ceil(filteredItems.length / itemsPerPage);
    const startIndex = (currentPage - 1) * itemsPerPage;
    const paginatedItems = filteredItems.slice(startIndex, startIndex + itemsPerPage);

    // Stats
    const stats = {
        total: currentItems.length
    };

    const handleCreate = () => {
        setShowCreateModal(true);
    };

    const handleEdit = (item) => {
        setEditingItem(item);
        setShowEditModal(true);
    };

    const handleSubmitNew = async (data) => {
        try {
            if (activeTab === 'skills') {
                await skillService.createSkill(data);
                showToast('Kỹ năng đã được tạo thành công!', 'success');
            } else {
                await categoryService.createCategory(data);
                showToast('Danh mục đã được tạo thành công!', 'success');
            }
            setShowCreateModal(false);
            await fetchData();
        } catch (error) {
            console.error('Error creating item:', error);
            throw error;
        }
    };

    const handleSubmitEdit = async (data) => {
        try {
            if (activeTab === 'skills') {
                await skillService.updateSkill(editingItem.id, data);
                showToast('Kỹ năng đã được cập nhật thành công!', 'success');
            } else {
                await categoryService.updateCategory(editingItem.id, data);
                showToast('Danh mục đã được cập nhật thành công!', 'success');
            }
            setShowEditModal(false);
            setEditingItem(null);
            await fetchData();
        } catch (error) {
            console.error('Error updating item:', error);
            throw error;
        }
    };

    const handleDelete = (item) => {
        setConfirmModal({
            isOpen: true,
            itemId: item.id,
            action: 'delete',
            title: `Xóa ${activeTab === 'skills' ? 'kỹ năng' : 'danh mục'}`,
            message: `Bạn có chắc chắn muốn xóa "${item.name}"? Hành động này không thể hoàn tác.`
        });
    };

    const handleConfirmAction = async () => {
        if (!confirmModal.itemId) return;

        try {
            if (activeTab === 'skills') {
                await skillService.deleteSkill(confirmModal.itemId);
                showToast('Kỹ năng đã được xóa thành công!', 'success');
            } else {
                await categoryService.deleteCategory(confirmModal.itemId);
                showToast('Danh mục đã được xóa thành công!', 'success');
            }

            setLoading(true);
            await fetchData();
            setRefreshKey(prev => prev + 1);
        } catch (error) {
            console.error('Error performing action:', error);
            const errorMessage = error.message || `Không thể xóa ${activeTab === 'skills' ? 'kỹ năng' : 'danh mục'}. Vui lòng thử lại.`;
            showToast(errorMessage, 'error');
            setLoading(false);
        }

        setConfirmModal(prev => ({ ...prev, isOpen: false, itemId: null }));
    };

    return (
        <div className="h-full flex flex-col">
            <div className="flex-1 overflow-y-auto">
                {/* Tabs */}
                <div className="mb-6 border-b border-gray-200">
                    <div className="flex gap-4">
                        <button
                            onClick={() => {
                                setActiveTab('skills');
                                setSearchTerm('');
                                setCurrentPage(1);
                            }}
                            className={`px-6 py-3 font-semibold transition-colors border-b-2 ${activeTab === 'skills'
                                ? 'border-blue-600 text-blue-600'
                                : 'border-transparent text-gray-500 hover:text-gray-700'
                                }`}
                        >
                            Kỹ năng ({skills.length})
                        </button>
                        <button
                            onClick={() => {
                                setActiveTab('categories');
                                setSearchTerm('');
                                setCurrentPage(1);
                            }}
                            className={`px-6 py-3 font-semibold transition-colors border-b-2 ${activeTab === 'categories'
                                ? 'border-blue-600 text-blue-600'
                                : 'border-transparent text-gray-500 hover:text-gray-700'
                                }`}
                        >
                            Danh mục ({categories.length})
                        </button>
                    </div>
                </div>

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
                        <button onClick={fetchData} className="mt-2 px-4 py-2 bg-red-600 text-white rounded-lg hover:bg-red-700 transition-colors">
                            Thử lại
                        </button>
                    </div>
                )}

                {!loading && !error && (
                    <>
                        {/* Stats */}


                        {/* Table Container */}
                        <div className="bg-white rounded-xl shadow-sm border border-gray-100 overflow-hidden">
                            {/* Header & Filters */}
                            <div className="p-6 border-b border-gray-100">
                                <div className="flex flex-col md:flex-row md:items-center md:justify-between gap-4">
                                    <h3 className="font-bold text-gray-800">
                                        Danh sách {activeTab === 'skills' ? 'kỹ năng' : 'danh mục'}
                                    </h3>

                                    <div className="flex flex-col md:flex-row gap-3">
                                        {/* Search */}
                                        <div className="relative">
                                            <Search className="absolute left-3 top-1/2 -translate-y-1/2 text-gray-400" size={18} />
                                            <input
                                                type="text"
                                                placeholder="Tìm kiếm..."
                                                className="pl-10 pr-4 py-2 rounded-lg bg-gray-50 text-sm focus:outline-none focus:ring-2 focus:ring-blue-500 w-full md:w-64"
                                                value={searchTerm}
                                                onChange={(e) => setSearchTerm(e.target.value)}
                                            />
                                        </div>

                                        {/* Create New Button */}
                                        <button
                                            onClick={handleCreate}
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
                                            <th className="px-6 py-4">ID</th>
                                            <th className="px-6 py-4">Tên</th>
                                            {activeTab === 'categories' && (
                                                <th className="px-6 py-4">Kỹ năng</th>
                                            )}
                                            <th className="px-6 py-4">Hành động</th>
                                        </tr>
                                    </thead>
                                    <tbody key={refreshKey} className="divide-y divide-gray-100 text-sm text-gray-700">
                                        {paginatedItems.map((item) => (
                                            <ItemRow
                                                key={item.id}
                                                item={item}
                                                activeTab={activeTab}
                                                allSkills={skills}
                                                onEdit={handleEdit}
                                                onDelete={handleDelete}
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
                                    <span>trên {filteredItems.length} kết quả</span>
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

                {/* Create Modal */}
                {showCreateModal && (
                    <CreateModal
                        type={activeTab}
                        onClose={() => setShowCreateModal(false)}
                        onSubmit={handleSubmitNew}
                    />
                )}

                {/* Edit Modal */}
                {showEditModal && editingItem && (
                    <CreateModal
                        type={activeTab}
                        editMode={true}
                        initialData={editingItem}
                        onClose={() => {
                            setShowEditModal(false);
                            setEditingItem(null);
                        }}
                        onSubmit={handleSubmitEdit}
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

const ItemRow = ({ item, activeTab, allSkills = [], onEdit, onDelete }) => {
    // Get skills for categories - API returns skills array directly
    const skills = activeTab === 'categories' && item.skills ? item.skills : [];
    const displaySkills = skills.slice(0, 3);
    const hasMoreSkills = skills.length > 3;

    return (
        <tr className="hover:bg-gray-50 transition-colors">
            <td className="px-6 py-4">
                <span className="text-xs text-gray-500 font-mono">{item.id?.substring(0, 8)}...</span>
            </td>
            <td className="px-6 py-4">
                <div className="flex items-center gap-3">
                    <div className="w-10 h-10 rounded-lg bg-blue-50 flex items-center justify-center shrink-0">
                        <Tags className="text-blue-600" size={20} />
                    </div>
                    <div>
                        <p className="font-medium text-gray-800">{item.name}</p>
                    </div>
                </div>
            </td>

            {/* Skills column - only for categories */}
            {activeTab === 'categories' && (
                <td className="px-6 py-4">
                    {skills.length > 0 ? (
                        <div className="flex flex-wrap gap-1">
                            {displaySkills.map((skill, idx) => (
                                <span
                                    key={skill.id || idx}
                                    className="inline-block px-2 py-1 bg-gray-100 text-gray-700 rounded text-xs"
                                >
                                    {skill.name}
                                </span>
                            ))}
                            {hasMoreSkills && (
                                <span className="inline-block px-2 py-1 text-gray-500 text-xs">
                                    +{skills.length - 3} khác
                                </span>
                            )}
                        </div>
                    ) : (
                        <span className="text-xs text-gray-400 italic">Chưa có kỹ năng</span>
                    )}
                </td>
            )}

            <td className="px-6 py-4">
                <div className="flex gap-2">
                    <button
                        onClick={() => onEdit(item)}
                        className="p-2 text-green-600 hover:bg-green-50 rounded-lg transition-colors"
                        title="Chỉnh sửa"
                    >
                        <Edit size={18} />
                    </button>
                    <button
                        onClick={() => onDelete(item)}
                        className="p-2 text-red-600 hover:bg-red-50 rounded-lg transition-colors"
                        title="Xóa"
                    >
                        <Trash2 size={18} />
                    </button>
                </div>
            </td>
        </tr>
    );
};

const CreateModal = ({ type, editMode = false, initialData = null, onClose, onSubmit }) => {
    const [formData, setFormData] = useState({
        name: initialData?.name || '',
        // Extract skillIds from skills array if editing category
        skillIds: initialData?.skills ? initialData.skills.map(s => s.id) : []
    });

    // Debug logging
    useEffect(() => {
        console.log('🔍 CreateModal Debug:', {
            editMode,
            type,
            initialData,
            extractedSkillIds: initialData?.skills ? initialData.skills.map(s => s.id) : [],
            formDataSkillIds: formData.skillIds
        });
    }, []);

    const [errors, setErrors] = useState({});
    const [submitting, setSubmitting] = useState(false);
    const [submitError, setSubmitError] = useState('');

    // Skills-related state (only for categories)
    const [allSkills, setAllSkills] = useState([]);
    const [loadingSkills, setLoadingSkills] = useState(false);
    const [skillSearchTerm, setSkillSearchTerm] = useState('');
    const [showSkillDropdown, setShowSkillDropdown] = useState(false);

    // Fetch all skills when modal opens (only for categories)
    useEffect(() => {
        if (type === 'categories') {
            fetchAllSkills();
        }
    }, [type]);

    const fetchAllSkills = async () => {
        setLoadingSkills(true);
        try {
            const skills = await skillService.getAllSkills();
            setAllSkills(Array.isArray(skills) ? skills : []);
            console.log('✅ Fetched skills:', skills);
        } catch (error) {
            console.error('Error fetching skills:', error);
            setAllSkills([]);
        } finally {
            setLoadingSkills(false);
        }
    };

    const handleInputChange = (e) => {
        const { name, value } = e.target;
        setFormData(prev => ({ ...prev, [name]: value }));
        if (errors[name]) {
            setErrors(prev => ({ ...prev, [name]: '' }));
        }
    };

    const handleSkillToggle = (skillId) => {
        setFormData(prev => {
            const skillIds = prev.skillIds || [];
            const isSelected = skillIds.includes(skillId);
            return {
                ...prev,
                skillIds: isSelected
                    ? skillIds.filter(id => id !== skillId)
                    : [...skillIds, skillId]
            };
        });
    };

    const handleRemoveSkill = (skillId) => {
        setFormData(prev => ({
            ...prev,
            skillIds: (prev.skillIds || []).filter(id => id !== skillId)
        }));
    };

    const filteredSkills = allSkills.filter(skill =>
        skill.name?.toLowerCase().includes(skillSearchTerm.toLowerCase())
    );

    const selectedSkills = allSkills.filter(skill =>
        formData.skillIds?.includes(skill.id)
    );

    // Debug selected skills
    useEffect(() => {
        if (type === 'categories' && allSkills.length > 0) {
            console.log('📊 Selected Skills Debug:', {
                allSkillsCount: allSkills.length,
                formDataSkillIds: formData.skillIds,
                selectedSkillsCount: selectedSkills.length,
                selectedSkills: selectedSkills.map(s => ({ id: s.id, name: s.name }))
            });
        }
    }, [formData.skillIds, allSkills]);

    const validateForm = () => {
        const newErrors = {};
        if (!formData.name.trim()) newErrors.name = 'Tên là bắt buộc';
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
            setSubmitError(error.message || `Có lỗi xảy ra khi ${editMode ? 'cập nhật' : 'tạo'} ${type === 'skills' ? 'kỹ năng' : 'danh mục'}`);
        } finally {
            setSubmitting(false);
        }
    };

    return (
        <div className="fixed inset-0 bg-black/60 backdrop-blur-sm flex items-center justify-center z-50 p-4 animate-fade-in">
            <div className="bg-white rounded-3xl shadow-2xl w-full max-w-md overflow-hidden transform transition-all animate-scale-in relative">
                {/* Header */}
                <div className="bg-gradient-to-r from-blue-600 to-cyan-600 px-8 py-6 relative">
                    <button
                        onClick={onClose}
                        className="absolute top-4 right-4 p-2 bg-white/20 hover:bg-white/30 rounded-full text-white transition-all"
                    >
                        <X size={20} />
                    </button>
                    <h3 className="text-2xl font-bold text-white flex items-center gap-3">
                        <Tags size={28} />
                        {editMode ? 'Chỉnh sửa' : 'Tạo'} {type === 'skills' ? 'kỹ năng' : 'danh mục'} {editMode ? '' : 'mới'}
                    </h3>
                </div>

                {/* Form */}
                <form onSubmit={handleSubmit} className="px-8 py-6">
                    {submitError && (
                        <div className="mb-4 p-3 bg-red-50 border border-red-200 rounded-lg text-red-700 text-sm">
                            {submitError}
                        </div>
                    )}

                    <div className="mb-4">
                        <label className="block text-sm font-semibold text-gray-700 mb-2">
                            Tên {type === 'skills' ? 'kỹ năng' : 'danh mục'} <span className="text-red-500">*</span>
                        </label>
                        <input
                            type="text"
                            name="name"
                            value={formData.name}
                            onChange={handleInputChange}
                            className={`w-full px-4 py-2.5 rounded-lg border ${errors.name ? 'border-red-500' : 'border-gray-300'} focus:outline-none focus:ring-2 focus:ring-blue-500`}
                            placeholder={`Nhập tên ${type === 'skills' ? 'kỹ năng' : 'danh mục'}`}
                        />
                        {errors.name && <p className="mt-1 text-sm text-red-500">{errors.name}</p>}
                    </div>

                    {/* Skill Selection - Only for Categories */}
                    {type === 'categories' && (
                        <div className="mb-4">
                            <label className="block text-sm font-semibold text-gray-700 mb-2">
                                Kỹ năng liên quan
                            </label>

                            {/* Search and Dropdown */}
                            <div className="relative">
                                <div className="relative">
                                    <Search className="absolute left-3 top-1/2 -translate-y-1/2 text-gray-400" size={18} />
                                    <input
                                        type="text"
                                        placeholder="Tìm kiếm kỹ năng..."
                                        value={skillSearchTerm}
                                        onChange={(e) => setSkillSearchTerm(e.target.value)}
                                        onFocus={() => setShowSkillDropdown(true)}
                                        className="w-full pl-10 pr-4 py-2.5 rounded-lg border border-gray-300 focus:outline-none focus:ring-2 focus:ring-blue-500"
                                    />
                                </div>

                                {/* Dropdown */}
                                {showSkillDropdown && (
                                    <>
                                        <div
                                            className="fixed inset-0 z-10"
                                            onClick={() => setShowSkillDropdown(false)}
                                        />
                                        <div className="absolute z-20 w-full mt-1 bg-white border border-gray-300 rounded-lg shadow-lg max-h-60 overflow-y-auto">
                                            {loadingSkills ? (
                                                <div className="p-4 text-center text-gray-500">
                                                    <Loader2 className="animate-spin inline-block" size={20} />
                                                    <span className="ml-2">Đang tải...</span>
                                                </div>
                                            ) : filteredSkills.length === 0 ? (
                                                <div className="p-4 text-center text-gray-500">
                                                    Không tìm thấy kỹ năng
                                                </div>
                                            ) : (
                                                filteredSkills.map((skill) => (
                                                    <label
                                                        key={skill.id}
                                                        className="flex items-center px-4 py-2 hover:bg-gray-50 cursor-pointer"
                                                    >
                                                        <input
                                                            type="checkbox"
                                                            checked={formData.skillIds?.includes(skill.id)}
                                                            onChange={() => handleSkillToggle(skill.id)}
                                                            className="w-4 h-4 text-blue-600 border-gray-300 rounded focus:ring-blue-500"
                                                        />
                                                        <span className="ml-3 text-sm text-gray-700">{skill.name}</span>
                                                    </label>
                                                ))
                                            )}
                                        </div>
                                    </>
                                )}
                            </div>

                            {/* Selected Skills */}
                            {selectedSkills.length > 0 && (
                                <div className="mt-3 flex flex-wrap gap-2">
                                    {selectedSkills.map((skill) => (
                                        <span
                                            key={skill.id}
                                            className="inline-flex items-center gap-1 px-3 py-1 bg-blue-50 text-blue-700 rounded-full text-sm"
                                        >
                                            {skill.name}
                                            <button
                                                type="button"
                                                onClick={() => handleRemoveSkill(skill.id)}
                                                className="hover:bg-blue-100 rounded-full p-0.5"
                                            >
                                                <X size={14} />
                                            </button>
                                        </span>
                                    ))}
                                </div>
                            )}

                            <p className="mt-2 text-xs text-gray-500">
                                {selectedSkills.length} kỹ năng đã chọn
                            </p>
                        </div>
                    )}
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
                                {editMode ? 'Cập nhật' : 'Tạo mới'}
                            </>
                        )}
                    </button>
                </div>
            </div>
        </div>
    );
};

export default SkillCategoryManagement;

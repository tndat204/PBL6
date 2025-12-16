import React, { useState, useEffect } from 'react';
import {
    Shield,
    Key,
    Search,
    ChevronLeft,
    ChevronRight,
    Loader2,
    Plus,
    Edit,
    Trash2,
    X,
    AlertCircle
} from 'lucide-react';
import { roleService } from '../services/roleService';
import { permissionService } from '../services/permissionService';
import Toast from '../components/Toast';
import ConfirmModal from '../components/ConfirmModal';

const PermissionsManagement = () => {
    // State for roles
    const [roles, setRoles] = useState([]);
    const [rolesLoading, setRolesLoading] = useState(true);
    const [rolesSearchTerm, setRolesSearchTerm] = useState('');
    const [rolesCurrentPage, setRolesCurrentPage] = useState(1);
    const [rolesPerPage] = useState(10);

    // State for permissions
    const [permissions, setPermissions] = useState([]);
    const [permissionsLoading, setPermissionsLoading] = useState(true);
    const [permissionsSearchTerm, setPermissionsSearchTerm] = useState('');
    const [permissionsCurrentPage, setPermissionsCurrentPage] = useState(1);
    const [permissionsPerPage] = useState(10);

    // Modal states
    const [showRoleModal, setShowRoleModal] = useState(false);
    const [showPermissionModal, setShowPermissionModal] = useState(false);
    const [editingRole, setEditingRole] = useState(null);
    const [editingPermission, setEditingPermission] = useState(null);
    const [confirmModal, setConfirmModal] = useState({
        isOpen: false,
        type: null, // 'role' or 'permission'
        id: null,
        title: '',
        message: ''
    });

    // Toast
    const [toast, setToast] = useState(null);

    useEffect(() => {
        fetchRoles();
        fetchPermissions();
    }, []);

    const fetchRoles = async () => {
        try {
            setRolesLoading(true);
            const data = await roleService.getAllRoles();
            const roleList = Array.isArray(data) ? data : (data.result || []);
            setRoles(roleList);
        } catch (error) {
            console.error('Error fetching roles:', error);
            showToast('Không thể tải danh sách vai trò', 'error');
        } finally {
            setRolesLoading(false);
        }
    };

    const fetchPermissions = async () => {
        try {
            setPermissionsLoading(true);
            const data = await permissionService.getAllPermissions();
            const permissionList = Array.isArray(data) ? data : (data.result || []);
            setPermissions(permissionList);
        } catch (error) {
            console.error('Error fetching permissions:', error);
            showToast('Không thể tải danh sách quyền hạn', 'error');
        } finally {
            setPermissionsLoading(false);
        }
    };

    const showToast = (message, type = 'info') => {
        setToast({ message, type, id: Date.now() });
    };

    // Role handlers
    const handleCreateRole = () => {
        setEditingRole(null);
        setShowRoleModal(true);
    };

    const handleEditRole = (role) => {
        setEditingRole(role);
        setShowRoleModal(true);
    };

    const handleDeleteRole = (role) => {
        setConfirmModal({
            isOpen: true,
            type: 'role',
            id: role.id,
            title: 'Xóa vai trò',
            message: `Bạn có chắc chắn muốn xóa vai trò "${role.name}"? Hành động này không thể hoàn tác.`
        });
    };

    const handleSaveRole = async (roleData) => {
        try {
            if (editingRole) {
                await roleService.updateRole(editingRole.id, roleData);
                showToast('Cập nhật vai trò thành công!', 'success');
            } else {
                await roleService.createRole(roleData);
                showToast('Tạo vai trò mới thành công!', 'success');
            }
            setShowRoleModal(false);
            setEditingRole(null);
            await fetchRoles();
        } catch (error) {
            console.error('Error saving role:', error);
            throw error;
        }
    };

    // Permission handlers
    const handleCreatePermission = () => {
        setEditingPermission(null);
        setShowPermissionModal(true);
    };

    const handleEditPermission = (permission) => {
        setEditingPermission(permission);
        setShowPermissionModal(true);
    };

    const handleDeletePermission = (permission) => {
        setConfirmModal({
            isOpen: true,
            type: 'permission',
            id: permission.id,
            title: 'Xóa quyền hạn',
            message: `Bạn có chắc chắn muốn xóa quyền hạn "${permission.name}"? Hành động này không thể hoàn tác.`
        });
    };

    const handleSavePermission = async (permissionData) => {
        try {
            if (editingPermission) {
                await permissionService.updatePermission(editingPermission.id, permissionData);
                showToast('Cập nhật quyền hạn thành công!', 'success');
            } else {
                await permissionService.createPermission(permissionData);
                showToast('Tạo quyền hạn mới thành công!', 'success');
            }
            setShowPermissionModal(false);
            setEditingPermission(null);
            await fetchPermissions();
        } catch (error) {
            console.error('Error saving permission:', error);
            throw error;
        }
    };

    // Confirm delete handler
    const handleConfirmDelete = async () => {
        try {
            if (confirmModal.type === 'role') {
                await roleService.deleteRole(confirmModal.id);
                showToast('Xóa vai trò thành công!', 'success');
                await fetchRoles();
            } else if (confirmModal.type === 'permission') {
                await permissionService.deletePermission(confirmModal.id);
                showToast('Xóa quyền hạn thành công!', 'success');
                await fetchPermissions();
            }
        } catch (error) {
            console.error('Error deleting:', error);
            showToast('Không thể xóa. Vui lòng thử lại.', 'error');
        } finally {
            setConfirmModal({ ...confirmModal, isOpen: false });
        }
    };

    // Filter and pagination for roles
    const filteredRoles = roles.filter(role =>
        role.name?.toLowerCase().includes(rolesSearchTerm.toLowerCase()) ||
        role.description?.toLowerCase().includes(rolesSearchTerm.toLowerCase())
    );
    const rolesTotalPages = Math.ceil(filteredRoles.length / rolesPerPage);
    const rolesStartIndex = (rolesCurrentPage - 1) * rolesPerPage;
    const paginatedRoles = filteredRoles.slice(rolesStartIndex, rolesStartIndex + rolesPerPage);

    // Filter and pagination for permissions
    const filteredPermissions = permissions.filter(permission =>
        permission.name?.toLowerCase().includes(permissionsSearchTerm.toLowerCase()) ||
        permission.description?.toLowerCase().includes(permissionsSearchTerm.toLowerCase())
    );
    const permissionsTotalPages = Math.ceil(filteredPermissions.length / permissionsPerPage);
    const permissionsStartIndex = (permissionsCurrentPage - 1) * permissionsPerPage;
    const paginatedPermissions = filteredPermissions.slice(permissionsStartIndex, permissionsStartIndex + permissionsPerPage);

    return (
        <div className="h-full flex flex-col">
            <div className="flex-1 overflow-y-auto">
                {/* Stats Grid */}
                <div className="grid grid-cols-1 md:grid-cols-2 gap-6 mb-8">
                    <StatCard
                        title="Tổng số vai trò"
                        value={roles.length}
                        color="blue"
                        icon={<Shield />}
                    />
                    <StatCard
                        title="Tổng số quyền hạn"
                        value={permissions.length}
                        color="purple"
                        icon={<Key />}
                    />
                </div>

                {/* Roles Section */}
                <div className="bg-white rounded-xl shadow-sm border border-gray-100 overflow-hidden mb-8">
                    <div className="p-6 border-b border-gray-100">
                        <div className="flex flex-col md:flex-row md:items-center md:justify-between gap-4">
                            <h3 className="font-bold text-gray-800 flex items-center gap-2">
                                <Shield className="text-blue-600" size={20} />
                                Quản lý vai trò
                            </h3>
                            <div className="flex flex-col md:flex-row gap-3">
                                <div className="relative">
                                    <Search className="absolute left-3 top-1/2 -translate-y-1/2 text-gray-400" size={18} />
                                    <input
                                        type="text"
                                        placeholder="Tìm kiếm vai trò..."
                                        className="pl-10 pr-4 py-2 rounded-lg bg-gray-50 text-sm focus:outline-none focus:ring-2 focus:ring-blue-500 w-full md:w-64"
                                        value={rolesSearchTerm}
                                        onChange={(e) => setRolesSearchTerm(e.target.value)}
                                    />
                                </div>
                                <button
                                    onClick={handleCreateRole}
                                    className="flex items-center gap-2 px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition-colors text-sm font-medium"
                                >
                                    <Plus size={18} />
                                    <span>Thêm vai trò</span>
                                </button>
                            </div>
                        </div>
                    </div>

                    {rolesLoading ? (
                        <div className="flex items-center justify-center h-64">
                            <Loader2 className="animate-spin text-blue-600" size={48} />
                            <span className="ml-3 text-gray-600">Đang tải...</span>
                        </div>
                    ) : (
                        <>
                            <div className="overflow-x-auto">
                                <table className="w-full text-left border-collapse">
                                    <thead className="bg-gray-50 text-gray-600 uppercase text-xs font-semibold">
                                        <tr>
                                            <th className="px-6 py-4">Tên vai trò</th>
                                            <th className="px-6 py-4">Mô tả</th>
                                            <th className="px-6 py-4">Hành động</th>
                                        </tr>
                                    </thead>
                                    <tbody className="divide-y divide-gray-100 text-sm text-gray-700">
                                        {paginatedRoles.length === 0 ? (
                                            <tr>
                                                <td colSpan="3" className="px-6 py-12 text-center text-gray-500">
                                                    <Shield size={48} className="mx-auto mb-3 text-gray-300" />
                                                    <p>Không tìm thấy vai trò nào</p>
                                                </td>
                                            </tr>
                                        ) : (
                                            paginatedRoles.map((role) => (
                                                <RoleRow
                                                    key={role.id}
                                                    role={role}
                                                    onEdit={handleEditRole}
                                                    onDelete={handleDeleteRole}
                                                />
                                            ))
                                        )}
                                    </tbody>
                                </table>
                            </div>

                            {/* Roles Pagination */}
                            {paginatedRoles.length > 0 && (
                                <div className="p-4 border-t border-gray-100 flex items-center justify-between">
                                    <div className="text-sm text-gray-600">
                                        Hiển thị {rolesStartIndex + 1} - {Math.min(rolesStartIndex + rolesPerPage, filteredRoles.length)} trên {filteredRoles.length} kết quả
                                    </div>
                                    <div className="flex items-center gap-2">
                                        <button
                                            onClick={() => setRolesCurrentPage(prev => Math.max(1, prev - 1))}
                                            disabled={rolesCurrentPage === 1}
                                            className="p-2 rounded hover:bg-gray-100 disabled:opacity-50 disabled:cursor-not-allowed"
                                        >
                                            <ChevronLeft size={20} />
                                        </button>
                                        <span className="text-sm text-gray-600">
                                            Trang {rolesCurrentPage} / {rolesTotalPages || 1}
                                        </span>
                                        <button
                                            onClick={() => setRolesCurrentPage(prev => Math.min(rolesTotalPages, prev + 1))}
                                            disabled={rolesCurrentPage === rolesTotalPages || rolesTotalPages === 0}
                                            className="p-2 rounded hover:bg-gray-100 disabled:opacity-50 disabled:cursor-not-allowed"
                                        >
                                            <ChevronRight size={20} />
                                        </button>
                                    </div>
                                </div>
                            )}
                        </>
                    )}
                </div>

                {/* Permissions Section */}
                <div className="bg-white rounded-xl shadow-sm border border-gray-100 overflow-hidden">
                    <div className="p-6 border-b border-gray-100">
                        <div className="flex flex-col md:flex-row md:items-center md:justify-between gap-4">
                            <h3 className="font-bold text-gray-800 flex items-center gap-2">
                                <Key className="text-purple-600" size={20} />
                                Quản lý quyền hạn
                            </h3>
                            <div className="flex flex-col md:flex-row gap-3">
                                <div className="relative">
                                    <Search className="absolute left-3 top-1/2 -translate-y-1/2 text-gray-400" size={18} />
                                    <input
                                        type="text"
                                        placeholder="Tìm kiếm quyền hạn..."
                                        className="pl-10 pr-4 py-2 rounded-lg bg-gray-50 text-sm focus:outline-none focus:ring-2 focus:ring-purple-500 w-full md:w-64"
                                        value={permissionsSearchTerm}
                                        onChange={(e) => setPermissionsSearchTerm(e.target.value)}
                                    />
                                </div>
                                <button
                                    onClick={handleCreatePermission}
                                    className="flex items-center gap-2 px-4 py-2 bg-purple-600 text-white rounded-lg hover:bg-purple-700 transition-colors text-sm font-medium"
                                >
                                    <Plus size={18} />
                                    <span>Thêm quyền hạn</span>
                                </button>
                            </div>
                        </div>
                    </div>

                    {permissionsLoading ? (
                        <div className="flex items-center justify-center h-64">
                            <Loader2 className="animate-spin text-purple-600" size={48} />
                            <span className="ml-3 text-gray-600">Đang tải...</span>
                        </div>
                    ) : (
                        <>
                            <div className="overflow-x-auto">
                                <table className="w-full text-left border-collapse">
                                    <thead className="bg-gray-50 text-gray-600 uppercase text-xs font-semibold">
                                        <tr>
                                            <th className="px-6 py-4">Tên quyền hạn</th>
                                            <th className="px-6 py-4">Mô tả</th>
                                            <th className="px-6 py-4">Hành động</th>
                                        </tr>
                                    </thead>
                                    <tbody className="divide-y divide-gray-100 text-sm text-gray-700">
                                        {paginatedPermissions.length === 0 ? (
                                            <tr>
                                                <td colSpan="3" className="px-6 py-12 text-center text-gray-500">
                                                    <Key size={48} className="mx-auto mb-3 text-gray-300" />
                                                    <p>Không tìm thấy quyền hạn nào</p>
                                                </td>
                                            </tr>
                                        ) : (
                                            paginatedPermissions.map((permission) => (
                                                <PermissionRow
                                                    key={permission.id}
                                                    permission={permission}
                                                    onEdit={handleEditPermission}
                                                    onDelete={handleDeletePermission}
                                                />
                                            ))
                                        )}
                                    </tbody>
                                </table>
                            </div>

                            {/* Permissions Pagination */}
                            {paginatedPermissions.length > 0 && (
                                <div className="p-4 border-t border-gray-100 flex items-center justify-between">
                                    <div className="text-sm text-gray-600">
                                        Hiển thị {permissionsStartIndex + 1} - {Math.min(permissionsStartIndex + permissionsPerPage, filteredPermissions.length)} trên {filteredPermissions.length} kết quả
                                    </div>
                                    <div className="flex items-center gap-2">
                                        <button
                                            onClick={() => setPermissionsCurrentPage(prev => Math.max(1, prev - 1))}
                                            disabled={permissionsCurrentPage === 1}
                                            className="p-2 rounded hover:bg-gray-100 disabled:opacity-50 disabled:cursor-not-allowed"
                                        >
                                            <ChevronLeft size={20} />
                                        </button>
                                        <span className="text-sm text-gray-600">
                                            Trang {permissionsCurrentPage} / {permissionsTotalPages || 1}
                                        </span>
                                        <button
                                            onClick={() => setPermissionsCurrentPage(prev => Math.min(permissionsTotalPages, prev + 1))}
                                            disabled={permissionsCurrentPage === permissionsTotalPages || permissionsTotalPages === 0}
                                            className="p-2 rounded hover:bg-gray-100 disabled:opacity-50 disabled:cursor-not-allowed"
                                        >
                                            <ChevronRight size={20} />
                                        </button>
                                    </div>
                                </div>
                            )}
                        </>
                    )}
                </div>

                {/* Role Modal */}
                {showRoleModal && (
                    <RoleModal
                        role={editingRole}
                        onClose={() => {
                            setShowRoleModal(false);
                            setEditingRole(null);
                        }}
                        onSave={handleSaveRole}
                    />
                )}

                {/* Permission Modal */}
                {showPermissionModal && (
                    <PermissionModal
                        permission={editingPermission}
                        onClose={() => {
                            setShowPermissionModal(false);
                            setEditingPermission(null);
                        }}
                        onSave={handleSavePermission}
                    />
                )}

                {/* Confirm Modal */}
                <ConfirmModal
                    isOpen={confirmModal.isOpen}
                    onClose={() => setConfirmModal({ ...confirmModal, isOpen: false })}
                    onConfirm={handleConfirmDelete}
                    title={confirmModal.title}
                    message={confirmModal.message}
                />

                {/* Toast */}
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

const RoleRow = ({ role, onEdit, onDelete }) => (
    <tr className="hover:bg-gray-50 transition-colors">
        <td className="px-6 py-4">
            <div className="flex items-center gap-2">
                <Shield className="text-blue-600" size={16} />
                <span className="font-medium text-gray-800">{role.name}</span>
            </div>
        </td>
        <td className="px-6 py-4 text-gray-600">
            {role.description || 'Chưa có mô tả'}
        </td>
        <td className="px-6 py-4">
            <div className="flex gap-2">
                <button
                    onClick={() => onEdit(role)}
                    className="p-2 text-blue-600 hover:bg-blue-50 rounded-lg transition-colors"
                    title="Chỉnh sửa"
                >
                    <Edit size={18} />
                </button>
                <button
                    onClick={() => onDelete(role)}
                    className="p-2 text-red-600 hover:bg-red-50 rounded-lg transition-colors"
                    title="Xóa"
                >
                    <Trash2 size={18} />
                </button>
            </div>
        </td>
    </tr>
);

const PermissionRow = ({ permission, onEdit, onDelete }) => (
    <tr className="hover:bg-gray-50 transition-colors">
        <td className="px-6 py-4">
            <div className="flex items-center gap-2">
                <Key className="text-purple-600" size={16} />
                <span className="font-medium text-gray-800">{permission.name}</span>
            </div>
        </td>
        <td className="px-6 py-4 text-gray-600">
            {permission.description || 'Chưa có mô tả'}
        </td>
        <td className="px-6 py-4">
            <div className="flex gap-2">
                <button
                    onClick={() => onEdit(permission)}
                    className="p-2 text-purple-600 hover:bg-purple-50 rounded-lg transition-colors"
                    title="Chỉnh sửa"
                >
                    <Edit size={18} />
                </button>
                <button
                    onClick={() => onDelete(permission)}
                    className="p-2 text-red-600 hover:bg-red-50 rounded-lg transition-colors"
                    title="Xóa"
                >
                    <Trash2 size={18} />
                </button>
            </div>
        </td>
    </tr>
);

const RoleModal = ({ role, onClose, onSave }) => {
    const [formData, setFormData] = useState({
        name: role?.name || '',
        description: role?.description || ''
    });
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

    const validateForm = () => {
        const newErrors = {};
        if (!formData.name.trim()) newErrors.name = 'Tên vai trò là bắt buộc';
        setErrors(newErrors);
        return Object.keys(newErrors).length === 0;
    };

    const handleSubmit = async (e) => {
        e.preventDefault();
        setSubmitError('');

        if (!validateForm()) return;

        setSubmitting(true);
        try {
            await onSave(formData);
        } catch (error) {
            setSubmitError(error.message || 'Có lỗi xảy ra khi lưu vai trò');
        } finally {
            setSubmitting(false);
        }
    };

    return (
        <div className="fixed inset-0 bg-black/60 backdrop-blur-sm flex items-center justify-center z-50 p-4 animate-fade-in">
            <div className="bg-white rounded-3xl shadow-2xl w-full max-w-md overflow-hidden transform transition-all animate-scale-in relative">
                <div className="bg-gradient-to-r from-blue-600 to-cyan-600 px-8 py-6 relative">
                    <button
                        onClick={onClose}
                        className="absolute top-4 right-4 p-2 bg-white/20 hover:bg-white/30 rounded-full text-white transition-all"
                    >
                        <X size={20} />
                    </button>
                    <h3 className="text-2xl font-bold text-white flex items-center gap-3">
                        <Shield size={28} />
                        {role ? 'Chỉnh sửa vai trò' : 'Tạo vai trò mới'}
                    </h3>
                </div>

                <form onSubmit={handleSubmit} className="px-8 py-6">
                    {submitError && (
                        <div className="mb-4 p-3 bg-red-50 border border-red-200 rounded-lg text-red-700 text-sm flex items-center gap-2">
                            <AlertCircle size={16} />
                            {submitError}
                        </div>
                    )}

                    <div className="space-y-4">
                        <div>
                            <label className="block text-sm font-semibold text-gray-700 mb-2">
                                Tên vai trò <span className="text-red-500">*</span>
                            </label>
                            <input
                                type="text"
                                name="name"
                                value={formData.name}
                                onChange={handleInputChange}
                                className={`w-full px-4 py-2.5 rounded-lg border ${errors.name ? 'border-red-500' : 'border-gray-300'} focus:outline-none focus:ring-2 focus:ring-blue-500`}
                                placeholder="Nhập tên vai trò"
                            />
                            {errors.name && <p className="mt-1 text-sm text-red-500">{errors.name}</p>}
                        </div>

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
                                placeholder="Nhập mô tả vai trò"
                            />
                        </div>
                    </div>

                    <div className="mt-6 flex justify-end gap-3">
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
                            disabled={submitting}
                            className="px-6 py-2.5 rounded-lg bg-blue-600 text-white font-medium hover:bg-blue-700 transition-colors disabled:opacity-50 disabled:cursor-not-allowed flex items-center gap-2"
                        >
                            {submitting ? (
                                <>
                                    <Loader2 className="animate-spin" size={18} />
                                    Đang lưu...
                                </>
                            ) : (
                                role ? 'Cập nhật' : 'Tạo mới'
                            )}
                        </button>
                    </div>
                </form>
            </div>
        </div>
    );
};

const PermissionModal = ({ permission, onClose, onSave }) => {
    const [formData, setFormData] = useState({
        name: permission?.name || '',
        description: permission?.description || ''
    });
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

    const validateForm = () => {
        const newErrors = {};
        if (!formData.name.trim()) newErrors.name = 'Tên quyền hạn là bắt buộc';
        setErrors(newErrors);
        return Object.keys(newErrors).length === 0;
    };

    const handleSubmit = async (e) => {
        e.preventDefault();
        setSubmitError('');

        if (!validateForm()) return;

        setSubmitting(true);
        try {
            await onSave(formData);
        } catch (error) {
            setSubmitError(error.message || 'Có lỗi xảy ra khi lưu quyền hạn');
        } finally {
            setSubmitting(false);
        }
    };

    return (
        <div className="fixed inset-0 bg-black/60 backdrop-blur-sm flex items-center justify-center z-50 p-4 animate-fade-in">
            <div className="bg-white rounded-3xl shadow-2xl w-full max-w-md overflow-hidden transform transition-all animate-scale-in relative">
                <div className="bg-gradient-to-r from-purple-600 to-pink-600 px-8 py-6 relative">
                    <button
                        onClick={onClose}
                        className="absolute top-4 right-4 p-2 bg-white/20 hover:bg-white/30 rounded-full text-white transition-all"
                    >
                        <X size={20} />
                    </button>
                    <h3 className="text-2xl font-bold text-white flex items-center gap-3">
                        <Key size={28} />
                        {permission ? 'Chỉnh sửa quyền hạn' : 'Tạo quyền hạn mới'}
                    </h3>
                </div>

                <form onSubmit={handleSubmit} className="px-8 py-6">
                    {submitError && (
                        <div className="mb-4 p-3 bg-red-50 border border-red-200 rounded-lg text-red-700 text-sm flex items-center gap-2">
                            <AlertCircle size={16} />
                            {submitError}
                        </div>
                    )}

                    <div className="space-y-4">
                        <div>
                            <label className="block text-sm font-semibold text-gray-700 mb-2">
                                Tên quyền hạn <span className="text-red-500">*</span>
                            </label>
                            <input
                                type="text"
                                name="name"
                                value={formData.name}
                                onChange={handleInputChange}
                                className={`w-full px-4 py-2.5 rounded-lg border ${errors.name ? 'border-red-500' : 'border-gray-300'} focus:outline-none focus:ring-2 focus:ring-purple-500`}
                                placeholder="Nhập tên quyền hạn"
                            />
                            {errors.name && <p className="mt-1 text-sm text-red-500">{errors.name}</p>}
                        </div>

                        <div>
                            <label className="block text-sm font-semibold text-gray-700 mb-2">
                                Mô tả
                            </label>
                            <textarea
                                name="description"
                                value={formData.description}
                                onChange={handleInputChange}
                                rows={3}
                                className="w-full px-4 py-2.5 rounded-lg border border-gray-300 focus:outline-none focus:ring-2 focus:ring-purple-500 resize-none"
                                placeholder="Nhập mô tả quyền hạn"
                            />
                        </div>
                    </div>

                    <div className="mt-6 flex justify-end gap-3">
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
                            disabled={submitting}
                            className="px-6 py-2.5 rounded-lg bg-purple-600 text-white font-medium hover:bg-purple-700 transition-colors disabled:opacity-50 disabled:cursor-not-allowed flex items-center gap-2"
                        >
                            {submitting ? (
                                <>
                                    <Loader2 className="animate-spin" size={18} />
                                    Đang lưu...
                                </>
                            ) : (
                                permission ? 'Cập nhật' : 'Tạo mới'
                            )}
                        </button>
                    </div>
                </form>
            </div>
        </div>
    );
};

export default PermissionsManagement;

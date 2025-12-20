import React, { useState, useEffect } from 'react';
import { X, AlertCircle, UserCheck, Shield, Mail, Briefcase, Calendar, Users, Building2, CreditCard } from 'lucide-react';
import { companyService } from '../services';
import CompanyAutocomplete from './CompanyAutocomplete';

// Helper for form rows
const FormRow = ({ icon, label, children, error }) => (
    <div className="flex items-start gap-4 py-3">
        <div className="w-8 text-gray-500 mt-2 flex justify-center">{icon}</div>
        <div className="flex-1">
            <div className="text-xs font-semibold text-gray-500 mb-1 uppercase tracking-wide">{label}</div>
            {children}
            {error && <p className="text-red-500 text-xs mt-1">{error}</p>}
        </div>
    </div>
);

const CreateUserModal = ({ onClose, onSubmit, user, isEdit = false }) => {
    const [formData, setFormData] = useState({
        role: 'USER', // Default role
        username: '',
        password: '',
        email: '',
        phone: '',
        fullName: '',
        address: '',
        taxCode: '', // For RECRUITER
        nameCompany: '', // For RECRUITER
        avatarUrl: '',
        birthDate: ''
    });

    const [errors, setErrors] = useState({});
    const [serverError, setServerError] = useState(null);
    const [companies, setCompanies] = useState([]);
    const [loadingCompanies, setLoadingCompanies] = useState(false);

    // Fetch companies when role is RECRUITER
    useEffect(() => {
        if (formData.role === 'RECRUITER' && !isEdit) {
            fetchCompanies();
        }
    }, [formData.role, isEdit]);

    const fetchCompanies = async () => {
        setLoadingCompanies(true);
        try {
            const response = await companyService.getAllCompanies();
            setCompanies(Array.isArray(response) ? response : []);
        } catch (error) {
            console.error('Error fetching companies:', error);
            setCompanies([]);
        } finally {
            setLoadingCompanies(false);
        }
    };

    useEffect(() => {
        if (isEdit && user) {
            // Check if avatar is a valid image URL
            const isImage = (url) => {
                if (!url) return false;
                return /\.(jpg|jpeg|png|gif|webp|svg)$/i.test(url);
            };

            setFormData({
                role: user.role || 'USER', // Set existing role
                username: user.username || '',
                password: '', // Password is empty by default in edit mode
                email: user.email || '',
                phone: user.phone || '',
                fullName: user.name || '',
                address: user.address || '',
                taxCode: user.taxCode || '',
                nameCompany: user.nameCompany || '',
                avatarUrl: isImage(user.avatar) ? user.avatar : '', // Only set if it looks like an image
                birthDate: user.birthDate ? new Date(user.birthDate).toISOString().split('T')[0] : ''
            });
        }
    }, [isEdit, user]);

    const handleChange = (e) => {
        const { name, value } = e.target;
        setFormData(prev => ({
            ...prev,
            [name]: value
        }));
        if (errors[name]) {
            setErrors(prev => ({
                ...prev,
                [name]: ''
            }));
        }
    };

    const validateForm = () => {
        const newErrors = {};
        if (!formData.username.trim()) newErrors.username = 'Tên đăng nhập là bắt buộc';

        // Password is required only in create mode, or if user entered something in edit mode
        if (!isEdit && !formData.password.trim()) {
            newErrors.password = 'Mật khẩu là bắt buộc';
        }
        if (formData.password && formData.password.length < 6) {
            newErrors.password = 'Mật khẩu phải có ít nhất 6 ký tự';
        }

        if (!formData.email.trim()) newErrors.email = 'Email là bắt buộc';
        if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(formData.email)) newErrors.email = 'Email không hợp lệ';
        if (!formData.fullName.trim()) newErrors.fullName = 'Họ tên là bắt buộc';

        setErrors(newErrors);
        return Object.keys(newErrors).length === 0;
    };

    const handleSubmit = async (e) => {
        e.preventDefault();
        setServerError(null);
        if (validateForm()) {
            try {
                const submitData = {
                    ...formData,
                    birthDate: formData.birthDate ? new Date(formData.birthDate).toISOString() : new Date().toISOString()
                };

                // Remove password if empty in edit mode
                if (isEdit && !submitData.password) {
                    delete submitData.password;
                }

                // Remove taxCode and nameCompany if role is not RECRUITER
                // Backend uses these fields to determine if user is RECRUITER
                if (formData.role !== 'RECRUITER') {
                    delete submitData.taxCode;
                    delete submitData.nameCompany;
                }

                // Remove role field as backend doesn't accept it
                delete submitData.role;

                await onSubmit(submitData);
            } catch (err) {
                setServerError(err.message || 'Có lỗi xảy ra');
            }
        }
    };

    return (
        <div className="fixed inset-0 bg-black/40 flex items-center justify-center z-50 p-4 backdrop-blur-sm">
            <div className="bg-white rounded-2xl shadow-2xl w-full max-w-2xl overflow-hidden flex flex-col max-h-[90vh]">

                {/* Header */}
                <div className="px-8 py-6 border-b border-gray-100 flex items-center justify-between bg-white sticky top-0 z-10">
                    <h3 className="text-xl font-semibold text-gray-800">
                        {isEdit ? 'Cập nhật thông tin người dùng' : 'Tạo người dùng mới'}
                    </h3>
                    <button onClick={onClose} className="text-gray-400 hover:text-gray-600 transition-colors">
                        <X size={24} />
                    </button>
                </div>

                {/* Body */}
                <div className="flex-1 overflow-y-auto px-8 py-6">
                    <form id="create-user-form" onSubmit={handleSubmit} className="space-y-2" autoComplete="off">

                        {/* Server Error */}
                        {serverError && (
                            <div className="mb-6 p-4 bg-red-50 border border-red-100 text-red-600 rounded-xl text-sm flex items-center gap-3">
                                <AlertCircle size={18} />
                                <span>{serverError}</span>
                            </div>
                        )}

                        {/* Main Title Input (Full Name) */}
                        <div className="mb-8">
                            <input
                                type="text"
                                name="fullName"
                                value={formData.fullName}
                                onChange={handleChange}
                                placeholder="Nhập họ và tên"
                                className="w-full text-3xl font-medium text-gray-800 placeholder-gray-300 border-b-2 border-gray-100 focus:border-blue-500 focus:outline-none py-2 transition-colors"
                                autoFocus={!isEdit}
                                autoComplete="off"
                            />
                            {errors.fullName && <p className="text-red-500 text-sm mt-2">{errors.fullName}</p>}
                        </div>

                        {/* Role Selector - Only in Create Mode */}
                        {!isEdit && (
                            <div className="mb-6 p-4 bg-blue-50 border border-blue-100 rounded-xl">
                                <label className="block text-sm font-semibold text-blue-900 mb-2">
                                    Vai trò <span className="text-red-500">*</span>
                                </label>
                                <select
                                    name="role"
                                    value={formData.role}
                                    onChange={handleChange}
                                    className="w-full px-4 py-2.5 rounded-lg border border-blue-200 bg-white focus:outline-none focus:ring-2 focus:ring-blue-500 text-gray-700"
                                >
                                    <option value="USER">Ứng viên (USER)</option>
                                    <option value="RECRUITER">Nhà tuyển dụng (RECRUITER)</option>
                                    <option value="ADMIN">Quản trị viên (ADMIN)</option>
                                </select>
                                <p className="text-xs text-blue-700 mt-2">
                                    {formData.role === 'USER' && '💼 Người dùng có thể tìm việc và nộp đơn ứng tuyển'}
                                    {formData.role === 'RECRUITER' && '🏢 Nhà tuyển dụng có thể đăng tin và quản lý tuyển dụng'}
                                    {formData.role === 'ADMIN' && '⚙️ Quản trị viên có toàn quyền quản lý hệ thống'}
                                </p>
                            </div>
                        )}

                        {/* Show current role in Edit Mode */}
                        {isEdit && (
                            <div className="mb-6 p-4 bg-gray-50 border border-gray-200 rounded-xl">
                                <label className="block text-sm font-semibold text-gray-700 mb-2">
                                    Vai trò hiện tại
                                </label>
                                <div className="px-4 py-2.5 rounded-lg bg-gray-100 text-gray-700 font-medium">
                                    {formData.role === 'USER' && '💼 Ứng viên (USER)'}
                                    {formData.role === 'RECRUITER' && '🏢 Nhà tuyển dụng (RECRUITER)'}
                                    {formData.role === 'ADMIN' && '⚙️ Quản trị viên (ADMIN)'}
                                </div>
                                <p className="text-xs text-gray-500 mt-2">
                                    Vai trò không thể thay đổi trong chế độ chỉnh sửa
                                </p>
                            </div>
                        )}

                        {/* Form Fields */}
                        <div className="space-y-2">
                            {!isEdit && (
                                <FormRow icon={<UserCheck size={20} />} label="Tên đăng nhập" error={errors.username}>
                                    <input
                                        type="text"
                                        name="username"
                                        value={formData.username}
                                        onChange={handleChange}
                                        className="w-full bg-gray-50 hover:bg-gray-100 focus:bg-white border border-transparent focus:border-blue-500 rounded-lg px-3 py-2 text-gray-700 transition-all outline-none"
                                        placeholder="username"
                                        autoComplete="off"
                                    />
                                </FormRow>
                            )}

                            <FormRow icon={<Shield size={20} />} label={isEdit ? "Mật khẩu mới (để trống nếu không đổi)" : "Mật khẩu"} error={errors.password}>
                                <input
                                    type="password"
                                    name="password"
                                    value={formData.password}
                                    onChange={handleChange}
                                    className="w-full bg-gray-50 hover:bg-gray-100 focus:bg-white border border-transparent focus:border-blue-500 rounded-lg px-3 py-2 text-gray-700 transition-all outline-none"
                                    placeholder="••••••••"
                                    autoComplete="new-password"
                                />
                            </FormRow>

                            {!isEdit && (
                                <FormRow icon={<Mail size={20} />} label="Email" error={errors.email}>
                                    <input
                                        type="email"
                                        name="email"
                                        value={formData.email}
                                        onChange={handleChange}
                                        className="w-full bg-gray-50 hover:bg-gray-100 focus:bg-white border border-transparent focus:border-blue-500 rounded-lg px-3 py-2 text-gray-700 transition-all outline-none"
                                        placeholder="example@email.com"
                                    />
                                </FormRow>
                            )}

                            {/* RECRUITER-specific fields */}
                            {formData.role === 'RECRUITER' && !isEdit && (
                                <>
                                    <FormRow icon={<Building2 size={20} />} label="Tên công ty" error={errors.nameCompany}>
                                        {loadingCompanies ? (
                                            <div className="text-sm text-gray-500 py-2">Đang tải danh sách công ty...</div>
                                        ) : (
                                            <CompanyAutocomplete
                                                companies={companies}
                                                value={formData.nameCompany}
                                                taxCode={formData.taxCode}
                                                onChange={(value) => {
                                                    setFormData(prev => ({ ...prev, nameCompany: value }));
                                                    if (errors.nameCompany) {
                                                        setErrors(prev => ({ ...prev, nameCompany: '' }));
                                                    }
                                                }}
                                                onSelect={(company) => {
                                                    setFormData(prev => ({
                                                        ...prev,
                                                        nameCompany: company.name,
                                                        taxCode: company.taxCode
                                                    }));
                                                    if (errors.nameCompany) setErrors(prev => ({ ...prev, nameCompany: '' }));
                                                    if (errors.taxCode) setErrors(prev => ({ ...prev, taxCode: '' }));
                                                }}
                                                placeholder="Gõ để tìm hoặc tạo mới..."
                                            />
                                        )}
                                    </FormRow>

                                    <FormRow icon={<CreditCard size={20} />} label="Mã số thuế" error={errors.taxCode}>
                                        <input
                                            type="text"
                                            name="taxCode"
                                            value={formData.taxCode}
                                            onChange={handleChange}
                                            className="w-full bg-gray-50 hover:bg-gray-100 focus:bg-white border border-transparent focus:border-blue-500 rounded-lg px-3 py-2 text-gray-700 transition-all outline-none"
                                            placeholder="0123456789"
                                        />
                                    </FormRow>
                                </>
                            )}

                            <FormRow icon={<Calendar size={20} />} label="Ngày sinh">
                                <input
                                    type="date"
                                    name="birthDate"
                                    value={formData.birthDate}
                                    onChange={handleChange}
                                    className="w-full bg-gray-50 hover:bg-gray-100 focus:bg-white border border-transparent focus:border-blue-500 rounded-lg px-3 py-2 text-gray-700 transition-all outline-none"
                                />
                            </FormRow>

                            <FormRow icon={<Users size={20} />} label="Liên hệ">
                                <div className="grid grid-cols-2 gap-3">
                                    <input
                                        type="tel"
                                        name="phone"
                                        value={formData.phone}
                                        onChange={handleChange}
                                        className="bg-gray-50 hover:bg-gray-100 focus:bg-white border border-transparent focus:border-blue-500 rounded-lg px-3 py-2 text-gray-700 transition-all outline-none"
                                        placeholder="Số điện thoại"
                                    />
                                    <input
                                        type="text"
                                        name="address"
                                        value={formData.address}
                                        onChange={handleChange}
                                        className="bg-gray-50 hover:bg-gray-100 focus:bg-white border border-transparent focus:border-blue-500 rounded-lg px-3 py-2 text-gray-700 transition-all outline-none"
                                        placeholder="Địa chỉ"
                                    />
                                </div>
                            </FormRow>

                            {!isEdit && (
                                <FormRow icon={<UserCheck size={20} />} label="Avatar URL">
                                    <input
                                        type="url"
                                        name="avatarUrl"
                                        value={formData.avatarUrl}
                                        onChange={handleChange}
                                        className="w-full bg-gray-50 hover:bg-gray-100 focus:bg-white border border-transparent focus:border-blue-500 rounded-lg px-3 py-2 text-gray-700 transition-all outline-none"
                                        placeholder="https://example.com/avatar.jpg"
                                    />
                                </FormRow>
                            )}
                        </div>


                    </form>
                </div>

                {/* Footer */}
                <div className="px-8 py-5 bg-gray-50 border-t border-gray-100 flex justify-end gap-3">
                    <button
                        type="button"
                        onClick={onClose}
                        className="px-6 py-2.5 rounded-lg text-gray-600 font-medium hover:bg-gray-200 transition-colors"
                    >
                        Hủy bỏ
                    </button>
                    <button
                        type="submit"
                        form="create-user-form"
                        className="px-6 py-2.5 rounded-lg bg-slate-900 text-white font-medium hover:bg-slate-800 transition-all shadow-lg shadow-slate-900/20"
                    >
                        {isEdit ? 'Lưu thay đổi' : 'Tạo người dùng'}
                    </button>
                </div>
            </div>
        </div>
    );
};

export default CreateUserModal;

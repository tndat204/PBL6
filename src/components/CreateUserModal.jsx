import React, { useState, useEffect } from 'react';
import { X, AlertCircle, UserCheck, Shield, Mail, Briefcase, Calendar, Users } from 'lucide-react';

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
        username: '',
        password: '',
        email: '',
        phone: '',
        fullName: '',
        address: '',
        taxCode: '',
        nameCompany: '',
        avatarUrl: '',
        birthDate: ''
    });

    const [errors, setErrors] = useState({});
    const [serverError, setServerError] = useState(null);

    useEffect(() => {
        if (isEdit && user) {
            // Check if avatar is a valid image URL
            const isImage = (url) => {
                if (!url) return false;
                return /\.(jpg|jpeg|png|gif|webp|svg)$/i.test(url);
            };

            setFormData({
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

                            {!isEdit && (
                                <FormRow icon={<Briefcase size={20} />} label="Thông tin công việc">
                                    <div className="grid grid-cols-2 gap-3">
                                        <input
                                            type="text"
                                            name="nameCompany"
                                            value={formData.nameCompany}
                                            onChange={handleChange}
                                            className="bg-gray-50 hover:bg-gray-100 focus:bg-white border border-transparent focus:border-blue-500 rounded-lg px-3 py-2 text-gray-700 transition-all outline-none"
                                            placeholder="Tên công ty"
                                        />
                                        <input
                                            type="text"
                                            name="taxCode"
                                            value={formData.taxCode}
                                            onChange={handleChange}
                                            className="bg-gray-50 hover:bg-gray-100 focus:bg-white border border-transparent focus:border-blue-500 rounded-lg px-3 py-2 text-gray-700 transition-all outline-none"
                                            placeholder="Mã số thuế"
                                        />
                                    </div>
                                </FormRow>
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

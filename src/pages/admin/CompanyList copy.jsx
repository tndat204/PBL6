import React, { useState, useEffect } from 'react';
import * as companyApi from '../../api/CompanyApi';
import {
    FaBuilding,
    FaUsers,
    FaBriefcase,
    FaChartBar,
    FaCog,
    FaPlus,
    FaTimes
} from 'react-icons/fa';

const CompanyList = () => {
    const [activeMenu, setActiveMenu] = useState('company');
    const [isEditModalOpen, setIsEditModalOpen] = useState(false);
    const [isEditMode, setIsEditMode] = useState(false); // false = add mode, true = edit mode
    const [companies, setCompanies] = useState([]);
    const [loading, setLoading] = useState(false);
    const [editFormData, setEditFormData] = useState({
        id: '',
        name: '',
        taxCode: '',
        address: '',
        phone: '',
        email: '',
        description: '',
        active: false,
        logoUrl: ''
    });
    const [errors, setErrors] = useState({});

    const menuItems = [
        { id: 'company', label: 'Company', icon: FaBuilding },
        { id: 'user', label: 'User', icon: FaUsers },
        { id: 'job', label: 'Job', icon: FaBriefcase },
        { id: 'statistics', label: 'Statistics', icon: FaChartBar },
        { id: 'settings', label: 'Settings', icon: FaCog },
    ];

    // Hàm lấy danh sách công ty từ API
    const fetchCompanies = async () => {
        try {
            setLoading(true);
            const token = localStorage.getItem('token');
            if (!token) return;

            const data = await companyApi.getCompanies(token);
            if (data.result) setCompanies(data.result);
            else setCompanies(data);
        } catch (err) {
            console.error(err);
        } finally {
            setLoading(false);
        }
    };    // Gọi API khi component mount
    useEffect(() => {
        fetchCompanies();
    }, []);

    async function uploadCompanyLogo(companyId, file, token) {
        const formData = new FormData();
        formData.append("file", file); // key phải đúng EXACT theo backend

        const res = await fetch(`/api/job/company/logo/${companyId}`, {
            method: "PUT",
            headers: {
                'Authorization': `Bearer ${token}` // KHÔNG set Content-Type!!!
            },
            body: formData
        });

        if (!res.ok) {
            const errText = await res.text();
            console.error("Upload failed response:", errText);
            throw new Error("Upload ảnh thất bại");
        }
    }
    const handleAdd = () => {
        setEditFormData({
            id: '',
            name: '',
            taxCode: '',
            address: '',
            phone: '',
            email: '',
            description: '',
            active: false,
            logoUrl: ''
        });
        setErrors({});
        setIsEditMode(false);
        setIsEditModalOpen(true);
    };

    const handleEdit = (id) => {
        const company = companies.find(c => c.id === id);
        if (company) {
            setEditFormData({
                id: company.id,
                name: company.name || '',
                taxCode: company.taxCode || '',
                address: company.address || '',
                phone: company.phone || '',
                email: company.email || '',
                description: company.description || '',
                active: company.active || false,
                logoUrl: company.logoUrl || ''
            });
            setErrors({});
            setIsEditMode(true);
            setIsEditModalOpen(true);
        }
    };

    const handleCloseModal = () => {
        setIsEditModalOpen(false);
        setIsEditMode(false);
        setErrors({});
        setEditFormData({
            id: '',
            name: '',
            taxCode: '',
            address: '',
            phone: '',
            email: '',
            description: '',
            active: false,
            logoUrl: ''
        });
    };

    const handleInputChange = (e) => {
        const { name, value, type, checked } = e.target;
        setEditFormData(prev => ({
            ...prev,
            [name]: type === 'checkbox' ? checked : value
        }));

        // Clear error khi user bắt đầu nhập
        if (errors[name]) {
            setErrors(prev => {
                const newErrors = { ...prev };
                delete newErrors[name];
                return newErrors;
            });
        }
    };

    // Hàm validate form
    const validateForm = () => {
        const newErrors = {};

        // Validate name
        if (!editFormData.name || editFormData.name.trim() === '') {
            newErrors.name = 'Tên công ty không được để trống';
        } else if (editFormData.name.trim().length < 2) {
            newErrors.name = 'Tên công ty phải có ít nhất 2 ký tự';
        } else if (editFormData.name.trim().length > 200) {
            newErrors.name = 'Tên công ty không được vượt quá 200 ký tự';
        }

        // Validate taxCode
        if (!editFormData.taxCode || editFormData.taxCode.trim() === '') {
            newErrors.taxCode = 'Mã số thuế không được để trống';
        } else {
            const taxCodeRegex = /^[0-9]{10,13}$/;
            if (!taxCodeRegex.test(editFormData.taxCode.trim())) {
                newErrors.taxCode = 'Mã số thuế phải là số và có độ dài từ 10-13 chữ số';
            }
        }

        // Validate address
        if (!editFormData.address || editFormData.address.trim() === '') {
            newErrors.address = 'Địa chỉ không được để trống';
        } else if (editFormData.address.trim().length < 5) {
            newErrors.address = 'Địa chỉ phải có ít nhất 5 ký tự';
        } else if (editFormData.address.trim().length > 500) {
            newErrors.address = 'Địa chỉ không được vượt quá 500 ký tự';
        }

        // Validate phone
        if (!editFormData.phone || editFormData.phone.trim() === '') {
            newErrors.phone = 'Số điện thoại không được để trống';
        } else {
            // Format số điện thoại VN: bắt đầu bằng 0, có 10-11 số
            const phoneRegex = /^0[0-9]{9,10}$/;
            if (!phoneRegex.test(editFormData.phone.trim())) {
                newErrors.phone = 'Số điện thoại không hợp lệ (phải bắt đầu bằng 0 và có 10-11 chữ số)';
            }
        }

        // Validate email
        if (!editFormData.email || editFormData.email.trim() === '') {
            newErrors.email = 'Email không được để trống';
        } else {
            const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
            if (!emailRegex.test(editFormData.email.trim())) {
                newErrors.email = 'Email không đúng định dạng (ví dụ: example@email.com)';
            } else if (editFormData.email.trim().length > 100) {
                newErrors.email = 'Email không được vượt quá 100 ký tự';
            }
        }

        // Validate description (không bắt buộc nhưng nếu có thì phải hợp lệ)
        if (editFormData.description && editFormData.description.length > 1000) {
            newErrors.description = 'Mô tả không được vượt quá 1000 ký tự';
        }

        // Validate logoUrl (không bắt buộc nhưng nếu có thì phải là URL hợp lệ)
        if (editFormData.logoUrl && editFormData.logoUrl.trim() !== '') {
            try {
                new URL(editFormData.logoUrl.trim());
            } catch (e) {
                newErrors.logoUrl = 'URL logo không hợp lệ (phải là URL đầy đủ, ví dụ: https://example.com/logo.png)';
            }
        }

        setErrors(newErrors);
        return Object.keys(newErrors).length === 0;
    };

    const handleSave = async () => {
        const isValid = validateForm();
        if (!isValid) {
            setTimeout(() => {
                const firstErrorField = document.querySelector('.border-red-500')?.getAttribute('name');
                if (firstErrorField) {
                    const element = document.querySelector(`[name="${firstErrorField}"]`);
                    if (element) {
                        element.scrollIntoView({ behavior: 'smooth', block: 'center' });
                        element.focus();
                    }
                }
            }, 100);
            return;
        }

        try {
            const token = localStorage.getItem('token');
            if (!token) return alert('Bạn cần đăng nhập để thực hiện thao tác này!');

            const userStr = localStorage.getItem('user');
            const user = userStr ? JSON.parse(userStr) : null;
            const ownerID = user?.id || user?.userID;
            if (!ownerID) return alert('Không tìm thấy thông tin người dùng. Vui lòng đăng nhập lại!');

            const payload = {
                name: editFormData.name.trim(),
                ownerID,
                taxCode: editFormData.taxCode.trim(),
                address: editFormData.address.trim(),
                phone: editFormData.phone.trim(),
                email: editFormData.email.trim(),
                description: editFormData.description?.trim() || '',
                active: !!editFormData.active,
                logoUrl: editFormData.logoUrl?.trim() || ''
            };

            let companyId = editFormData.id;
            let response;

            if (isEditMode) {
                setLoading(true);
                

                response = await companyApi.updateCompany(companyId, payload, token);
                if (response.status !== 200 && response.status !== 201) {
                    alert('Cập nhật công ty thất bại');
                    return;
                }

            } else {
                response = await companyApi.createCompany(payload, token);
                if (!response.ok) {
                    const errorData = await response.json().catch(() => null);
                    return alert(errorData?.message || 'Tạo công ty thất bại');
                }

                const data = await response.json();
                companyId = data?.id || data?.companyID || data?.data?.id;
            }

            if (editFormData.avatarFile) {
                try {
                    await uploadCompanyLogo(companyId, editFormData.avatarFile, token);
                } catch (err) {
                    console.error(err);
                    alert('Lưu thông tin thành công nhưng upload ảnh thất bại.');
                }
            }

            alert(isEditMode ? 'Cập nhật công ty thành công!' : 'Tạo công ty thành công!');
            handleCloseModal();
            await fetchCompanies();

        } catch (error) {
            console.error('Lỗi khi lưu công ty:', error);
            alert('Lỗi hệ thống, vui lòng thử lại sau.');
        }
    };




    const handleDelete = async (id) => {
        const confirmDelete = window.confirm('Bạn có chắc chắn muốn xóa công ty này?');
        if (!confirmDelete) return;

        try {
            const token = localStorage.getItem('token');
            if (!token) {
                alert('Bạn cần đăng nhập để thực hiện thao tác này!');
                return;
            }

            const response = await companyApi.deleteCompany(id, token);
            if (!response.ok) {
                let errorMessage = `Lỗi ${response.status}: ${response.statusText}`;
                try {
                    const errorData = await response.json();
                    errorMessage = errorData.message || errorData.error || errorMessage;
                } catch { }
                alert(errorMessage);
                return;
            }

            alert('Xóa công ty thành công!');
            await fetchCompanies(); // Refresh danh sách

        } catch (error) {
            console.error('Lỗi khi xóa công ty:', error);
            alert('Có lỗi xảy ra khi xóa công ty. Vui lòng thử lại.');
        }
    };


    return (
        <div className="flex h-screen bg-gray-100">
            {/* Sidebar */}
            <div className="w-64 bg-white shadow-lg">
                <div className="p-6 border-b border-gray-200">
                    <h2 className="text-xl font-bold text-gray-800">Admin Panel</h2>
                </div>
                <nav className="mt-4">
                    {menuItems.map((item) => {
                        const Icon = item.icon;
                        return (
                            <button
                                key={item.id}
                                onClick={() => setActiveMenu(item.id)}
                                className={`w-full flex items-center gap-3 px-6 py-3 text-left transition-colors ${activeMenu === item.id
                                    ? 'bg-blue-50 text-blue-600 border-r-4 border-blue-600'
                                    : 'text-gray-700 hover:bg-gray-50'
                                    }`}
                            >
                                <Icon className="text-lg" />
                                <span className="font-medium">{item.label}</span>
                            </button>
                        );
                    })}
                </nav>
            </div>

            {/* Main Content */}
            <div className="flex-1 overflow-auto">
                <div className="p-6">
                    <div className="flex justify-between items-center mb-6">
                        <h1 className="text-2xl font-bold text-gray-800">Company List</h1>
                        <button
                            onClick={handleAdd}
                            className="flex items-center gap-2 px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition-colors"
                        >
                            <FaPlus />
                            <span>Thêm</span>
                        </button>
                    </div>

                    {/* Table */}
                    <div className="bg-white rounded-lg shadow overflow-hidden">
                        {loading ? (
                            <div className="text-center py-12 text-gray-500">
                                Đang tải dữ liệu...
                            </div>
                        ) : (
                            <div className="overflow-x-auto">
                                <table className="min-w-full divide-y divide-gray-200">
                                    <thead className="bg-gray-50">
                                        <tr>
                                            <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                                                Logo
                                            </th>
                                            <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                                                Name
                                            </th>
                                            <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                                                Tax Code
                                            </th>
                                            <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                                                Address
                                            </th>
                                            <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                                                Phone
                                            </th>
                                            <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                                                Email
                                            </th>
                                            <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                                                Description
                                            </th>
                                            <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                                                Status
                                            </th>
                                            <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                                                Actions
                                            </th>
                                        </tr>
                                    </thead>
                                    <tbody className="bg-white divide-y divide-gray-200">
                                        {companies.map((company) => (
                                            <tr key={company.id} className="hover:bg-gray-50">
                                                <td className="px-6 py-4 whitespace-nowrap">
                                                    {company.logoUrl ? (
                                                        <img
                                                            src={company.logoUrl}
                                                            alt={company.name}
                                                            className="h-10 w-10 rounded-full object-cover"
                                                        />
                                                    ) : (
                                                        <div className="h-10 w-10 rounded-full bg-gray-200 flex items-center justify-center">
                                                            <FaBuilding className="text-gray-400" />
                                                        </div>
                                                    )}
                                                </td>
                                                <td className="px-6 py-4 whitespace-nowrap">
                                                    <div className="text-sm font-medium text-gray-900">{company.name}</div>
                                                </td>
                                                <td className="px-6 py-4 whitespace-nowrap">
                                                    <div className="text-sm text-gray-500">{company.taxCode}</div>
                                                </td>
                                                <td className="px-6 py-4 whitespace-nowrap">
                                                    <div className="text-sm text-gray-500">{company.address}</div>
                                                </td>
                                                <td className="px-6 py-4 whitespace-nowrap">
                                                    <div className="text-sm text-gray-500">{company.phone}</div>
                                                </td>
                                                <td className="px-6 py-4 whitespace-nowrap">
                                                    <div className="text-sm text-gray-500">{company.email}</div>
                                                </td>
                                                <td className="px-6 py-4">
                                                    <div className="text-sm text-gray-500 max-w-xs truncate" title={company.description}>
                                                        {company.description}
                                                    </div>
                                                </td>
                                                <td className="text-center">
                                                    {company.active ? (
                                                        <button
                                                            onClick={() => deactivateCompany(company.id)}
                                                            className="px-3 py-1 bg-red-500 text-white rounded hover:bg-red-600"
                                                        >
                                                            Deactivate
                                                        </button>
                                                    ) : (
                                                        <button
                                                            onClick={() => activateCompany(company.id)}
                                                            className="px-3 py-1 bg-green-600 text-white rounded hover:bg-green-700"
                                                        >
                                                            Activate
                                                        </button>
                                                    )}
                                                </td>

                                                <td className="px-6 py-4 whitespace-nowrap">
                                                    <div className="flex items-center gap-2">
                                                        <button
                                                            onClick={() => handleEdit(company.id)}
                                                            className="p-2 text-blue-600 hover:bg-blue-50 rounded-lg transition-colors"
                                                            title="Sửa"
                                                        >
                                                            Sửa
                                                        </button>
                                                        <button
                                                            onClick={() => handleDelete(company.id)}
                                                            className="p-2 text-red-600 hover:bg-red-50 rounded-lg transition-colors"
                                                            title="Xóa"
                                                        >
                                                            Xóa
                                                        </button>
                                                    </div>
                                                </td>
                                            </tr>
                                        ))}
                                    </tbody>
                                </table>
                            </div>
                        )}
                    </div>

                    {!loading && companies.length === 0 && (
                        <div className="text-center py-12 text-gray-500">
                            Không có công ty nào
                        </div>
                    )}
                </div>
            </div>

            {/* Edit Modal */}
            {isEditModalOpen && (
                <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
                    <div className="bg-white rounded-lg shadow-xl w-full max-w-2xl max-h-[90vh] overflow-y-auto m-4">
                        {/* Modal Header */}
                        <div className="flex justify-between items-center p-6 border-b border-gray-200">
                            <h2 className="text-xl font-bold text-gray-800">
                                {isEditMode ? 'Chỉnh sửa công ty' : 'Thêm công ty mới'}
                            </h2>
                            <button
                                onClick={handleCloseModal}
                                className="text-gray-400 hover:text-gray-600 transition-colors"
                            >
                                <FaTimes className="text-xl" />
                            </button>
                        </div>

                        {/* Modal Body */}
                        <div className="p-6">
                            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                                {/* Name */}
                                <div className="md:col-span-2">
                                    <label className="block text-sm font-medium text-gray-700 mb-1">
                                        Tên công ty <span className="text-red-500">*</span>
                                    </label>
                                    <input
                                        type="text"
                                        name="name"
                                        value={editFormData.name}
                                        onChange={handleInputChange}
                                        className={`w-full px-3 py-2 border rounded-lg focus:outline-none focus:ring-2 ${errors.name
                                            ? 'border-red-500 focus:ring-red-500'
                                            : 'border-gray-300 focus:ring-blue-500'
                                            }`}
                                        required
                                    />
                                    {errors.name && (
                                        <p className="mt-1 text-sm text-red-600">{errors.name}</p>
                                    )}
                                </div>

                                {/* Tax Code */}
                                <div>
                                    <label className="block text-sm font-medium text-gray-700 mb-1">
                                        Mã số thuế <span className="text-red-500">*</span>
                                    </label>
                                    <input
                                        type="text"
                                        name="taxCode"
                                        value={editFormData.taxCode}
                                        onChange={handleInputChange}
                                        className={`w-full px-3 py-2 border rounded-lg focus:outline-none focus:ring-2 ${errors.taxCode
                                            ? 'border-red-500 focus:ring-red-500'
                                            : 'border-gray-300 focus:ring-blue-500'
                                            }`}
                                        required
                                    />
                                    {errors.taxCode && (
                                        <p className="mt-1 text-sm text-red-600">{errors.taxCode}</p>
                                    )}
                                </div>

                                {/* Phone */}
                                <div>
                                    <label className="block text-sm font-medium text-gray-700 mb-1">
                                        Số điện thoại <span className="text-red-500">*</span>
                                    </label>
                                    <input
                                        type="tel"
                                        name="phone"
                                        value={editFormData.phone}
                                        onChange={handleInputChange}
                                        className={`w-full px-3 py-2 border rounded-lg focus:outline-none focus:ring-2 ${errors.phone
                                            ? 'border-red-500 focus:ring-red-500'
                                            : 'border-gray-300 focus:ring-blue-500'
                                            }`}
                                        required
                                    />
                                    {errors.phone && (
                                        <p className="mt-1 text-sm text-red-600">{errors.phone}</p>
                                    )}
                                </div>

                                {/* Email */}
                                <div>
                                    <label className="block text-sm font-medium text-gray-700 mb-1">
                                        Email <span className="text-red-500">*</span>
                                    </label>
                                    <input
                                        type="email"
                                        name="email"
                                        value={editFormData.email}
                                        onChange={handleInputChange}
                                        className={`w-full px-3 py-2 border rounded-lg focus:outline-none focus:ring-2 ${errors.email
                                            ? 'border-red-500 focus:ring-red-500'
                                            : 'border-gray-300 focus:ring-blue-500'
                                            }`}
                                        required
                                    />
                                    {errors.email && (
                                        <p className="mt-1 text-sm text-red-600">{errors.email}</p>
                                    )}
                                </div>

                                {/* Address */}
                                <div>
                                    <label className="block text-sm font-medium text-gray-700 mb-1">
                                        Địa chỉ <span className="text-red-500">*</span>
                                    </label>
                                    <input
                                        type="text"
                                        name="address"
                                        value={editFormData.address}
                                        onChange={handleInputChange}
                                        className={`w-full px-3 py-2 border rounded-lg focus:outline-none focus:ring-2 ${errors.address
                                            ? 'border-red-500 focus:ring-red-500'
                                            : 'border-gray-300 focus:ring-blue-500'
                                            }`}
                                        required
                                    />
                                    {errors.address && (
                                        <p className="mt-1 text-sm text-red-600">{errors.address}</p>
                                    )}
                                </div>

                                {/* Logo URL */}
                                <div>
                                    <label className="block text-sm font-medium text-gray-700 mb-1">
                                        URL Logo
                                    </label>
                                    <input
                                        type="file"
                                        accept="image/*"
                                        onChange={(e) => setEditFormData({ ...editFormData, avatarFile: e.target.files[0] })}
                                    />

                                    {errors.logoUrl && (
                                        <p className="mt-1 text-sm text-red-600">{errors.logoUrl}</p>
                                    )}
                                </div>

                                {/* Description */}
                                <div className="md:col-span-2">
                                    <label className="block text-sm font-medium text-gray-700 mb-1">
                                        Mô tả
                                    </label>
                                    <textarea
                                        name="description"
                                        value={editFormData.description}
                                        onChange={handleInputChange}
                                        rows="4"
                                        className={`w-full px-3 py-2 border rounded-lg focus:outline-none focus:ring-2 ${errors.description
                                            ? 'border-red-500 focus:ring-red-500'
                                            : 'border-gray-300 focus:ring-blue-500'
                                            }`}
                                        placeholder="Nhập mô tả công ty..."
                                    />
                                    {errors.description && (
                                        <p className="mt-1 text-sm text-red-600">{errors.description}</p>
                                    )}
                                    {!errors.description && editFormData.description && (
                                        <p className="mt-1 text-xs text-gray-500">
                                            {editFormData.description.length}/1000 ký tự
                                        </p>
                                    )}
                                </div>


                            </div>
                        </div>

                        {/* Modal Footer */}
                        <div className="flex justify-end gap-3 p-6 border-t border-gray-200">
                            <button
                                onClick={handleCloseModal}
                                className="px-4 py-2 text-gray-700 bg-gray-100 rounded-lg hover:bg-gray-200 transition-colors"
                            >
                                Hủy
                            </button>
                            <button
                                onClick={handleSave}
                                className="px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition-colors"
                            >
                                Lưu
                            </button>
                        </div>
                    </div>
                </div>
            )}
        </div>
    );
};

export default CompanyList;

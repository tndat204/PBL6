import React, { useState } from 'react';
import AdminLayout from '../../layouts/AdminLayout'; // điều chỉnh đường dẫn nếu khác
import { FaPlus, FaBuilding } from 'react-icons/fa';

const CompanyList = () => {
    const [activeMenu, setActiveMenu] = useState('company');

    return (
        <AdminLayout activeMenu={activeMenu} setActiveMenu={setActiveMenu}>
            <div className="flex justify-between items-center mb-6">
                <h1 className="text-2xl font-bold text-gray-800">Company List</h1>
                <button
                    className="flex items-center gap-2 px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition-colors"
                >
                    <FaPlus />
                    <span>Thêm</span>
                </button>
            </div>

            <div className="bg-white rounded-lg shadow overflow-hidden">
                <div className="overflow-x-auto">
                    <table className="min-w-full divide-y divide-gray-200">
                        <thead className="bg-gray-50">
                            <tr>
                                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Logo</th>
                                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Name</th>
                                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Tax Code</th>
                                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Address</th>
                                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Phone</th>
                                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Email</th>
                                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Description</th>
                                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Status</th>
                                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Actions</th>
                            </tr>
                        </thead>
                        <tbody className="bg-white divide-y divide-gray-200">
                            <tr className="hover:bg-gray-50">
                                <td className="px-6 py-4 whitespace-nowrap">
                                    <div className="h-10 w-10 rounded-full bg-gray-200 flex items-center justify-center">
                                        <FaBuilding className="text-gray-400" />
                                    </div>
                                </td>
                                <td className="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900">ACME Corp</td>
                                <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">1234567890</td>
                                <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">123 Street, City</td>
                                <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">0123456789</td>
                                <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">contact@acme.com</td>
                                <td className="px-6 py-4 text-sm text-gray-500">Công ty chuyên sản xuất thiết bị công nghiệp</td>
                                <td className="px-6 py-4 whitespace-nowrap text-sm text-green-600 font-semibold">Active</td>
                                <td className="px-6 py-4 whitespace-nowrap">
                                    <div className="flex items-center gap-2">
                                        <button className="p-2 text-blue-600 hover:bg-blue-50 rounded-lg transition-colors">Sửa</button>
                                        <button className="p-2 text-red-600 hover:bg-red-50 rounded-lg transition-colors">Xóa</button>
                                    </div>
                                </td>
                            </tr>
                        </tbody>
                    </table>
                </div>
            </div>
        </AdminLayout>
    );
};

export default CompanyList;

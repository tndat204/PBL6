import React, { useState, useEffect } from 'react';
import * as companyApi from "../../api/CompanyApi";
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
    const [companies, setCompanies] = useState([]);
    const [loading, setLoading] = useState(false);
    const menuItems = [
        { id: 'company', label: 'Company', icon: FaBuilding },
        { id: 'user', label: 'User', icon: FaUsers },
        { id: 'job', label: 'Job', icon: FaBriefcase },
        { id: 'statistics', label: 'Statistics', icon: FaChartBar },
        { id: 'settings', label: 'Settings', icon: FaCog },
    ];
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
                                className={`w-full flex items-center gap-3 px-6 py-3 text-left text-gray-700 hover:bg-gray-50 transition-colors`}
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
                            className="flex items-center gap-2 px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition-colors"
                        >
                            <FaPlus />
                            <span>Thêm</span>
                        </button>
                    </div>

                    {/* Static Table Example */}
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
                                {loading ? (
                                    <tr>
                                    <td colSpan={9} className="px-6 py-4 text-center text-gray-500">
                                        Đang tải...
                                    </td>
                                    </tr>
                                ) : companies.length === 0 ? (
                                    <tr>
                                    <td colSpan={9} className="px-6 py-4 text-center text-gray-500">
                                        Không có công ty nào
                                    </td>
                                    </tr>
                                ) : (
                                    companies.map((company) => (
                                    <tr key={company.id} className="hover:bg-gray-50">
                                        <td className="px-6 py-4 whitespace-nowrap">
                                        <div className="h-10 w-10 rounded-full bg-gray-200 flex items-center justify-center">
                                            <FaBuilding className="text-gray-400" />
                                        </div>
                                        </td>
                                        <td className="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900">
                                        {company.name}
                                        </td>
                                        <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                                        {company.taxCode}
                                        </td>
                                        <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                                        {company.address}
                                        </td>
                                        <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                                        {company.phone}
                                        </td>
                                        <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                                        {company.email}
                                        </td>
                                        <td className="px-6 py-4 text-sm text-gray-500">
                                        {company.description}
                                        </td>
                                        <td className="px-6 py-4 whitespace-nowrap text-sm font-semibold text-green-600">
                                        {company.status === 1 ? 'Active' : 'Inactive'}
                                        </td>
                                        <td className="px-6 py-4 whitespace-nowrap">
                                        <div className="flex items-center gap-2">
                                            <button className="p-2 text-blue-600 hover:bg-blue-50 rounded-lg transition-colors">
                                            Sửa
                                            </button>
                                            <button className="p-2 text-red-600 hover:bg-red-50 rounded-lg transition-colors">
                                            Xóa
                                            </button>
                                        </div>
                                        </td>
                                    </tr>
                                    ))
                                )}
                                </tbody>

                            </table>
                        </div>
                    </div>

                    
                </div>
            </div>
        </div>
    );
};

export default CompanyList;

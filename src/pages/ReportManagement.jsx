import React, { useState, useEffect } from 'react';
import { Search, Filter, AlertTriangle, CheckCircle, XCircle, Clock, Eye } from 'lucide-react';
import { reviewService } from '../services/reviewService';
import Toast from '../components/Toast';

const ReportManagement = () => {
    const [reports, setReports] = useState([]);
    const [loading, setLoading] = useState(true);
    const [error, setError] = useState(null);
    const [page, setPage] = useState(0);
    const [totalPages, setTotalPages] = useState(0);
    const [statusFilter, setStatusFilter] = useState('');
    const [toast, setToast] = useState(null);
    const [confirmDialog, setConfirmDialog] = useState(null);
    const [processingReportId, setProcessingReportId] = useState(null);

    useEffect(() => {
        fetchReports();
    }, [page, statusFilter]);

    const fetchReports = async () => {
        setLoading(true);
        try {
            const response = await reviewService.getReports(page, 10, statusFilter);
            if (response && response.content) {
                setReports(response.content);
                setTotalPages(response.totalPages);
            } else {
                setReports([]);
            }
        } catch (err) {
            console.error('Error fetching reports:', err);
            setError('Không thể tải danh sách báo cáo.');
        } finally {
            setLoading(false);
        }
    };

    const showToast = (message, type) => {
        setToast({ message, type });
        setTimeout(() => setToast(null), 3000);
    };

    const handleProcessReport = async (reportId, newStatus) => {
        setConfirmDialog(null);
        setProcessingReportId(reportId);
        try {
            await reviewService.processReport(reportId, newStatus);
            showToast(`Đã ${newStatus === 'APPROVED' ? 'chấp nhận' : newStatus === 'REJECTED' ? 'từ chối' : 'đặt lại'} báo cáo thành công`, 'success');
            await fetchReports();
        } catch (err) {
            console.error('Error processing report:', err);
            showToast('Không thể xử lý báo cáo. Vui lòng thử lại.', 'error');
        } finally {
            setProcessingReportId(null);
        }
    };

    const openConfirmDialog = (reportId, newStatus) => {
        const messages = {
            APPROVED: 'Bạn có chắc chắn muốn chấp nhận báo cáo này? Đánh giá liên quan sẽ bị ẩn/xóa.',
            REJECTED: 'Bạn có chắc chắn muốn từ chối báo cáo này? Đánh giá sẽ vẫn hiển thị.',
            PENDING: 'Bạn có chắc chắn muốn đặt lại trạng thái báo cáo về "Chờ xử lý"?'
        };
        setConfirmDialog({
            reportId,
            newStatus,
            message: messages[newStatus]
        });
    };

    const getStatusBadge = (status) => {
        const styles = {
            PENDING: 'bg-yellow-100 text-yellow-700',
            APPROVED: 'bg-green-100 text-green-700',
            REJECTED: 'bg-red-100 text-red-700'
        };
        const labels = {
            PENDING: 'Chờ xử lý',
            APPROVED: 'Đã duyệt',
            REJECTED: 'Đã từ chối'
        };
        return (
            <span className={`px-3 py-1 rounded-full text-xs font-medium ${styles[status] || 'bg-gray-100 text-gray-700'}`}>
                {labels[status] || status}
            </span>
        );
    };

    return (
        <div className="p-6 max-w-[1600px] mx-auto">
            {toast && <Toast message={toast.message} type={toast.type} onClose={() => setToast(null)} />}

            {/* Header */}
            <div className="flex flex-col md:flex-row md:items-center justify-between gap-4 mb-8">
                <div>
                    <h1 className="text-2xl font-bold text-gray-800">Quản lý báo cáo</h1>
                    <p className="text-gray-500 mt-1">Xem và xử lý các báo cáo vi phạm từ người dùng</p>
                </div>
            </div>

            {/* Filters */}
            <div className="bg-white p-4 rounded-xl shadow-sm border border-gray-100 mb-6 flex flex-wrap gap-4 items-center">
                <div className="flex items-center gap-2 text-gray-500">
                    <Filter size={20} />
                    <span className="font-medium">Bộ lọc:</span>
                </div>

                <select
                    value={statusFilter}
                    onChange={(e) => {
                        setStatusFilter(e.target.value);
                        setPage(0);
                    }}
                    className="px-4 py-2 bg-gray-50 border border-gray-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500 text-sm"
                >
                    <option value="">Tất cả trạng thái</option>
                    <option value="PENDING">Chờ xử lý</option>
                    <option value="APPROVED">Đã duyệt</option>
                    <option value="REJECTED">Đã từ chối</option>
                </select>

                <button
                    onClick={fetchReports}
                    className="ml-auto px-4 py-2 bg-blue-50 text-blue-600 rounded-lg hover:bg-blue-100 transition-colors text-sm font-medium"
                >
                    Làm mới
                </button>
            </div>

            {/* Table */}
            <div className="bg-white rounded-xl shadow-sm border border-gray-100 overflow-hidden">
                <div className="overflow-x-auto">
                    <table className="w-full text-left border-collapse">
                        <thead>
                            <tr className="bg-gray-50/50 border-b border-gray-100">
                                <th className="px-6 py-4 text-xs font-semibold text-gray-500 uppercase tracking-wider">ID</th>
                                <th className="px-6 py-4 text-xs font-semibold text-gray-500 uppercase tracking-wider">Lý do</th>
                                <th className="px-6 py-4 text-xs font-semibold text-gray-500 uppercase tracking-wider">Mô tả</th>
                                <th className="px-6 py-4 text-xs font-semibold text-gray-500 uppercase tracking-wider">Người báo cáo</th>
                                <th className="px-6 py-4 text-xs font-semibold text-gray-500 uppercase tracking-wider">Ngày tạo</th>
                                <th className="px-6 py-4 text-xs font-semibold text-gray-500 uppercase tracking-wider">Trạng thái</th>
                                <th className="px-6 py-4 text-xs font-semibold text-gray-500 uppercase tracking-wider text-right">Hành động</th>
                            </tr>
                        </thead>
                        <tbody className="divide-y divide-gray-50">
                            {loading ? (
                                <tr>
                                    <td colSpan="7" className="px-6 py-12 text-center text-gray-500">
                                        <div className="flex flex-col items-center gap-3">
                                            <div className="w-8 h-8 border-4 border-blue-500 border-t-transparent rounded-full animate-spin"></div>
                                            <p>Đang tải dữ liệu...</p>
                                        </div>
                                    </td>
                                </tr>
                            ) : reports.length === 0 ? (
                                <tr>
                                    <td colSpan="7" className="px-6 py-12 text-center text-gray-500">
                                        <div className="flex flex-col items-center gap-3">
                                            <div className="w-12 h-12 bg-gray-100 rounded-full flex items-center justify-center text-gray-400">
                                                <AlertTriangle size={24} />
                                            </div>
                                            <p>Không tìm thấy báo cáo nào</p>
                                        </div>
                                    </td>
                                </tr>
                            ) : (
                                reports.map((report) => (
                                    <tr key={report.id} className="hover:bg-gray-50/50 transition-colors group">
                                        <td className="px-6 py-4 text-sm text-gray-500 font-mono">
                                            {report.id.substring(0, 8)}...
                                        </td>
                                        <td className="px-6 py-4">
                                            <span className="font-medium text-gray-800">{report.reason}</span>
                                        </td>
                                        <td className="px-6 py-4 text-sm text-gray-600 max-w-xs truncate" title={report.description}>
                                            {report.description || '-'}
                                        </td>
                                        <td className="px-6 py-4 text-sm text-gray-600">
                                            {report.reporterId ? report.reporterId.substring(0, 8) + '...' : 'N/A'}
                                        </td>
                                        <td className="px-6 py-4 text-sm text-gray-500">
                                            <div className="flex items-center gap-2">
                                                <Clock size={14} />
                                                {new Date(report.createdAt).toLocaleDateString('vi-VN')}
                                            </div>
                                        </td>
                                        <td className="px-6 py-4">
                                            {getStatusBadge(report.status)}
                                        </td>
                                        <td className="px-6 py-4 text-right">
                                            <div className="flex items-center justify-end gap-2">
                                                {report.status === 'PENDING' ? (
                                                    <>
                                                        <button
                                                            onClick={() => openConfirmDialog(report.id, 'APPROVED')}
                                                            disabled={processingReportId === report.id}
                                                            className="flex items-center gap-1.5 px-3 py-1.5 bg-green-50 text-green-700 rounded-lg hover:bg-green-100 transition-colors text-sm font-medium disabled:opacity-50 disabled:cursor-not-allowed"
                                                            title="Chấp nhận báo cáo"
                                                        >
                                                            <CheckCircle size={16} />
                                                            <span>Duyệt</span>
                                                        </button>
                                                        <button
                                                            onClick={() => openConfirmDialog(report.id, 'REJECTED')}
                                                            disabled={processingReportId === report.id}
                                                            className="flex items-center gap-1.5 px-3 py-1.5 bg-red-50 text-red-700 rounded-lg hover:bg-red-100 transition-colors text-sm font-medium disabled:opacity-50 disabled:cursor-not-allowed"
                                                            title="Từ chối báo cáo"
                                                        >
                                                            <XCircle size={16} />
                                                            <span>Từ chối</span>
                                                        </button>
                                                    </>
                                                ) : (
                                                    <button
                                                        onClick={() => openConfirmDialog(report.id, 'PENDING')}
                                                        disabled={processingReportId === report.id}
                                                        className="flex items-center gap-1.5 px-3 py-1.5 bg-yellow-50 text-yellow-700 rounded-lg hover:bg-yellow-100 transition-colors text-sm font-medium disabled:opacity-50 disabled:cursor-not-allowed"
                                                        title="Đặt lại về chờ xử lý"
                                                    >
                                                        <Clock size={16} />
                                                        <span>Đặt lại</span>
                                                    </button>
                                                )}
                                            </div>
                                        </td>
                                    </tr>
                                ))
                            )}
                        </tbody>
                    </table>
                </div>

                {/* Pagination */}
                <div className="px-6 py-4 border-t border-gray-100 flex items-center justify-between bg-gray-50/30">
                    <p className="text-sm text-gray-500">
                        Hiển thị trang <span className="font-medium">{page + 1}</span> / <span className="font-medium">{totalPages || 1}</span>
                    </p>
                    <div className="flex gap-2">
                        <button
                            onClick={() => setPage(p => Math.max(0, p - 1))}
                            disabled={page === 0}
                            className="px-3 py-1 text-sm border border-gray-200 rounded-lg hover:bg-white disabled:opacity-50 disabled:cursor-not-allowed transition-colors"
                        >
                            Trước
                        </button>
                        <button
                            onClick={() => setPage(p => Math.min(totalPages - 1, p + 1))}
                            disabled={page >= totalPages - 1}
                            className="px-3 py-1 text-sm border border-gray-200 rounded-lg hover:bg-white disabled:opacity-50 disabled:cursor-not-allowed transition-colors"
                        >
                            Sau
                        </button>
                    </div>
                </div>
            </div>

            {/* Confirmation Dialog */}
            {confirmDialog && (
                <div className="fixed inset-0 z-50 flex items-center justify-center bg-black bg-opacity-50 p-4">
                    <div className="bg-white rounded-xl shadow-xl max-w-md w-full p-6">
                        <div className="flex items-start gap-4 mb-4">
                            <div className="w-12 h-12 rounded-full bg-yellow-100 flex items-center justify-center flex-shrink-0">
                                <AlertTriangle size={24} className="text-yellow-600" />
                            </div>
                            <div>
                                <h3 className="text-lg font-semibold text-gray-900 mb-2">Xác nhận hành động</h3>
                                <p className="text-gray-600 text-sm">{confirmDialog.message}</p>
                            </div>
                        </div>
                        <div className="flex gap-3 justify-end">
                            <button
                                onClick={() => setConfirmDialog(null)}
                                className="px-4 py-2 border border-gray-300 text-gray-700 rounded-lg hover:bg-gray-50 font-medium transition-colors"
                            >
                                Hủy
                            </button>
                            <button
                                onClick={() => handleProcessReport(confirmDialog.reportId, confirmDialog.newStatus)}
                                className="px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 font-medium transition-colors"
                            >
                                Xác nhận
                            </button>
                        </div>
                    </div>
                </div>
            )}
        </div>
    );
};

export default ReportManagement;

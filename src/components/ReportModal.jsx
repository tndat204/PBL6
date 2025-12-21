import React, { useState, useEffect } from "react";
import { X, AlertCircle } from "lucide-react";
import { reviewService } from "../services";

function ReportModal({ isOpen, onClose, reviewId, onReportSuccess }) {
    const [reportReasons, setReportReasons] = useState([]);
    const [selectedReason, setSelectedReason] = useState("");
    const [description, setDescription] = useState("");
    const [loading, setLoading] = useState(false);
    const [fetchingReasons, setFetchingReasons] = useState(true);
    const [error, setError] = useState("");

    useEffect(() => {
        if (isOpen) {
            fetchReportReasons();
            // Reset form when modal opens
            setSelectedReason("");
            setDescription("");
            setError("");
        }
    }, [isOpen]);

    const fetchReportReasons = async () => {
        try {
            setFetchingReasons(true);
            const reasons = await reviewService.getReportReasons();
            setReportReasons(Array.isArray(reasons) ? reasons : []);
        } catch (err) {
            console.error("Failed to fetch report reasons:", err);
            setError("Không thể tải danh sách lý do báo cáo. Vui lòng thử lại.");
        } finally {
            setFetchingReasons(false);
        }
    };

    const handleReasonChange = (reasonKey) => {
        setSelectedReason(reasonKey);
        setError("");
    };

    const handleSubmit = async (e) => {
        e.preventDefault();

        if (!selectedReason) {
            setError("Vui lòng chọn một lý do báo cáo.");
            return;
        }

        try {
            setLoading(true);
            setError("");

            await reviewService.reportReview(reviewId, {
                reason: selectedReason,
                description: description.trim()
            });

            // Success
            if (onReportSuccess) {
                onReportSuccess();
            }
            onClose();
        } catch (err) {
            console.error("Failed to submit report:", err);
            setError("Không thể gửi báo cáo. Vui lòng thử lại.");
        } finally {
            setLoading(false);
        }
    };

    if (!isOpen) return null;

    return (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-black bg-opacity-50 p-4">
            <div className="bg-white rounded-xl shadow-xl max-w-md w-full max-h-[90vh] overflow-y-auto">
                {/* Header */}
                <div className="flex items-center justify-between p-6 border-b border-gray-100">
                    <h3 className="text-lg font-semibold text-gray-900">Báo cáo đánh giá</h3>
                    <button
                        onClick={onClose}
                        className="text-gray-400 hover:text-gray-600 transition-colors"
                        disabled={loading}
                    >
                        <X size={20} />
                    </button>
                </div>

                {/* Content */}
                <form onSubmit={handleSubmit} className="p-6">
                    {error && (
                        <div className="mb-4 p-3 bg-red-50 border border-red-200 rounded-lg flex items-start gap-2">
                            <AlertCircle size={18} className="text-red-600 flex-shrink-0 mt-0.5" />
                            <p className="text-sm text-red-600">{error}</p>
                        </div>
                    )}

                    {fetchingReasons ? (
                        <div className="py-8 text-center text-gray-500">
                            <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-blue-600 mx-auto mb-2"></div>
                            <p className="text-sm">Đang tải...</p>
                        </div>
                    ) : (
                        <>
                            <div className="mb-4">
                                <label className="block text-sm font-medium text-gray-700 mb-3">
                                    Lý do báo cáo <span className="text-red-500">*</span>
                                </label>
                                <div className="space-y-3">
                                    {reportReasons.map((reason) => (
                                        <label
                                            key={reason.key}
                                            className="flex items-start gap-3 p-3 border border-gray-200 rounded-lg hover:bg-gray-50 cursor-pointer transition-colors"
                                        >
                                            <input
                                                type="radio"
                                                name="reportReason"
                                                value={reason.key}
                                                checked={selectedReason === reason.key}
                                                onChange={() => handleReasonChange(reason.key)}
                                                className="mt-1 w-4 h-4 text-blue-600 border-gray-300 focus:ring-blue-500"
                                                disabled={loading}
                                            />
                                            <div className="flex-1">
                                                <div className="font-medium text-gray-900 text-sm">
                                                    {reason.label}
                                                </div>
                                                {reason.description && (
                                                    <div className="text-xs text-gray-500 mt-1">
                                                        {reason.description}
                                                    </div>
                                                )}
                                            </div>
                                        </label>
                                    ))}
                                </div>
                            </div>

                            <div className="mb-6">
                                <label className="block text-sm font-medium text-gray-700 mb-2">
                                    Mô tả chi tiết (tùy chọn)
                                </label>
                                <textarea
                                    value={description}
                                    onChange={(e) => setDescription(e.target.value)}
                                    placeholder="Vui lòng cung cấp thêm thông tin về vấn đề..."
                                    rows={4}
                                    className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 resize-none text-sm"
                                    disabled={loading}
                                />
                            </div>

                            {/* Actions */}
                            <div className="flex gap-3">
                                <button
                                    type="button"
                                    onClick={onClose}
                                    className="flex-1 px-4 py-2.5 border border-gray-300 text-gray-700 rounded-lg hover:bg-gray-50 font-medium transition-colors"
                                    disabled={loading}
                                >
                                    Hủy
                                </button>
                                <button
                                    type="submit"
                                    className="flex-1 px-4 py-2.5 bg-red-600 text-white rounded-lg hover:bg-red-700 font-medium transition-colors disabled:opacity-50 disabled:cursor-not-allowed"
                                    disabled={loading || !selectedReason}
                                >
                                    {loading ? "Đang gửi..." : "Gửi báo cáo"}
                                </button>
                            </div>
                        </>
                    )}
                </form>
            </div>
        </div>
    );
}

export default ReportModal;

import React, { useState } from 'react';
import { Upload, FileText, CheckCircle, AlertCircle, Loader2, ChevronDown, ChevronUp, Star } from 'lucide-react';
import { cvService } from '../services';
import Toast from '../components/Toast';

const CVReview = () => {
    const [file, setFile] = useState(null);
    const [loading, setLoading] = useState(false);
    const [result, setResult] = useState(null);
    const [error, setError] = useState(null);
    const [toast, setToast] = useState(null);
    const [expandedCriteria, setExpandedCriteria] = useState({});

    const handleFileChange = (e) => {
        const selectedFile = e.target.files[0];
        if (selectedFile) {
            if (selectedFile.type !== 'application/pdf') {
                showToast('Vui lòng chỉ tải lên file PDF.', 'error');
                return;
            }
            setFile(selectedFile);
            setError(null);
            setResult(null);
        }
    };

    const handleUpload = async () => {
        if (!file) return;

        setLoading(true);
        setError(null);
        try {
            const data = await cvService.reviewCV(file);
            if (data.success) {
                setResult(data.review);
                showToast('Đánh giá CV thành công!', 'success');
            } else {
                setError('Không thể đánh giá CV. Vui lòng thử lại.');
            }
        } catch (err) {
            console.error(err);
            setError('Có lỗi xảy ra khi kết nối đến server.');
        } finally {
            setLoading(false);
        }
    };

    const showToast = (message, type) => {
        setToast({ message, type });
        setTimeout(() => setToast(null), 3000);
    };

    const toggleCriteria = (key) => {
        setExpandedCriteria(prev => ({
            ...prev,
            [key]: !prev[key]
        }));
    };

    const getScoreColor = (score) => {
        if (score >= 80) return 'text-green-600';
        if (score >= 60) return 'text-blue-600';
        if (score >= 40) return 'text-yellow-600';
        return 'text-red-600';
    };

    const getScoreBg = (score) => {
        if (score >= 80) return 'bg-green-100';
        if (score >= 60) return 'bg-blue-100';
        if (score >= 40) return 'bg-yellow-100';
        return 'bg-red-100';
    };

    const criteriaLabels = {
        personal_info: 'Thông tin cá nhân',
        career_objective: 'Mục tiêu nghề nghiệp',
        education: 'Học vấn',
        work_experience: 'Kinh nghiệm làm việc',
        skills: 'Kỹ năng',
        social_activities: 'Hoạt động xã hội',
        certifications: 'Chứng chỉ'
    };

    return (
        <div className="min-h-screen bg-gray-50 py-8 px-4 sm:px-6 lg:px-8">
            {toast && <Toast message={toast.message} type={toast.type} onClose={() => setToast(null)} />}

            <div className="max-w-4xl mx-auto">
                <div className="text-center mb-10">
                    <h1 className="text-3xl font-bold text-gray-900 mb-2">Đánh giá CV bằng AI</h1>
                    <p className="text-gray-600">Tải lên CV của bạn để nhận phân tích chi tiết và gợi ý cải thiện từ AI</p>
                </div>

                {/* Upload Section */}
                <div className="bg-white rounded-2xl shadow-sm border border-gray-100 p-8 mb-8">
                    <div className="flex flex-col items-center justify-center border-2 border-dashed border-gray-300 rounded-xl p-10 hover:border-blue-500 transition-colors bg-gray-50/50">
                        <input
                            type="file"
                            id="cv-upload"
                            className="hidden"
                            accept=".pdf"
                            onChange={handleFileChange}
                        />

                        {file ? (
                            <div className="flex flex-col items-center">
                                <div className="w-16 h-16 bg-red-100 rounded-full flex items-center justify-center mb-4">
                                    <FileText className="text-red-600" size={32} />
                                </div>
                                <p className="text-lg font-medium text-gray-900 mb-1">{file.name}</p>
                                <p className="text-sm text-gray-500 mb-6">{(file.size / 1024 / 1024).toFixed(2)} MB</p>
                                <div className="flex gap-3">
                                    <button
                                        onClick={() => document.getElementById('cv-upload').click()}
                                        className="px-4 py-2 text-sm font-medium text-gray-700 bg-white border border-gray-300 rounded-lg hover:bg-gray-50 transition-colors"
                                    >
                                        Chọn file khác
                                    </button>
                                    <button
                                        onClick={handleUpload}
                                        disabled={loading}
                                        className="px-6 py-2 text-sm font-medium text-white bg-blue-600 rounded-lg hover:bg-blue-700 transition-colors disabled:opacity-50 disabled:cursor-not-allowed flex items-center gap-2"
                                    >
                                        {loading ? (
                                            <>
                                                <Loader2 className="animate-spin" size={18} />
                                                Đang phân tích...
                                            </>
                                        ) : (
                                            <>
                                                <CheckCircle size={18} />
                                                Phân tích ngay
                                            </>
                                        )}
                                    </button>
                                </div>
                            </div>
                        ) : (
                            <label htmlFor="cv-upload" className="flex flex-col items-center cursor-pointer">
                                <div className="w-16 h-16 bg-blue-50 rounded-full flex items-center justify-center mb-4">
                                    <Upload className="text-blue-600" size={32} />
                                </div>
                                <p className="text-lg font-medium text-gray-900 mb-1">Kéo thả hoặc chọn file PDF</p>
                                <p className="text-sm text-gray-500">Hỗ trợ định dạng .pdf (Tối đa 5MB)</p>
                            </label>
                        )}
                    </div>
                    {error && (
                        <div className="mt-4 p-4 bg-red-50 border border-red-200 rounded-lg flex items-center gap-3 text-red-700">
                            <AlertCircle size={20} />
                            <p>{error}</p>
                        </div>
                    )}
                </div>

                {/* Results Section */}
                {result && (
                    <div className="space-y-6 animate-fade-in">
                        {/* Overall Score Card */}
                        <div className="bg-white rounded-2xl shadow-sm border border-gray-100 p-8 relative overflow-hidden">
                            <div className="absolute top-0 left-0 w-full h-2 bg-gradient-to-r from-blue-500 to-purple-500"></div>
                            <div className="flex flex-col md:flex-row items-center gap-8">
                                <div className="relative shrink-0">
                                    <div className="w-32 h-32 rounded-full border-8 border-gray-100 flex items-center justify-center">
                                        <span className={`text-4xl font-bold ${getScoreColor(result.overall_score)}`}>
                                            {result.overall_score}
                                        </span>
                                    </div>
                                    <div className="absolute -bottom-2 left-1/2 -translate-x-1/2 bg-gray-900 text-white text-xs px-3 py-1 rounded-full font-medium">
                                        Điểm tổng
                                    </div>
                                </div>
                                <div className="flex-1 text-center md:text-left">
                                    <h2 className="text-xl font-bold text-gray-900 mb-2">Nhận xét tổng quan</h2>
                                    <p className="text-gray-600 leading-relaxed">{result.overall_comment}</p>
                                </div>
                            </div>
                        </div>

                        {/* Priority Improvements */}
                        <div className="bg-white rounded-2xl shadow-sm border border-gray-100 p-6">
                            <h3 className="text-lg font-bold text-gray-900 mb-4 flex items-center gap-2">
                                <AlertCircle className="text-orange-500" size={20} />
                                Cần cải thiện ưu tiên
                            </h3>
                            <ul className="space-y-3">
                                {result.priority_improvements.map((item, index) => (
                                    <li key={index} className="flex items-start gap-3 bg-orange-50 p-3 rounded-lg text-gray-700 text-sm">
                                        <span className="font-bold text-orange-600 mt-0.5">{index + 1}.</span>
                                        {item}
                                    </li>
                                ))}
                            </ul>
                        </div>

                        {/* Detailed Criteria */}
                        <div className="space-y-4">
                            <h3 className="text-xl font-bold text-gray-900 px-2">Chi tiết đánh giá</h3>
                            {Object.entries(result.criteria_reviews).map(([key, data]) => (
                                <div key={key} className="bg-white rounded-xl shadow-sm border border-gray-100 overflow-hidden">
                                    <button
                                        onClick={() => toggleCriteria(key)}
                                        className="w-full px-6 py-4 flex items-center justify-between hover:bg-gray-50 transition-colors"
                                    >
                                        <div className="flex items-center gap-4">
                                            <div className={`w-12 h-12 rounded-lg ${getScoreBg(data.score)} flex items-center justify-center font-bold ${getScoreColor(data.score)}`}>
                                                {data.score}
                                            </div>
                                            <div className="text-left">
                                                <h4 className="font-bold text-gray-900">{criteriaLabels[key] || key}</h4>
                                                <p className="text-sm text-gray-500">
                                                    {data.strengths.length} điểm mạnh • {data.improvements.length} điểm cần cải thiện
                                                </p>
                                            </div>
                                        </div>
                                        {expandedCriteria[key] ? <ChevronUp size={20} className="text-gray-400" /> : <ChevronDown size={20} className="text-gray-400" />}
                                    </button>

                                    {expandedCriteria[key] && (
                                        <div className="px-6 pb-6 pt-2 border-t border-gray-100 space-y-4">
                                            <div>
                                                <h5 className="text-sm font-semibold text-green-700 mb-2 flex items-center gap-2">
                                                    <CheckCircle size={16} /> Điểm mạnh
                                                </h5>
                                                <ul className="list-disc list-inside space-y-1 text-sm text-gray-600 ml-1">
                                                    {data.strengths.map((item, idx) => (
                                                        <li key={idx}>{item}</li>
                                                    ))}
                                                </ul>
                                            </div>
                                            <div>
                                                <h5 className="text-sm font-semibold text-red-700 mb-2 flex items-center gap-2">
                                                    <AlertCircle size={16} /> Cần cải thiện
                                                </h5>
                                                <ul className="list-disc list-inside space-y-1 text-sm text-gray-600 ml-1">
                                                    {data.improvements.map((item, idx) => (
                                                        <li key={idx}>{item}</li>
                                                    ))}
                                                </ul>
                                            </div>
                                            <div className="bg-blue-50 p-4 rounded-lg">
                                                <h5 className="text-sm font-semibold text-blue-700 mb-2 flex items-center gap-2">
                                                    <Star size={16} /> Gợi ý từ AI
                                                </h5>
                                                <ul className="space-y-2 text-sm text-gray-700">
                                                    {data.suggestions.map((item, idx) => (
                                                        <li key={idx} className="flex gap-2">
                                                            <span className="text-blue-400">•</span>
                                                            {item}
                                                        </li>
                                                    ))}
                                                </ul>
                                            </div>
                                        </div>
                                    )}
                                </div>
                            ))}
                        </div>

                        {/* Final Recommendations */}
                        <div className="bg-gradient-to-br from-slate-800 to-slate-900 rounded-2xl shadow-lg p-8 text-white">
                            <h3 className="text-lg font-bold mb-4 flex items-center gap-2">
                                <Star className="text-yellow-400" size={20} />
                                Lời khuyên cuối cùng
                            </h3>
                            <ul className="space-y-3">
                                {result.final_recommendations.map((item, index) => (
                                    <li key={index} className="flex items-start gap-3 text-gray-300 text-sm">
                                        <span className="w-1.5 h-1.5 rounded-full bg-yellow-400 mt-2 shrink-0"></span>
                                        {item}
                                    </li>
                                ))}
                            </ul>
                        </div>
                    </div>
                )}
            </div>
        </div>
    );
};

export default CVReview;

import React, { useState, useEffect } from 'react';
import { useLocation, useNavigate } from 'react-router-dom';
import { CheckCircle, AlertCircle, ChevronDown, ChevronUp, Star, ArrowLeft, Download } from 'lucide-react';
import Navbar from '../components/Navbar';
import Footer from '../components/Footer';

const CVReviewResult = () => {
    const location = useLocation();
    const navigate = useNavigate();
    const [result, setResult] = useState(null);
    const [expandedCriteria, setExpandedCriteria] = useState({});

    useEffect(() => {
        if (location.state && location.state.result) {
            setResult(location.state.result);
        } else {
            navigate('/cv-review');
        }
    }, [location, navigate]);

    if (!result) return null;

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
        <div className="min-h-screen bg-gray-50 flex flex-col">
            <Navbar />
            <div className="flex-grow py-8 px-4 sm:px-6 lg:px-8">
                <div className="max-w-5xl mx-auto">
                    {/* Header */}
                    <div className="flex items-center justify-between mb-8">
                        <button
                            onClick={() => navigate('/cv-review')}
                            className="flex items-center gap-2 text-gray-600 hover:text-gray-900 transition-colors font-medium"
                        >
                            <ArrowLeft size={20} />
                            Quay lại trang tải lên
                        </button>
                        <h1 className="text-2xl font-bold text-gray-900">Kết quả phân tích</h1>
                    </div>

                    <div className="space-y-6 animate-fade-in">
                        {/* Overall Score Card */}
                        <div className="bg-white rounded-2xl shadow-sm border border-gray-100 p-8 relative overflow-hidden">
                            <div className="absolute top-0 left-0 w-full h-2 bg-gradient-to-r from-blue-500 to-purple-500"></div>
                            <div className="flex flex-col md:flex-row items-center gap-8">
                                <div className="relative shrink-0">
                                    <div className="w-40 h-40 rounded-full border-8 border-gray-50 flex items-center justify-center bg-white shadow-inner">
                                        <span className={`text-5xl font-bold ${getScoreColor(result.overall_score)}`}>
                                            {result.overall_score}
                                        </span>
                                    </div>
                                    <div className="absolute -bottom-3 left-1/2 -translate-x-1/2 bg-gray-900 text-white text-xs px-4 py-1.5 rounded-full font-medium shadow-lg whitespace-nowrap">
                                        Điểm tổng quan
                                    </div>
                                </div>
                                <div className="flex-1 text-center md:text-left space-y-4">
                                    <div>
                                        <h2 className="text-2xl font-bold text-gray-900 mb-2">Đánh giá tổng quan</h2>
                                        <p className="text-gray-600 leading-relaxed text-lg">{result.overall_comment}</p>
                                    </div>
                                </div>
                            </div>
                        </div>

                        {/* Priority Improvements */}
                        <div className="bg-white rounded-2xl shadow-sm border border-gray-100 p-8">
                            <h3 className="text-xl font-bold text-gray-900 mb-6 flex items-center gap-2">
                                <AlertCircle className="text-orange-500" size={24} />
                                Cải thiện ưu tiên
                            </h3>
                            <div className="grid gap-4">
                                {result.priority_improvements.map((item, index) => (
                                    <div key={index} className="flex items-start gap-4 bg-orange-50/50 p-4 rounded-xl border border-orange-100">
                                        <span className="flex items-center justify-center w-8 h-8 rounded-full bg-orange-100 text-orange-600 font-bold text-sm shrink-0">
                                            {index + 1}
                                        </span>
                                        <p className="text-gray-800 pt-1">{item}</p>
                                    </div>
                                ))}
                            </div>
                        </div>

                        {/* Detailed Criteria */}
                        <div className="space-y-6">
                            <h3 className="text-xl font-bold text-gray-900 px-2">Chi tiết đánh giá</h3>
                            <div className="grid gap-4">
                                {Object.entries(result.criteria_reviews).map(([key, data]) => (
                                    <div key={key} className="bg-white rounded-xl shadow-sm border border-gray-100 overflow-hidden transition-all duration-200 hover:shadow-md">
                                        <button
                                            onClick={() => toggleCriteria(key)}
                                            className="w-full px-6 py-5 flex items-center justify-between hover:bg-gray-50 transition-colors"
                                        >
                                            <div className="flex items-center gap-6">
                                                <div className={`w-14 h-14 rounded-xl ${getScoreBg(data.score)} flex items-center justify-center font-bold text-xl ${getScoreColor(data.score)}`}>
                                                    {data.score}
                                                </div>
                                                <div className="text-left">
                                                    <h4 className="text-lg font-bold text-gray-900 mb-1">{criteriaLabels[key] || key}</h4>
                                                    <div className="flex gap-4 text-sm text-gray-500">
                                                        <span className="flex items-center gap-1">
                                                            <CheckCircle size={14} className="text-green-500" />
                                                            {data.strengths.length} điểm mạnh
                                                        </span>
                                                        <span className="flex items-center gap-1">
                                                            <AlertCircle size={14} className="text-orange-500" />
                                                            {data.improvements.length} cần cải thiện
                                                        </span>
                                                    </div>
                                                </div>
                                            </div>
                                            {expandedCriteria[key] ? <ChevronUp size={20} className="text-gray-400" /> : <ChevronDown size={20} className="text-gray-400" />}
                                        </button>

                                        {expandedCriteria[key] && (
                                            <div className="px-6 pb-8 pt-2 border-t border-gray-100 space-y-6 bg-gray-50/30">
                                                <div className="grid md:grid-cols-2 gap-6">
                                                    <div className="bg-green-50/50 p-5 rounded-xl border border-green-100">
                                                        <h5 className="text-sm font-bold text-green-800 mb-3 flex items-center gap-2 uppercase tracking-wide">
                                                            <CheckCircle size={16} /> Điểm mạnh
                                                        </h5>
                                                        <ul className="space-y-2">
                                                            {data.strengths.map((item, idx) => (
                                                                <li key={idx} className="text-sm text-gray-700 flex items-start gap-2">
                                                                    <span className="text-green-500 mt-1">•</span>
                                                                    {item}
                                                                </li>
                                                            ))}
                                                        </ul>
                                                    </div>
                                                    <div className="bg-red-50/50 p-5 rounded-xl border border-red-100">
                                                        <h5 className="text-sm font-bold text-red-800 mb-3 flex items-center gap-2 uppercase tracking-wide">
                                                            <AlertCircle size={16} /> Cần cải thiện
                                                        </h5>
                                                        <ul className="space-y-2">
                                                            {data.improvements.map((item, idx) => (
                                                                <li key={idx} className="text-sm text-gray-700 flex items-start gap-2">
                                                                    <span className="text-red-500 mt-1">•</span>
                                                                    {item}
                                                                </li>
                                                            ))}
                                                        </ul>
                                                    </div>
                                                </div>

                                                <div className="bg-blue-50 p-5 rounded-xl border border-blue-100">
                                                    <h5 className="text-sm font-bold text-blue-800 mb-3 flex items-center gap-2 uppercase tracking-wide">
                                                        <Star size={16} /> Gợi ý từ AI
                                                    </h5>
                                                    <ul className="space-y-2">
                                                        {data.suggestions.map((item, idx) => (
                                                            <li key={idx} className="text-sm text-gray-700 flex items-start gap-2">
                                                                <span className="text-blue-500 mt-1">•</span>
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
                        </div>

                        {/* Final Recommendations */}
                        <div className="bg-gradient-to-br from-slate-800 to-slate-900 rounded-2xl shadow-lg p-8 text-white">
                            <h3 className="text-xl font-bold mb-6 flex items-center gap-2">
                                <Star className="text-yellow-400" size={24} />
                                Khuyến nghị cuối cùng
                            </h3>
                            <ul className="space-y-4">
                                {result.final_recommendations.map((item, index) => (
                                    <li key={index} className="flex items-start gap-4 text-gray-300">
                                        <span className="w-2 h-2 rounded-full bg-yellow-400 mt-2.5 shrink-0"></span>
                                        <span className="leading-relaxed">{item}</span>
                                    </li>
                                ))}
                            </ul>
                        </div>
                    </div>
                </div>
            </div>
            <Footer />
        </div>
    );
};

export default CVReviewResult;

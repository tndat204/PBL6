import React, { useState } from 'react';
import {
    Upload,
    FileText,
    Users,
    Loader2,
    ChevronDown,
    ChevronUp,
    Download,
    Award,
    Briefcase,
    GraduationCap,
    Code,
    MessageCircle,
    Settings
} from 'lucide-react';
import MainLayout from '../layouts/MainLayout';
import Toast from '../components/Toast';

const CVMatching = () => {
    // Form state
    const [jdFile, setJdFile] = useState(null);
    const [cvFiles, setCvFiles] = useState([]);
    const [cvUrls, setCvUrls] = useState('');
    const [weights, setWeights] = useState({
        TechnicalSkills: 0.1,
        SoftSkills: 0.3,
        Experience: 0.25,
        Education: 0.3,
        Other: 0.05
    });
    const [showWeights, setShowWeights] = useState(false);

    // Results state
    const [results, setResults] = useState(null);
    const [loading, setLoading] = useState(false);
    const [toast, setToast] = useState(null);
    const [expandedResults, setExpandedResults] = useState({});
    const [resultsCount, setResultsCount] = useState('all');

    const showToast = (message, type = 'info') => {
        setToast({ message, type, id: Date.now() });
    };

    const handleJdFileChange = (e) => {
        const file = e.target.files[0];
        if (file && file.type === 'application/pdf') {
            setJdFile(file);
        } else {
            showToast('Vui lòng chọn file PDF', 'error');
        }
    };

    const handleCvFilesChange = (e) => {
        const files = Array.from(e.target.files);
        const pdfFiles = files.filter(file => file.type === 'application/pdf');
        if (pdfFiles.length !== files.length) {
            showToast('Một số file không phải PDF đã bị bỏ qua', 'warning');
        }
        setCvFiles(pdfFiles);
    };

    const handleWeightChange = (key, value) => {
        setWeights(prev => ({ ...prev, [key]: parseFloat(value) }));
    };

    const handleSubmit = async (e) => {
        e.preventDefault();

        if (!jdFile) {
            showToast('Vui lòng chọn file Job Description', 'error');
            return;
        }

        if (cvFiles.length === 0 && !cvUrls.trim()) {
            showToast('Vui lòng chọn ít nhất 1 CV hoặc nhập URL', 'error');
            return;
        }

        // Validate weights sum to 1 (100%)
        const totalWeight = Object.values(weights).reduce((sum, val) => sum + val, 0);
        if (Math.abs(totalWeight - 1) > 0.01) {
            showToast(`Tổng trọng số phải bằng 100% (hiện tại: ${(totalWeight * 100).toFixed(0)}%)`, 'error');
            return;
        }

        setLoading(true);
        const formData = new FormData();
        formData.append('jd', jdFile);

        cvFiles.forEach(file => {
            formData.append('cvs', file);
        });

        if (cvUrls.trim()) {
            const urlList = cvUrls.split('\n').filter(url => url.trim());
            formData.append('cv_urls', JSON.stringify(urlList));
        }

        formData.append('weights', JSON.stringify(weights));

        try {
            const response = await fetch('http://jobhuntai.c5etagb0eja7f7hf.southeastasia.azurecontainer.io:8000/match/multiple', {
                method: 'POST',
                headers: {
                    'X-API-Key': import.meta.env.VITE_CV_MATCHING_API_KEY || ''
                },
                body: formData
            });

            if (!response.ok) {
                throw new Error('Lỗi khi gọi API');
            }

            const data = await response.json();
            setResults(data);
            showToast('Phân tích CV thành công!', 'success');
        } catch (error) {
            console.error('Error:', error);
            showToast('Không thể phân tích CV. Vui lòng thử lại.', 'error');
        } finally {
            setLoading(false);
        }
    };

    const handleReset = () => {
        setJdFile(null);
        setCvFiles([]);
        setCvUrls('');
        setResults(null);
        setExpandedResults({});
        setResultsCount('all');
    };

    const toggleExpand = (index) => {
        setExpandedResults(prev => ({
            ...prev,
            [index]: !prev[index]
        }));
    };

    const getDisplayedResults = () => {
        if (!results || !results.results) return [];

        const sortedResults = [...results.results].sort((a, b) =>
            b.match_score.TotalScore - a.match_score.TotalScore
        );

        if (resultsCount === 'all') return sortedResults;
        return sortedResults.slice(0, parseInt(resultsCount));
    };

    const getScoreColor = (score) => {
        if (score >= 80) return 'text-green-600 bg-green-50';
        if (score >= 60) return 'text-blue-600 bg-blue-50';
        if (score >= 40) return 'text-yellow-600 bg-yellow-50';
        return 'text-red-600 bg-red-50';
    };

    return (
        <MainLayout showBanner={true}>
            <div className="flex gap-6 -mt-8">
                {/* Sidebar - Input Form */}
                <aside className="w-80 flex-shrink-0">
                    <div className="sticky top-6">
                        <div className="bg-white rounded-xl shadow-sm border border-gray-200 p-5">
                            <h2 className="text-lg font-semibold text-gray-900 mb-4">Tải lên files</h2>

                            <form onSubmit={handleSubmit} className="space-y-4">
                                {/* Job Description Upload */}
                                <div>
                                    <label className="block text-xs font-medium text-gray-700 mb-2">
                                        Job Description <span className="text-red-500">*</span>
                                    </label>
                                    <input
                                        type="file"
                                        accept=".pdf"
                                        onChange={handleJdFileChange}
                                        className="hidden"
                                        id="jd-upload"
                                    />
                                    <label
                                        htmlFor="jd-upload"
                                        className="flex items-center gap-2 px-3 py-2.5 border-2 border-dashed border-gray-300 rounded-lg cursor-pointer hover:border-indigo-400 hover:bg-indigo-50/50 transition-colors"
                                    >
                                        <FileText className="text-indigo-600 flex-shrink-0" size={18} />
                                        <span className="text-xs text-gray-700 truncate">
                                            {jdFile ? jdFile.name : 'Chọn file PDF'}
                                        </span>
                                    </label>
                                </div>

                                {/* CV Files Upload */}
                                <div>
                                    <label className="block text-xs font-medium text-gray-700 mb-2">
                                        CV Files <span className="text-red-500">*</span>
                                    </label>
                                    <input
                                        type="file"
                                        accept=".pdf"
                                        multiple
                                        onChange={handleCvFilesChange}
                                        className="hidden"
                                        id="cv-upload"
                                    />
                                    <label
                                        htmlFor="cv-upload"
                                        className="flex items-center gap-2 px-3 py-2.5 border-2 border-dashed border-gray-300 rounded-lg cursor-pointer hover:border-indigo-400 hover:bg-indigo-50/50 transition-colors"
                                    >
                                        <Users className="text-indigo-600 flex-shrink-0" size={18} />
                                        <span className="text-xs text-gray-700">
                                            {cvFiles.length > 0 ? `${cvFiles.length} files` : 'Chọn CVs'}
                                        </span>
                                    </label>
                                    {cvFiles.length > 0 && (
                                        <div className="mt-2 space-y-1 max-h-32 overflow-y-auto">
                                            {cvFiles.map((file, index) => (
                                                <div key={index} className="text-xs text-gray-600 truncate">
                                                    • {file.name}
                                                </div>
                                            ))}
                                        </div>
                                    )}
                                </div>

                                {/* CV URLs */}
                                <div>
                                    <label className="block text-xs font-medium text-gray-700 mb-2">
                                        CV URLs (Tùy chọn)
                                    </label>
                                    <textarea
                                        value={cvUrls}
                                        onChange={(e) => setCvUrls(e.target.value)}
                                        rows={3}
                                        className="w-full px-3 py-2 rounded-lg border border-gray-300 focus:outline-none focus:ring-2 focus:ring-indigo-500 resize-none text-xs"
                                        placeholder="URL mỗi dòng"
                                    />
                                </div>

                                {/* Weights */}
                                <div className="bg-gray-50 rounded-lg p-3 border border-gray-200">
                                    <button
                                        type="button"
                                        onClick={() => setShowWeights(!showWeights)}
                                        className="flex items-center gap-2 text-xs font-medium text-gray-700 hover:text-indigo-600 transition-colors w-full"
                                    >
                                        <Settings size={14} className={showWeights ? 'text-indigo-600' : 'text-gray-500'} />
                                        Trọng số
                                        {showWeights ? <ChevronUp size={14} className="ml-auto" /> : <ChevronDown size={14} className="ml-auto" />}
                                    </button>
                                    {showWeights && (
                                        <>
                                            <div className="mt-3 space-y-2">
                                                {Object.entries(weights).map(([key, value]) => {
                                                    const labels = {
                                                        TechnicalSkills: 'Tech',
                                                        SoftSkills: 'Soft',
                                                        Experience: 'Exp',
                                                        Education: 'Edu',
                                                        Other: 'Other'
                                                    };
                                                    return (
                                                        <div key={key} className="flex items-center gap-2">
                                                            <span className="text-xs text-gray-600 w-12 flex-shrink-0">{labels[key]}</span>
                                                            <input
                                                                type="range"
                                                                min="0"
                                                                max="1"
                                                                step="0.01"
                                                                value={value}
                                                                onChange={(e) => handleWeightChange(key, e.target.value)}
                                                                className="flex-1 min-w-0 h-1 bg-gray-200 rounded-lg appearance-none cursor-pointer accent-indigo-600"
                                                            />
                                                            <span className="text-xs font-semibold text-gray-900 w-9 text-right flex-shrink-0">
                                                                {(value * 100).toFixed(0)}%
                                                            </span>
                                                        </div>
                                                    );
                                                })}
                                            </div>
                                            {/* Total Weight Display */}
                                            <div className="mt-3 pt-2 border-t border-gray-300">
                                                <div className="flex items-center justify-between">
                                                    <span className="text-xs font-medium text-gray-700">Tổng:</span>
                                                    <span className={`text-xs font-bold ${Math.abs(Object.values(weights).reduce((sum, val) => sum + val, 0) - 1) < 0.01
                                                        ? 'text-green-600'
                                                        : 'text-red-600'
                                                        }`}>
                                                        {(Object.values(weights).reduce((sum, val) => sum + val, 0) * 100).toFixed(0)}%
                                                    </span>
                                                </div>
                                            </div>
                                        </>
                                    )}
                                </div>

                                {/* Buttons */}
                                <div className="space-y-2 pt-2">
                                    <button
                                        type="submit"
                                        disabled={loading}
                                        className="w-full flex items-center justify-center gap-2 px-4 py-2.5 bg-indigo-600 text-white rounded-lg font-medium hover:bg-indigo-700 transition-colors disabled:opacity-50 text-sm"
                                    >
                                        {loading ? (
                                            <>
                                                <Loader2 className="animate-spin" size={16} />
                                                Đang xử lý...
                                            </>
                                        ) : (
                                            <>
                                                <Upload size={16} />
                                                Phân tích
                                            </>
                                        )}
                                    </button>
                                    <button
                                        type="button"
                                        onClick={handleReset}
                                        className="w-full px-4 py-2 border border-gray-300 text-gray-700 rounded-lg font-medium hover:bg-gray-50 transition-colors text-sm"
                                    >
                                        Reset
                                    </button>
                                </div>
                            </form>
                        </div>
                    </div>
                </aside>

                {/* Main Content - Results */}
                <main className="flex-1 min-w-0">
                    {!results ? (
                        <div className="bg-white rounded-xl shadow-sm border border-gray-200 p-12 text-center">
                            <div className="max-w-md mx-auto">
                                <div className="w-16 h-16 bg-indigo-100 rounded-full flex items-center justify-center mx-auto mb-4">
                                    <FileText className="text-indigo-600" size={32} />
                                </div>
                                <h3 className="text-lg font-semibold text-gray-900 mb-2">
                                    Chưa có kết quả
                                </h3>
                                <p className="text-sm text-gray-600">
                                    Tải lên Job Description và CV files để bắt đầu phân tích
                                </p>
                            </div>
                        </div>
                    ) : (
                        <div className="space-y-4">
                            {/* Results Header */}
                            <div className="bg-white rounded-xl shadow-sm border border-gray-200 p-5">
                                <div className="flex items-center justify-between">
                                    <div>
                                        <h2 className="text-xl font-semibold text-gray-900">Kết quả phân tích</h2>
                                        <p className="text-sm text-gray-600 mt-1">
                                            <span className="font-medium">JD:</span> {results.jd_source}
                                        </p>
                                    </div>
                                    <div className="flex items-center gap-3">
                                        <select
                                            value={resultsCount}
                                            onChange={(e) => setResultsCount(e.target.value)}
                                            className="px-3 py-2 rounded-lg border border-gray-300 focus:outline-none focus:ring-2 focus:ring-indigo-500 text-sm"
                                        >
                                            <option value="5">Top 5</option>
                                            <option value="10">Top 10</option>
                                            <option value="20">Top 20</option>
                                            <option value="all">Tất cả ({results.results.length})</option>
                                        </select>
                                        {results.excel_download_url && (
                                            <a
                                                href={results.excel_download_url}
                                                target="_blank"
                                                rel="noopener noreferrer"
                                                className="flex items-center gap-2 px-4 py-2 bg-green-600 text-white rounded-lg font-medium hover:bg-green-700 transition-colors text-sm"
                                            >
                                                <Download size={16} />
                                                Excel
                                            </a>
                                        )}
                                    </div>
                                </div>
                            </div>

                            {/* Results List */}
                            {getDisplayedResults().map((result, index) => (
                                <ResultCard
                                    key={index}
                                    result={result}
                                    index={index}
                                    expanded={expandedResults[index]}
                                    onToggle={() => toggleExpand(index)}
                                    getScoreColor={getScoreColor}
                                />
                            ))}
                        </div>
                    )}
                </main>
            </div>

            {/* Toast */}
            {toast && (
                <Toast
                    message={toast.message}
                    type={toast.type}
                    onClose={() => setToast(null)}
                />
            )}
        </MainLayout>
    );
};

// Result Card Component
const ResultCard = ({ result, index, expanded, onToggle, getScoreColor }) => {
    const cvName = result.cv_filename || result.cv_url || 'Unknown CV';
    const totalScore = result.match_score.TotalScore;

    return (
        <div className="bg-white rounded-xl shadow-sm border border-gray-200 overflow-hidden hover:shadow-md transition-shadow">
            {/* Card Header */}
            <div className="p-5">
                <div className="flex items-start justify-between gap-4">
                    <div className="flex-1 min-w-0">
                        <h3 className="text-base font-semibold text-gray-900 mb-3 truncate">{cvName}</h3>
                        <div className="flex items-center gap-3 flex-wrap">
                            <div className={`px-3 py-1.5 rounded-lg font-bold text-xl ${getScoreColor(totalScore)}`}>
                                {totalScore.toFixed(1)}%
                            </div>
                            <div className="flex gap-2 flex-wrap">
                                <ScoreBadge icon={<Code size={12} />} label="Tech" score={result.match_score.TechnicalSkills} />
                                <ScoreBadge icon={<MessageCircle size={12} />} label="Soft" score={result.match_score.SoftSkills} />
                                <ScoreBadge icon={<Briefcase size={12} />} label="Exp" score={result.match_score.Experience} />
                                <ScoreBadge icon={<GraduationCap size={12} />} label="Edu" score={result.match_score.Education} />
                                <ScoreBadge icon={<Award size={12} />} label="Other" score={result.match_score.Other} />
                            </div>
                        </div>
                    </div>
                    <button
                        onClick={onToggle}
                        className="p-2 hover:bg-gray-100 rounded-lg transition-colors flex-shrink-0"
                    >
                        {expanded ? <ChevronUp size={20} /> : <ChevronDown size={20} />}
                    </button>
                </div>
            </div>

            {/* Expanded Details */}
            {expanded && (
                <div className="px-5 pb-5 border-t border-gray-200 pt-5">
                    <CVDataDisplay cvData={result.cv_data} />
                </div>
            )}
        </div>
    );
};

// Score Badge Component
const ScoreBadge = ({ icon, label, score }) => (
    <div className="flex items-center gap-1 px-2 py-1 bg-gray-100 rounded-md text-xs">
        {icon}
        <span className="font-medium">{label}:</span>
        <span className="font-bold">{score?.toFixed(0) || 0}%</span>
    </div>
);

// CV Data Display Component (same as before, keeping it compact)
const CVDataDisplay = ({ cvData }) => (
    <div className="space-y-4 text-sm">
        {cvData.TechnicalSkills && (
            <div>
                <h4 className="font-semibold text-gray-900 mb-2 flex items-center gap-2">
                    <Code className="text-blue-600" size={16} />
                    Technical Skills
                </h4>
                <div className="grid grid-cols-2 gap-3">
                    {Object.entries(cvData.TechnicalSkills).map(([key, values]) => (
                        values && values.length > 0 && (
                            <div key={key}>
                                <p className="text-xs font-medium text-gray-700 mb-1">{key}:</p>
                                <div className="flex flex-wrap gap-1">
                                    {values.map((item, i) => (
                                        <span key={i} className="px-2 py-0.5 bg-blue-100 text-blue-700 rounded text-xs">
                                            {item}
                                        </span>
                                    ))}
                                </div>
                            </div>
                        )
                    ))}
                </div>
            </div>
        )}

        {cvData.SoftSkills && cvData.SoftSkills.length > 0 && (
            <div>
                <h4 className="font-semibold text-gray-900 mb-2 flex items-center gap-2">
                    <MessageCircle className="text-green-600" size={16} />
                    Soft Skills
                </h4>
                <div className="flex flex-wrap gap-1">
                    {cvData.SoftSkills.map((skill, i) => (
                        <span key={i} className="px-2 py-0.5 bg-green-100 text-green-700 rounded text-xs">
                            {skill}
                        </span>
                    ))}
                </div>
            </div>
        )}

        {cvData.Experience && (
            <div>
                <h4 className="font-semibold text-gray-900 mb-2 flex items-center gap-2">
                    <Briefcase className="text-purple-600" size={16} />
                    Experience
                </h4>
                <div className="space-y-1 text-xs">
                    {cvData.Experience.Years && <p><span className="font-medium">Years:</span> {cvData.Experience.Years}</p>}
                    {cvData.Experience.Roles && cvData.Experience.Roles.length > 0 && (
                        <p><span className="font-medium">Roles:</span> {cvData.Experience.Roles.join(', ')}</p>
                    )}
                </div>
            </div>
        )}

        {cvData.Education && (
            <div>
                <h4 className="font-semibold text-gray-900 mb-2 flex items-center gap-2">
                    <GraduationCap className="text-orange-600" size={16} />
                    Education
                </h4>
                <div className="text-xs space-y-1">
                    {cvData.Education.Degree && <p><span className="font-medium">Degree:</span> {cvData.Education.Degree}</p>}
                    {cvData.Education.Major && <p><span className="font-medium">Major:</span> {cvData.Education.Major}</p>}
                    {cvData.Education.University && <p><span className="font-medium">University:</span> {cvData.Education.University}</p>}
                </div>
            </div>
        )}

        {cvData.Certifications && cvData.Certifications.length > 0 && (
            <div>
                <h4 className="font-semibold text-gray-900 mb-2 flex items-center gap-2">
                    <Award className="text-yellow-600" size={16} />
                    Certifications
                </h4>
                <ul className="list-disc list-inside text-xs space-y-0.5">
                    {cvData.Certifications.map((cert, i) => (
                        <li key={i}>{cert}</li>
                    ))}
                </ul>
            </div>
        )}

        {cvData.Languages && cvData.Languages.length > 0 && (
            <div>
                <h4 className="font-semibold text-gray-900 mb-2">Languages</h4>
                <div className="flex flex-wrap gap-1">
                    {cvData.Languages.map((lang, i) => (
                        <span key={i} className="px-2 py-0.5 bg-gray-100 text-gray-700 rounded text-xs">
                            {lang}
                        </span>
                    ))}
                </div>
            </div>
        )}
    </div>
);

export default CVMatching;

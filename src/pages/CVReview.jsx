import React, { useState } from 'react';
import { Upload, FileText, CheckCircle, AlertCircle, Loader2, Shield } from 'lucide-react';
import { cvService } from '../services';
import Toast from '../components/Toast';
import { useNavigate } from 'react-router-dom';
import Navbar from '../components/Navbar';
import Footer from '../components/Footer';

const CVReview = () => {
    const [file, setFile] = useState(null);
    const [loading, setLoading] = useState(false);
    const [error, setError] = useState(null);
    const [toast, setToast] = useState(null);
    const navigate = useNavigate();

    const handleFileChange = (e) => {
        const selectedFile = e.target.files[0];
        if (selectedFile) {
            if (selectedFile.type !== 'application/pdf') {
                showToast('Vui lòng chỉ tải lên file PDF.', 'error');
                return;
            }
            if (selectedFile.size > 2 * 1024 * 1024) {
                showToast('File quá lớn. Vui lòng chọn file dưới 2MB.', 'error');
                return;
            }
            setFile(selectedFile);
            setError(null);
        }
    };

    const handleUpload = async () => {
        if (!file) return;

        setLoading(true);
        setError(null);
        try {
            const data = await cvService.reviewCV(file);
            if (data.success) {
                showToast('Đánh giá CV thành công!', 'success');
                navigate('/cv-review/results', { state: { result: data.review } });
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

    return (
        <div className="min-h-screen bg-gradient-to-br from-white via-blue-50 to-purple-50 relative overflow-hidden flex flex-col">
            <Navbar />
            {toast && <Toast message={toast.message} type={toast.type} onClose={() => setToast(null)} />}

            {/* Background Decorations */}
            <div className="absolute top-0 right-0 w-1/2 h-full bg-gradient-to-l from-blue-100/50 to-transparent pointer-events-none" />
            <div className="absolute bottom-0 left-0 w-96 h-96 bg-purple-100/50 rounded-full blur-3xl pointer-events-none" />

            <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 pt-20 pb-16 relative z-10 flex-grow">
                <div className="grid lg:grid-cols-2 gap-12 items-center">
                    {/* Left Column: Content */}
                    <div className="text-left space-y-8">
                        <div className="inline-flex items-center gap-2 px-3 py-1 rounded-full bg-blue-100 text-blue-700 text-sm font-medium">
                            <Shield size={16} />
                            <span>AI-Powered CV Analysis</span>
                        </div>

                        <h1 className="text-5xl lg:text-6xl font-bold text-gray-900 leading-tight">
                            The CV Checker that <span className="text-transparent bg-clip-text bg-gradient-to-r from-blue-600 to-purple-600">Beats the ATS</span>
                        </h1>

                        <p className="text-xl text-gray-600 leading-relaxed max-w-xl">
                            A quick and free AI CV checker that runs key checks to make sure your CV is ready to land interviews. Optimize your resume for Applicant Tracking Systems.
                        </p>

                        <div className="flex flex-wrap gap-4">
                            <div className="flex items-center gap-2 text-gray-700">
                                <CheckCircle className="text-green-500" size={20} />
                                <span>Instant Analysis</span>
                            </div>
                            <div className="flex items-center gap-2 text-gray-700">
                                <CheckCircle className="text-green-500" size={20} />
                                <span>ATS Compatibility</span>
                            </div>
                            <div className="flex items-center gap-2 text-gray-700">
                                <CheckCircle className="text-green-500" size={20} />
                                <span>Actionable Feedback</span>
                            </div>
                        </div>
                    </div>

                    {/* Right Column: Upload Box */}
                    <div className="bg-white rounded-3xl shadow-xl border border-gray-100 p-8 lg:p-10 backdrop-blur-sm bg-white/90">
                        <div className="text-center mb-8">
                            <h2 className="text-2xl font-bold text-gray-900">Upload your CV</h2>
                            <p className="text-gray-500 mt-2">Drop your CV here or choose a file. PDF only. Max 2MB file size.</p>
                        </div>

                        <div className="space-y-6">
                            <div className={`border-2 border-dashed rounded-2xl p-8 transition-all duration-200 ${file ? 'border-blue-500 bg-blue-50/50' : 'border-gray-300 hover:border-blue-400 hover:bg-gray-50'
                                }`}>
                                <input
                                    type="file"
                                    id="cv-upload"
                                    className="hidden"
                                    accept=".pdf"
                                    onChange={handleFileChange}
                                />

                                {file ? (
                                    <div className="flex flex-col items-center animate-fade-in">
                                        <div className="w-16 h-16 bg-white rounded-2xl shadow-sm flex items-center justify-center mb-4 text-red-500">
                                            <FileText size={32} />
                                        </div>
                                        <p className="font-semibold text-gray-900 mb-1">{file.name}</p>
                                        <p className="text-sm text-gray-500 mb-6">{(file.size / 1024 / 1024).toFixed(2)} MB</p>

                                        <div className="flex gap-3 w-full">
                                            <button
                                                onClick={() => document.getElementById('cv-upload').click()}
                                                className="flex-1 px-4 py-2.5 text-sm font-medium text-gray-700 bg-white border border-gray-300 rounded-xl hover:bg-gray-50 transition-colors"
                                            >
                                                Change File
                                            </button>
                                        </div>
                                    </div>
                                ) : (
                                    <label htmlFor="cv-upload" className="flex flex-col items-center cursor-pointer">
                                        <div className="w-20 h-20 bg-blue-50 rounded-full flex items-center justify-center mb-4 group-hover:scale-110 transition-transform duration-200">
                                            <Upload className="text-blue-600" size={32} />
                                        </div>
                                        <span className="px-6 py-2.5 bg-blue-600 text-white rounded-xl font-medium shadow-lg shadow-blue-600/20 hover:bg-blue-700 transition-all hover:shadow-blue-600/30">
                                            Upload Your CV
                                        </span>
                                    </label>
                                )}
                            </div>

                            {error && (
                                <div className="p-4 bg-red-50 border border-red-100 rounded-xl flex items-center gap-3 text-red-600 text-sm">
                                    <AlertCircle size={18} />
                                    <p>{error}</p>
                                </div>
                            )}

                            {file && (
                                <button
                                    onClick={handleUpload}
                                    disabled={loading}
                                    className="w-full py-4 bg-gradient-to-r from-blue-600 to-purple-600 text-white rounded-xl font-bold text-lg shadow-lg shadow-blue-600/20 hover:shadow-blue-600/30 hover:scale-[1.02] active:scale-[0.98] transition-all disabled:opacity-50 disabled:cursor-not-allowed disabled:hover:scale-100 flex items-center justify-center gap-2"
                                >
                                    {loading ? (
                                        <>
                                            <Loader2 className="animate-spin" size={24} />
                                            Analyzing...
                                        </>
                                    ) : (
                                        <>
                                            Check my Score
                                        </>
                                    )}
                                </button>
                            )}

                            <div className="flex items-center justify-center gap-2 text-xs text-gray-400">
                                <Shield size={12} />
                                <span>Privacy guaranteed. We don't store your CV.</span>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            {/* Dual-System Evaluation Section */}
            <div className="bg-white py-24 relative overflow-hidden">
                <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 relative z-10">
                    <div className="grid lg:grid-cols-2 gap-16 items-center">
                        {/* Left Column: Visual */}
                        <div className="relative">
                            <div className="absolute -inset-4 bg-gradient-to-r from-blue-100 to-purple-100 rounded-full blur-3xl opacity-50"></div>
                            <div className="relative bg-gradient-to-br from-slate-900 to-slate-800 rounded-3xl p-8 shadow-2xl border border-slate-700">
                                {/* Abstract representation of the "Resume Grader" */}
                                <div className="flex flex-col items-center space-y-6">
                                    <div className="w-full bg-white/10 rounded-xl p-4 backdrop-blur-sm border border-white/10">
                                        <div className="flex items-center gap-3 mb-3">
                                            <div className="w-3 h-3 rounded-full bg-red-500"></div>
                                            <div className="w-3 h-3 rounded-full bg-yellow-500"></div>
                                            <div className="w-3 h-3 rounded-full bg-green-500"></div>
                                        </div>
                                        <div className="space-y-2">
                                            <div className="h-2 bg-white/20 rounded w-3/4"></div>
                                            <div className="h-2 bg-white/20 rounded w-1/2"></div>
                                            <div className="h-2 bg-white/20 rounded w-full"></div>
                                        </div>
                                    </div>

                                    <div className="relative">
                                        <div className="w-32 h-32 rounded-full border-4 border-blue-500 flex items-center justify-center relative z-10 bg-slate-800">
                                            <Loader2 className="text-blue-400 animate-spin-slow" size={48} />
                                        </div>
                                        <div className="absolute inset-0 bg-blue-500/20 blur-xl rounded-full"></div>
                                    </div>

                                    <div className="w-full bg-white rounded-xl p-4 shadow-lg transform translate-y-4">
                                        <div className="flex items-center gap-4">
                                            <div className="w-10 h-10 rounded-full bg-green-100 flex items-center justify-center text-green-600">
                                                <CheckCircle size={20} />
                                            </div>
                                            <div>
                                                <div className="h-2 bg-gray-200 rounded w-24 mb-1"></div>
                                                <div className="h-2 bg-gray-100 rounded w-16"></div>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>

                        {/* Right Column: Content */}
                        <div className="space-y-12">
                            <div>
                                <h2 className="text-4xl font-bold text-gray-900 mb-6 leading-tight">
                                    Our CV Checker evaluates using a <span className="text-blue-600">dual-system</span>
                                </h2>
                                <p className="text-lg text-gray-600 leading-relaxed">
                                    Most CVs get screened by applicant tracking systems (ATS) before reaching recruiters.
                                    ATS searches for keywords and adds the CV to a database. The success of your CV
                                    depends on its optimization for the job, the template used, and included skills and keywords.
                                </p>
                            </div>

                            <div className="space-y-10">
                                <div className="flex gap-6">
                                    <div className="flex-shrink-0 w-12 h-12 rounded-full bg-green-100 flex items-center justify-center text-green-600 font-bold text-xl">
                                        1
                                    </div>
                                    <div>
                                        <h3 className="text-xl font-bold text-gray-900 mb-3">Content interpretation</h3>
                                        <p className="text-gray-600 leading-relaxed">
                                            Like an ATS, we analyse and attempt to comprehend your CV. The more we understand,
                                            the better it aligns with a company's ATS.
                                        </p>
                                    </div>
                                </div>

                                <div className="flex gap-6">
                                    <div className="flex-shrink-0 w-12 h-12 rounded-full bg-green-100 flex items-center justify-center text-green-600 font-bold text-xl">
                                        2
                                    </div>
                                    <div>
                                        <h3 className="text-xl font-bold text-gray-900 mb-3">What our checker identifies</h3>
                                        <p className="text-gray-600 leading-relaxed">
                                            Recruiters look for more than just keywords. We assess spelling, grammar,
                                            and the quality of content to ensure you make the best impression.
                                        </p>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
            <Footer />
        </div>
    );
};

export default CVReview;

import { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import MainLayout from '../layouts/MainLayout';
import applicationService from '../services/applicationService';
import { jobService } from '../services/jobService';
import {
    Briefcase,
    Calendar,
    FileText,
    Eye,
    Loader2,
    MapPin,
    Building2,
    Clock
} from 'lucide-react';

const MyApplications = () => {
    const navigate = useNavigate();
    const [applications, setApplications] = useState([]);
    const [loading, setLoading] = useState(true);
    const [error, setError] = useState(null);
    const [jobsMap, setJobsMap] = useState({});

    useEffect(() => {
        fetchMyApplications();
    }, []);

    const fetchMyApplications = async () => {
        try {
            setLoading(true);
            setError(null);

            const response = await applicationService.getMyApplications();
            console.log('My applications response:', response);

            const appList = response.result || response || [];
            setApplications(appList);

            // Fetch job details for each application
            const jobIds = [...new Set(appList.map(app => app.jobId))];
            const jobPromises = jobIds.map(id =>
                jobService.getJobById(id).catch(() => null)
            );
            const jobs = await Promise.all(jobPromises);

            const jobsMapping = {};
            jobs.forEach((job, index) => {
                if (job) {
                    jobsMapping[jobIds[index]] = job;
                }
            });
            setJobsMap(jobsMapping);

        } catch (err) {
            console.error('Error fetching applications:', err);
            setError('Không thể tải danh sách ứng tuyển.');
        } finally {
            setLoading(false);
        }
    };

    const getStatusBadge = (status) => {
        const statusConfig = {
            SUBMITTED: { label: 'Đã nộp', color: 'bg-blue-100 text-blue-700' },
            REVIEWED: { label: 'Đã xem xét', color: 'bg-purple-100 text-purple-700' },
            INTERVIEW: { label: 'Phỏng vấn', color: 'bg-orange-100 text-orange-700' },
            HIRED: { label: 'Được tuyển', color: 'bg-green-100 text-green-700' },
            REJECTED: { label: 'Từ chối', color: 'bg-red-100 text-red-700' },
        };
        const config = statusConfig[status] || { label: status, color: 'bg-gray-100 text-gray-700' };
        return (
            <span className={`px-3 py-1 rounded-full text-xs font-medium ${config.color}`}>
                {config.label}
            </span>
        );
    };

    const formatDate = (dateString) => {
        if (!dateString) return 'N/A';
        return new Date(dateString).toLocaleDateString('vi-VN');
    };

    if (loading) {
        return (
            <MainLayout showBanner={true}>
                <div className="max-w-7xl mx-auto py-10">
                    <div className="flex items-center justify-center h-64">
                        <Loader2 className="animate-spin text-blue-600" size={48} />
                        <span className="ml-3 text-gray-600">Đang tải dữ liệu...</span>
                    </div>
                </div>
            </MainLayout>
        );
    }

    if (error) {
        return (
            <MainLayout showBanner={true}>
                <div className="max-w-7xl mx-auto py-10">
                    <div className="bg-red-50 border border-red-200 rounded-lg p-4">
                        <p className="text-red-800 font-medium">❌ {error}</p>
                        <button
                            onClick={fetchMyApplications}
                            className="mt-2 px-4 py-2 bg-red-600 text-white rounded-lg hover:bg-red-700 transition-colors"
                        >
                            Thử lại
                        </button>
                    </div>
                </div>
            </MainLayout>
        );
    }

    return (
        <MainLayout showBanner={true}>
            <div className="max-w-7xl mx-auto py-10 px-4">
                {/* Header */}
                <div className="mb-8">
                    <h1 className="text-3xl font-bold text-gray-900 mb-2">Việc làm đã ứng tuyển</h1>
                    <p className="text-gray-600">Quản lý và theo dõi các đơn ứng tuyển của bạn</p>
                </div>

                {/* Stats */}
                <div className="grid grid-cols-1 md:grid-cols-4 gap-6 mb-8">
                    <StatCard
                        title="Tổng đơn"
                        value={applications.length}
                        color="blue"
                        icon={<Briefcase />}
                    />
                    <StatCard
                        title="Đã nộp"
                        value={applications.filter(a => a.status === 'SUBMITTED').length}
                        color="blue"
                        icon={<FileText />}
                    />
                    <StatCard
                        title="Phỏng vấn"
                        value={applications.filter(a => a.status === 'INTERVIEW').length}
                        color="orange"
                        icon={<Clock />}
                    />
                    <StatCard
                        title="Được tuyển"
                        value={applications.filter(a => a.status === 'HIRED').length}
                        color="green"
                        icon={<FileText />}
                    />
                </div>

                {/* Applications List */}
                {applications.length === 0 ? (
                    <div className="bg-white rounded-xl shadow-sm border border-gray-100 p-12 text-center">
                        <Briefcase className="mx-auto text-gray-400 mb-4" size={64} />
                        <h3 className="text-xl font-semibold text-gray-900 mb-2">
                            Chưa có đơn ứng tuyển nào
                        </h3>
                        <p className="text-gray-600 mb-6">
                            Hãy tìm kiếm và ứng tuyển vào các công việc phù hợp với bạn
                        </p>
                        <button
                            onClick={() => navigate('/jobs')}
                            className="px-6 py-3 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition-colors"
                        >
                            Tìm việc làm
                        </button>
                    </div>
                ) : (
                    <div className="space-y-4">
                        {applications.map((application) => {
                            const job = jobsMap[application.jobId];
                            return (
                                <div
                                    key={application.applicationId}
                                    className="bg-white rounded-xl shadow-sm border border-gray-100 p-6 hover:shadow-md transition-shadow"
                                >
                                    <div className="flex flex-col md:flex-row md:items-center md:justify-between gap-4">
                                        {/* Job Info */}
                                        <div className="flex-1">
                                            <div className="flex items-start gap-4">
                                                <div className="w-12 h-12 rounded-lg bg-blue-50 flex items-center justify-center shrink-0">
                                                    <Briefcase className="text-blue-600" size={24} />
                                                </div>
                                                <div className="flex-1">
                                                    <h3 className="text-lg font-semibold text-gray-900 mb-1">
                                                        {job?.title || 'Đang tải...'}
                                                    </h3>
                                                    <div className="flex flex-wrap gap-4 text-sm text-gray-600">
                                                        {job?.location && (
                                                            <div className="flex items-center gap-1">
                                                                <MapPin size={14} className="text-gray-400" />
                                                                <span>{job.location}</span>
                                                            </div>
                                                        )}
                                                        <div className="flex items-center gap-1">
                                                            <Calendar size={14} className="text-gray-400" />
                                                            <span>Nộp: {formatDate(application.appliedDate)}</span>
                                                        </div>
                                                    </div>
                                                    {application.notes && (
                                                        <p className="text-sm text-gray-600 mt-2">
                                                            <span className="font-medium">Ghi chú:</span> {application.notes}
                                                        </p>
                                                    )}
                                                </div>
                                            </div>
                                        </div>

                                        {/* Status & Actions */}
                                        <div className="flex flex-col md:items-end gap-3">
                                            {getStatusBadge(application.status)}
                                            <div className="flex gap-2">
                                                {application.cvFileUrl && (
                                                    <a
                                                        href={application.cvFileUrl}
                                                        target="_blank"
                                                        rel="noopener noreferrer"
                                                        className="px-4 py-2 text-sm bg-gray-100 text-gray-700 rounded-lg hover:bg-gray-200 transition-colors flex items-center gap-2"
                                                    >
                                                        <FileText size={16} />
                                                        Xem CV
                                                    </a>
                                                )}
                                                {job && (
                                                    <button
                                                        onClick={() => navigate(`/job-details/${job.id}`)}
                                                        className="px-4 py-2 text-sm bg-slate-100 text-slate-700 rounded-lg hover:bg-slate-200 transition-colors flex items-center gap-2"
                                                    >
                                                        <Eye size={16} />
                                                        Xem JD
                                                    </button>
                                                )}
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            );
                        })}
                    </div>
                )}
            </div>
        </MainLayout>
    );
};

const StatCard = ({ title, value, color, icon }) => (
    <div className="bg-white p-6 rounded-xl shadow-sm border border-gray-100 hover:shadow-md transition-shadow">
        <div className="flex justify-between items-start">
            <div>
                <p className="text-gray-500 text-xs font-semibold uppercase tracking-wide">{title}</p>
                <h3 className="text-2xl font-bold text-gray-800 mt-2">{value}</h3>
            </div>
            <div className={`p-3 rounded-lg bg-${color}-50 text-${color}-600`}>
                {icon}
            </div>
        </div>
    </div>
);

export default MyApplications;

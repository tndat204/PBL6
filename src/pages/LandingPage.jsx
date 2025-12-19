import { useState, useEffect } from "react";
import { useNavigate } from "react-router-dom";
import { MagnifyingGlassIcon, MapPinIcon } from "@heroicons/react/24/outline";
import Navbar from "../components/Navbar";
import JobList from "../components/JobList";
import { jobService } from "../services";

export default function LandingPage() {
    const navigate = useNavigate();
    const [searchKeyword, setSearchKeyword] = useState("");
    const [searchLocation, setSearchLocation] = useState("");
    const [jobs, setJobs] = useState([]);

    useEffect(() => {
        async function fetchJobs() {
            try {
                const data = await jobService.getAllJobs();
                // Lấy 4 jobs mới nhất
                const latestJobs = (data || []).slice(0, 4);
                setJobs(latestJobs);
            } catch (err) {
                console.error("Lỗi khi lấy danh sách jobs:", err);
                setJobs([]);
            }
        }
        fetchJobs();
    }, []);

    const handleSearch = (e) => {
        e.preventDefault();
        navigate(`/jobs?keyword=${searchKeyword}&location=${searchLocation}`);
    };

    const popularSearches = [
        "Marketing Kỹ Thuật Số",
        "Thiết Kế UI/UX",
        "Marketing Liên Kết",
        "Thiết Kế Trải Nghiệm",
        "Y Tế",
        "Nghệ Thuật",
        "Kinh Doanh & Tài Chính",
        "Công Nghệ Thông Tin",
    ];

    const trustedCompanies = [
        { name: "FPT Software", logo: "https://via.placeholder.com/120x40?text=FPT" },
        { name: "VNG", logo: "https://via.placeholder.com/120x40?text=VNG" },
        { name: "Viettel", logo: "https://via.placeholder.com/120x40?text=Viettel" },
        { name: "VNPT", logo: "https://via.placeholder.com/120x40?text=VNPT" },
        { name: "Tiki", logo: "https://via.placeholder.com/120x40?text=Tiki" },
    ];

    return (
        <div className="min-h-screen bg-white">
            {/* Header - Use Navbar Component */}
            <Navbar />

            {/* Hero Section */}
            <header className="bg-gradient-to-br from-slate-700 via-slate-800 to-slate-900 text-white">
                <div className="container mx-auto px-6 py-20 text-center">
                    <h1 className="text-5xl md:text-6xl font-bold mb-4 leading-tight">
                        Tìm công việc hoàn hảo
                        <br />
                        dành cho bạn
                    </h1>
                    <p className="text-lg text-slate-300 mb-12">
                        Hơn 5000+ việc làm đang chờ đón bạn
                    </p>

                    {/* Search Bar */}
                    <form onSubmit={handleSearch} className="max-w-4xl mx-auto">
                        <div className="bg-white/10 backdrop-blur-md rounded-2xl p-2 flex flex-col md:flex-row gap-2 items-center">
                            <div className="flex-1 flex items-center bg-slate-700/50 rounded-xl px-4 py-3 w-full">
                                <MagnifyingGlassIcon className="w-5 h-5 text-slate-400 mr-3" />
                                <input
                                    type="text"
                                    placeholder="Tìm theo từ khóa hoặc vị trí"
                                    value={searchKeyword}
                                    onChange={(e) => setSearchKeyword(e.target.value)}
                                    className="bg-transparent text-white placeholder-slate-400 outline-none w-full"
                                />
                            </div>

                            <div className="flex-1 flex items-center bg-slate-700/50 rounded-xl px-4 py-3 w-full">
                                <MapPinIcon className="w-5 h-5 text-slate-400 mr-3" />
                                <input
                                    type="text"
                                    placeholder="Địa điểm"
                                    value={searchLocation}
                                    onChange={(e) => setSearchLocation(e.target.value)}
                                    className="bg-transparent text-white placeholder-slate-400 outline-none w-full"
                                />
                            </div>

                            <button
                                type="submit"
                                className="px-8 py-3 bg-emerald-500 hover:bg-emerald-600 text-white font-semibold rounded-xl transition shadow-lg shadow-emerald-500/50"
                            >
                                Tìm Kiếm
                            </button>
                        </div>
                    </form>

                    {/* Popular Searches */}
                    <div className="mt-8">
                        <p className="text-slate-300 mb-4">Tìm Kiếm Phổ Biến</p>
                        <div className="flex flex-wrap justify-center gap-3">
                            {popularSearches.map((search, index) => (
                                <button
                                    key={index}
                                    onClick={() => {
                                        setSearchKeyword(search);
                                        navigate(`/jobs?keyword=${search}`);
                                    }}
                                    className="px-4 py-2 bg-slate-700/50 hover:bg-slate-600/50 rounded-full text-sm border border-slate-600 hover:border-emerald-500 transition"
                                >
                                    {search}
                                </button>
                            ))}
                        </div>
                    </div>
                </div>
            </header>

            {/* Trusted Companies Section */}
            <section className="py-16 bg-slate-50">
                <div className="container mx-auto px-6">
                    <div className="flex flex-wrap items-center justify-center gap-12 opacity-60">
                        {trustedCompanies.map((company, index) => (
                            <div key={index} className="grayscale hover:grayscale-0 transition">
                                <img
                                    src={company.logo}
                                    alt={company.name}
                                    className="h-10 object-contain"
                                />
                            </div>
                        ))}
                    </div>
                </div>
            </section>

            {/* Professional Service Section */}
            <section className="py-20">
                <div className="container mx-auto px-6">
                    <div className="grid md:grid-cols-2 gap-12 items-center">
                        {/* Left - Profile Card Preview */}
                        <div className="relative">
                            <div className="bg-gradient-to-br from-slate-100 to-slate-200 rounded-3xl p-8 shadow-2xl">
                                <div className="bg-white rounded-2xl p-6 shadow-lg">
                                    <div className="flex items-start justify-between mb-6">
                                        <div className="flex items-center space-x-4">
                                            <div className="w-16 h-16 bg-gradient-to-br from-emerald-400 to-cyan-500 rounded-full flex items-center justify-center text-white font-bold text-xl">
                                                AG
                                            </div>
                                            <div>
                                                <h3 className="font-bold text-lg">Trần Nguyên Đạt</h3>
                                                <p className="text-slate-600 text-sm">Backend Developer</p>
                                            </div>
                                        </div>
                                        <button className="text-slate-400 hover:text-slate-600">
                                            <svg className="w-6 h-6" fill="currentColor" viewBox="0 0 20 20">
                                                <path d="M10 6a2 2 0 110-4 2 2 0 010 4zM10 12a2 2 0 110-4 2 2 0 010 4zM10 18a2 2 0 110-4 2 2 0 010 4z" />
                                            </svg>
                                        </button>
                                    </div>

                                    <div className="space-y-3">
                                        <div className="flex items-center justify-between py-3 border-b">
                                            <span className="text-slate-600">Họ và Tên</span>
                                            <span className="flex items-center text-emerald-600 font-medium">
                                                <svg className="w-4 h-4 mr-1" fill="currentColor" viewBox="0 0 20 20">
                                                    <path fillRule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z" clipRule="evenodd" />
                                                </svg>
                                                Đã Xác Minh
                                            </span>
                                        </div>
                                        <div className="flex items-center justify-between py-3 border-b">
                                            <span className="text-slate-600">Email</span>
                                            <span className="flex items-center text-emerald-600 font-medium">
                                                <svg className="w-4 h-4 mr-1" fill="currentColor" viewBox="0 0 20 20">
                                                    <path fillRule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z" clipRule="evenodd" />
                                                </svg>
                                                Đã Xác Minh
                                            </span>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>

                        {/* Right - Content */}
                        <div>
                            <h2 className="text-4xl font-bold mb-6 text-slate-900">
                                Chúng tôi cung cấp
                                <br />
                                dịch vụ chuyên nghiệp
                            </h2>
                            <p className="text-slate-600 mb-8 leading-relaxed">
                                Một nền tảng để quản lý tất cả dữ liệu và quy trình của bạn—từ tuyển dụng,
                                quản lý mạng lưới, và mọi thứ ở giữa.
                            </p>

                            <div className="space-y-6">
                                <div className="flex items-start space-x-3">
                                    <div className="flex-shrink-0 w-6 h-6 bg-emerald-500 rounded-full flex items-center justify-center text-white mt-1">
                                        <span className="text-sm">→</span>
                                    </div>
                                    <div>
                                        <h4 className="font-semibold text-lg mb-1">Việc Làm Đã Xác Minh</h4>
                                        <p className="text-slate-600">
                                            Chúng tôi lấy việc làm trực tiếp từ website nhà tuyển dụng để bạn có thể
                                            chắc chắn chúng là thật.
                                        </p>
                                    </div>
                                </div>

                                <div className="flex items-start space-x-3">
                                    <div className="flex-shrink-0 w-6 h-6 bg-emerald-500 rounded-full flex items-center justify-center text-white mt-1">
                                        <span className="text-sm">→</span>
                                    </div>
                                    <div>
                                        <h4 className="font-semibold text-lg mb-1">Nền Tảng Đáng Tin Cậy</h4>
                                        <p className="text-slate-600">
                                            Tham gia cùng hàng nghìn chuyên gia tin tưởng nền tảng của chúng tôi cho
                                            sự phát triển nghề nghiệp của họ.
                                        </p>
                                    </div>
                                </div>
                            </div>

                            <button
                                onClick={() => navigate("/register")}
                                className="mt-8 px-8 py-3 bg-slate-900 hover:bg-slate-800 text-white font-semibold rounded-xl transition shadow-lg"
                            >
                                Bắt Đầu Ngay
                            </button>
                        </div>
                    </div>
                </div>
            </section>

            {/* New Listed Jobs Section */}
            <section className="py-20 bg-slate-50">
                <div className="container mx-auto px-6">
                    <h2 className="text-3xl font-bold mb-10">Việc Làm Mới Nhất</h2>

                    {jobs.length > 0 ? (
                        <JobList jobs={jobs} columns={4} />
                    ) : (
                        // Placeholder khi chưa có jobs
                        <div className="grid md:grid-cols-2 lg:grid-cols-4 gap-6">
                            {[1, 2, 3, 4].map((index) => (
                                <div key={index} className="bg-white rounded-xl p-6 shadow-md">
                                    <div className="animate-pulse">
                                        <div className="flex items-center space-x-3 mb-4">
                                            <div className="w-12 h-12 bg-slate-200 rounded-lg"></div>
                                            <div className="flex-1">
                                                <div className="h-4 bg-slate-200 rounded w-3/4 mb-2"></div>
                                                <div className="h-3 bg-slate-200 rounded w-1/2"></div>
                                            </div>
                                        </div>
                                        <div className="h-6 bg-slate-200 rounded w-1/3 mb-3"></div>
                                        <div className="h-12 bg-slate-200 rounded mb-4"></div>
                                        <div className="h-10 bg-slate-200 rounded"></div>
                                    </div>
                                </div>
                            ))}
                        </div>
                    )}
                    <div className="text-center mt-10">
                        <button
                            onClick={() => navigate("/jobs")}
                            className="px-8 py-3 bg-slate-900 hover:bg-slate-800 text-white font-semibold rounded-xl transition shadow-lg"
                        >
                            Xem Tất Cả Việc Làm
                        </button>
                    </div>
                </div>
            </section>

            {/* Why People Love Us Section */}
            <section className="py-20">
                <div className="container mx-auto px-6">
                    <div className="grid md:grid-cols-2 gap-12 items-center">
                        <div>
                            <h2 className="text-4xl font-bold mb-6">
                                Tại sao mọi người yêu thích chúng tôi
                            </h2>
                            <div className="space-y-4">
                                <div className="flex items-start space-x-3">
                                    <div className="flex-shrink-0 w-6 h-6 bg-emerald-500 rounded-full flex items-center justify-center text-white text-sm mt-1">
                                        ✓
                                    </div>
                                    <div>
                                        <h4 className="font-semibold mb-1">Kết nối với công việc tốt nhất</h4>
                                        <p className="text-slate-600 text-sm">
                                            Hệ thống AI của chúng tôi kết nối bạn với công việc phù hợp với kỹ năng của bạn.
                                        </p>
                                    </div>
                                </div>
                                <div className="flex items-start space-x-3">
                                    <div className="flex-shrink-0 w-6 h-6 bg-emerald-500 rounded-full flex items-center justify-center text-white text-sm mt-1">
                                        ✓
                                    </div>
                                    <div>
                                        <h4 className="font-semibold mb-1">Theo đuổi đam mê của bạn</h4>
                                        <p className="text-slate-600 text-sm">
                                            Tìm cơ hội phù hợp với mục tiêu nghề nghiệp và sở thích của bạn.
                                        </p>
                                    </div>
                                </div>
                                <div className="flex items-start space-x-3">
                                    <div className="flex-shrink-0 w-6 h-6 bg-emerald-500 rounded-full flex items-center justify-center text-white text-sm mt-1">
                                        ✓
                                    </div>
                                    <div>
                                        <h4 className="font-semibold mb-1">Gợi ý việc làm cá nhân hóa</h4>
                                        <p className="text-slate-600 text-sm">
                                            Nhận đề xuất công việc phù hợp dựa trên hồ sơ và sở thích của bạn.
                                        </p>
                                    </div>
                                </div>
                            </div>
                        </div>
                        <div className="relative">
                            <div className="bg-gradient-to-br from-slate-100 to-slate-200 rounded-3xl p-8">
                                <img
                                    src="https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?w=500&h=600&fit=crop"
                                    alt="Professional"
                                    className="rounded-2xl shadow-2xl w-full h-96 object-cover"
                                />
                            </div>
                        </div>
                    </div>
                </div>
            </section>

            {/* Top Ways to Help Section */}
            <section className="py-20 bg-gradient-to-br from-slate-700 via-slate-800 to-slate-900 text-white">
                <div className="container mx-auto px-6">
                    <h2 className="text-3xl font-bold text-center mb-12">Các cách tốt nhất để giúp bạn tiến lên</h2>
                    <div className="grid md:grid-cols-3 gap-8">
                        <div className="text-center">
                            <div className="w-16 h-16 bg-emerald-500 rounded-full flex items-center justify-center mx-auto mb-4">
                                <svg className="w-8 h-8" fill="currentColor" viewBox="0 0 20 20">
                                    <path d="M9 2a1 1 0 000 2h2a1 1 0 100-2H9z" />
                                    <path fillRule="evenodd" d="M4 5a2 2 0 012-2 3 3 0 003 3h2a3 3 0 003-3 2 2 0 012 2v11a2 2 0 01-2 2H6a2 2 0 01-2-2V5zm3 4a1 1 0 000 2h.01a1 1 0 100-2H7zm3 0a1 1 0 000 2h3a1 1 0 100-2h-3zm-3 4a1 1 0 100 2h.01a1 1 0 100-2H7zm3 0a1 1 0 100 2h3a1 1 0 100-2h-3z" clipRule="evenodd" />
                                </svg>
                            </div>
                            <h3 className="text-xl font-semibold mb-2">Công Việc Tốt Hơn</h3>
                            <p className="text-slate-300 text-sm mb-4">
                                Truy cập hàng nghìn việc làm đã xác minh từ các công ty hàng đầu toàn cầu.
                            </p>
                            <button className="text-emerald-400 hover:text-emerald-300 text-sm font-medium">
                                Tìm hiểu thêm →
                            </button>
                        </div>

                        <div className="text-center">
                            <div className="w-16 h-16 bg-emerald-500 rounded-full flex items-center justify-center mx-auto mb-4">
                                <svg className="w-8 h-8" fill="currentColor" viewBox="0 0 20 20">
                                    <path d="M13 6a3 3 0 11-6 0 3 3 0 016 0zM18 8a2 2 0 11-4 0 2 2 0 014 0zM14 15a4 4 0 00-8 0v3h8v-3zM6 8a2 2 0 11-4 0 2 2 0 014 0zM16 18v-3a5.972 5.972 0 00-.75-2.906A3.005 3.005 0 0119 15v3h-3zM4.75 12.094A5.973 5.973 0 004 15v3H1v-3a3 3 0 013.75-2.906z" />
                                </svg>
                            </div>
                            <h3 className="text-xl font-semibold mb-2">Cộng Đồng Hữu Ích</h3>
                            <p className="text-slate-300 text-sm mb-4">
                                Kết nối với các chuyên gia và nhận tư vấn nghề nghiệp từ các chuyên gia ngành.
                            </p>
                            <button className="text-emerald-400 hover:text-emerald-300 text-sm font-medium">
                                Tìm hiểu thêm →
                            </button>
                        </div>

                        <div className="text-center">
                            <div className="w-16 h-16 bg-emerald-500 rounded-full flex items-center justify-center mx-auto mb-4">
                                <svg className="w-8 h-8" fill="currentColor" viewBox="0 0 20 20">
                                    <path fillRule="evenodd" d="M10 9a3 3 0 100-6 3 3 0 000 6zm-7 9a7 7 0 1114 0H3z" clipRule="evenodd" />
                                </svg>
                            </div>
                            <h3 className="text-xl font-semibold mb-2">Hồ Sơ Nổi Bật</h3>
                            <p className="text-slate-300 text-sm mb-4">
                                Tạo hồ sơ chuyên nghiệp thể hiện kỹ năng và kinh nghiệm của bạn.
                            </p>
                            <button className="text-emerald-400 hover:text-emerald-300 text-sm font-medium">
                                Tìm hiểu thêm →
                            </button>
                        </div>
                    </div>
                    <div className="text-center mt-10">
                        <button className="px-8 py-3 bg-emerald-500 hover:bg-emerald-600 text-white font-semibold rounded-xl transition shadow-lg">
                            Bắt Đầu Ngay
                        </button>
                    </div>
                </div>
            </section>

            {/* Job Advisors Community Section */}
            <section className="py-20 bg-slate-50">
                <div className="container mx-auto px-6">
                    <h2 className="text-3xl font-bold text-center mb-4">
                        Tham gia Cộng Đồng Tư Vấn Việc Làm Lớn Nhất
                    </h2>
                    <p className="text-center text-slate-600 mb-12">
                        Kết nối với các chuyên gia ngành và nhận hướng dẫn nghề nghiệp cá nhân hóa
                    </p>
                    <div className="grid grid-cols-2 md:grid-cols-4 gap-6 mb-10">
                        {[1, 2, 3, 4].map((advisor) => (
                            <div key={advisor} className="bg-white rounded-xl p-6 text-center shadow-md hover:shadow-xl transition">
                                <div className="w-20 h-20 bg-gradient-to-br from-slate-300 to-slate-400 rounded-full mx-auto mb-4"></div>
                                <h4 className="font-semibold mb-1">Nguyễn Văn A</h4>
                                <p className="text-sm text-slate-500 mb-2">Tư Vấn Việc Làm</p>
                                <div className="flex items-center justify-center text-yellow-500 text-sm">
                                    ★★★★★
                                </div>
                            </div>
                        ))}
                    </div>
                    <div className="text-center">
                        <button className="px-8 py-3 bg-slate-900 hover:bg-slate-800 text-white font-semibold rounded-xl transition shadow-lg">
                            Xem Tất Cả Tư Vấn Viên
                        </button>
                    </div>
                </div>
            </section>

            {/* Career Advice Section */}
            <section className="py-20">
                <div className="container mx-auto px-6">
                    <h2 className="text-3xl font-bold mb-10">Mẹo Nghề Nghiệp Mới Nhất</h2>
                    <div className="grid md:grid-cols-3 gap-8">
                        <div className="bg-white rounded-xl overflow-hidden shadow-md hover:shadow-xl transition">
                            <div className="h-48 bg-gradient-to-br from-blue-400 to-blue-600"></div>
                            <div className="p-6">
                                <h3 className="font-semibold text-lg mb-2">
                                    10 Mẹo Tuyệt Vời Để Tìm Việc Bạn Muốn
                                </h3>
                                <p className="text-slate-600 text-sm mb-4">
                                    Khám phá các chiến lược đã được chứng minh để tìm và có được công việc mơ ước.
                                </p>
                                <button className="text-slate-900 hover:text-emerald-600 font-medium text-sm">
                                    Đọc Thêm →
                                </button>
                            </div>
                        </div>

                        <div className="bg-white rounded-xl overflow-hidden shadow-md hover:shadow-xl transition">
                            <div className="h-48 bg-gradient-to-br from-emerald-400 to-emerald-600"></div>
                            <div className="p-6">
                                <h3 className="font-semibold text-lg mb-2">
                                    Cách Xây Dựng Sự Nghiệp Mơ Ước Thành Công
                                </h3>
                                <p className="text-slate-600 text-sm mb-4">
                                    Học các bước thiết yếu để tạo ra con đường sự nghiệp thành công và trọn vẹn.
                                </p>
                                <button className="text-slate-900 hover:text-emerald-600 font-medium text-sm">
                                    Đọc Thêm →
                                </button>
                            </div>
                        </div>

                        <div className="bg-white rounded-xl overflow-hidden shadow-md hover:shadow-xl transition">
                            <div className="h-48 bg-gradient-to-br from-purple-400 to-purple-600"></div>
                            <div className="p-6">
                                <h3 className="font-semibold text-lg mb-2">
                                    Mẹo Phỏng Vấn Thiết Yếu Cho Người Tìm Việc
                                </h3>
                                <p className="text-slate-600 text-sm mb-4">
                                    Nắm vững nghệ thuật phỏng vấn với những mẹo và kỹ thuật chuyên gia.
                                </p>
                                <button className="text-slate-900 hover:text-emerald-600 font-medium text-sm">
                                    Đọc Thêm →
                                </button>
                            </div>
                        </div>
                    </div>
                </div>
            </section>


            {/* Footer */}
            <footer className="bg-slate-900 text-white py-12">
                <div className="container mx-auto px-6 text-center">
                    <div className="mb-6">
                        <div className="text-2xl font-bold">IT JOB HUNT</div>
                    </div>
                    <p className="text-slate-400">
                        © 2024 IT Job Hunt. All rights reserved.
                    </p>
                </div>
            </footer>
        </div>
    );
}

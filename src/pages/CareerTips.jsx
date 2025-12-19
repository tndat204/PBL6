import { useState } from "react";
import MainLayout from "../layouts/MainLayout";
import {
    DocumentTextIcon,
    UserGroupIcon,
    BriefcaseIcon,
    AcademicCapIcon,
    ChartBarIcon,
    LightBulbIcon
} from "@heroicons/react/24/outline";

export default function CareerTips() {
    const [selectedCategory, setSelectedCategory] = useState("all");

    const categories = [
        { id: "all", name: "Tất Cả", icon: LightBulbIcon },
        { id: "resume", name: "CV & Hồ Sơ", icon: DocumentTextIcon },
        { id: "interview", name: "Phỏng Vấn", icon: UserGroupIcon },
        { id: "career", name: "Phát Triển Sự Nghiệp", icon: BriefcaseIcon },
        { id: "skills", name: "Kỹ Năng", icon: AcademicCapIcon },
        { id: "salary", name: "Lương & Đàm Phán", icon: ChartBarIcon },
    ];

    const tips = [
        {
            id: 1,
            category: "resume",
            title: "10 Bí Quyết Viết CV Thu Hút Nhà Tuyển Dụng",
            excerpt: "Học cách tạo một CV ấn tượng giúp bạn nổi bật trong hàng trăm ứng viên khác.",
            image: "https://images.unsplash.com/photo-1586281380349-632531db7ed4?w=400&h=250&fit=crop",
            date: "15/12/2024",
            readTime: "5 phút đọc",
            content: [
                "1. Sử dụng format chuyên nghiệp và dễ đọc",
                "2. Tùy chỉnh CV cho từng vị trí ứng tuyển",
                "3. Làm nổi bật thành tích và kết quả cụ thể",
                "4. Sử dụng từ khóa phù hợp với ngành nghề",
                "5. Giữ CV ngắn gọn, tối đa 2 trang",
            ]
        },
        {
            id: 2,
            category: "interview",
            title: "Cách Trả Lời 15 Câu Hỏi Phỏng Vấn Phổ Biến Nhất",
            excerpt: "Chuẩn bị câu trả lời hoàn hảo cho những câu hỏi thường gặp trong phỏng vấn.",
            image: "https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?w=400&h=250&fit=crop",
            date: "12/12/2024",
            readTime: "8 phút đọc",
            content: [
                "1. 'Hãy giới thiệu về bản thân' - Chuẩn bị elevator pitch 2 phút",
                "2. 'Điểm mạnh và điểm yếu của bạn là gì?' - Trung thực nhưng khéo léo",
                "3. 'Tại sao bạn muốn làm việc tại công ty chúng tôi?' - Nghiên cứu kỹ công ty",
                "4. 'Bạn thấy mình ở đâu sau 5 năm?' - Thể hiện tham vọng hợp lý",
                "5. 'Mức lương bạn mong muốn?' - Nghiên cứu mức lương thị trường",
            ]
        },
        {
            id: 3,
            category: "career",
            title: "Lộ Trình Phát Triển Sự Nghiệp IT Từ Junior Đến Senior",
            excerpt: "Hướng dẫn chi tiết các bước để thăng tiến trong ngành công nghệ thông tin.",
            image: "https://images.unsplash.com/photo-1522071820081-009f0129c71c?w=400&h=250&fit=crop",
            date: "10/12/2024",
            readTime: "10 phút đọc",
            content: [
                "Junior (0-2 năm): Học hỏi và tích lũy kinh nghiệm",
                "Mid-level (2-5 năm): Chuyên sâu kỹ thuật và làm việc độc lập",
                "Senior (5+ năm): Dẫn dắt dự án và mentoring",
                "Tech Lead/Architect: Định hướng kỹ thuật cho team",
                "Manager: Quản lý con người và dự án",
            ]
        },
        {
            id: 4,
            category: "skills",
            title: "Top 10 Kỹ Năng Mềm Cần Thiết Cho Dân IT",
            excerpt: "Không chỉ kỹ thuật, những kỹ năng mềm này sẽ giúp bạn thành công hơn.",
            image: "https://images.unsplash.com/photo-1552664730-d307ca884978?w=400&h=250&fit=crop",
            date: "08/12/2024",
            readTime: "6 phút đọc",
            content: [
                "1. Giao tiếp hiệu quả - Truyền đạt ý tưởng kỹ thuật cho non-tech",
                "2. Làm việc nhóm - Collaboration trong Agile/Scrum",
                "3. Giải quyết vấn đề - Critical thinking và debugging",
                "4. Quản lý thời gian - Ưu tiên công việc và deadline",
                "5. Học hỏi liên tục - Cập nhật công nghệ mới",
            ]
        },
        {
            id: 5,
            category: "salary",
            title: "Bí Quyết Đàm Phán Lương Thành Công Cho IT",
            excerpt: "Chiến lược đàm phán để có được mức lương xứng đáng với năng lực của bạn.",
            image: "https://images.unsplash.com/photo-1554224155-8d04cb21cd6c?w=400&h=250&fit=crop",
            date: "05/12/2024",
            readTime: "7 phút đọc",
            content: [
                "1. Nghiên cứu mức lương thị trường cho vị trí tương đương",
                "2. Chuẩn bị danh sách thành tích và giá trị bạn mang lại",
                "3. Đừng nói số đầu tiên - Để nhà tuyển dụng đưa ra offer trước",
                "4. Đàm phán toàn bộ package, không chỉ lương cơ bản",
                "5. Biết khi nào nên chấp nhận và khi nào nên từ chối",
            ]
        },
        {
            id: 6,
            category: "resume",
            title: "Cách Viết Cover Letter Gây Ấn Tượng",
            excerpt: "Cover letter tốt có thể tạo sự khác biệt lớn trong hồ sơ ứng tuyển của bạn.",
            image: "https://images.unsplash.com/photo-1450101499163-c8848c66ca85?w=400&h=250&fit=crop",
            date: "03/12/2024",
            readTime: "5 phút đọc",
            content: [
                "1. Mở đầu thu hút - Hook ngay từ câu đầu tiên",
                "2. Thể hiện sự hiểu biết về công ty",
                "3. Kết nối kinh nghiệm với yêu cầu công việc",
                "4. Cho thấy personality và passion",
                "5. Kết thúc với call-to-action rõ ràng",
            ]
        },
        {
            id: 7,
            category: "interview",
            title: "Chuẩn Bị Gì Trước Buổi Phỏng Vấn 1 Ngày?",
            excerpt: "Checklist đầy đủ để bạn tự tin bước vào phòng phỏng vấn.",
            image: "https://images.unsplash.com/photo-1521791136064-7986c2920216?w=400&h=250&fit=crop",
            date: "01/12/2024",
            readTime: "6 phút đọc",
            content: [
                "1. Nghiên cứu kỹ về công ty và vị trí ứng tuyển",
                "2. Chuẩn bị câu trả lời cho các câu hỏi phổ biến",
                "3. Chuẩn bị 3-5 câu hỏi để hỏi interviewer",
                "4. Ôn lại kỹ năng kỹ thuật (nếu có technical test)",
                "5. Chuẩn bị trang phục chuyên nghiệp",
            ]
        },
        {
            id: 8,
            category: "career",
            title: "Khi Nào Nên Chuyển Việc? 7 Dấu Hiệu Quan Trọng",
            excerpt: "Nhận biết đúng thời điểm để có quyết định chuyển việc sáng suốt.",
            image: "https://images.unsplash.com/photo-1507679799987-c73779587ccf?w=400&h=250&fit=crop",
            date: "28/11/2024",
            readTime: "8 phút đọc",
            content: [
                "1. Không còn cơ hội học hỏi và phát triển",
                "2. Lương không tương xứng với năng lực và thị trường",
                "3. Môi trường làm việc toxic ảnh hưởng sức khỏe",
                "4. Không còn passion với công việc hiện tại",
                "5. Có cơ hội tốt hơn ở nơi khác",
            ]
        },
        {
            id: 9,
            category: "skills",
            title: "Làm Thế Nào Để Học Công Nghệ Mới Hiệu Quả?",
            excerpt: "Phương pháp học tập giúp bạn nhanh chóng nắm bắt công nghệ mới.",
            image: "https://images.unsplash.com/photo-1516321318423-f06f85e504b3?w=400&h=250&fit=crop",
            date: "25/11/2024",
            readTime: "7 phút đọc",
            content: [
                "1. Xác định mục tiêu học tập rõ ràng",
                "2. Học qua dự án thực tế, không chỉ lý thuyết",
                "3. Tham gia cộng đồng và học hỏi từ người khác",
                "4. Thực hành đều đặn mỗi ngày",
                "5. Dạy lại cho người khác để củng cố kiến thức",
            ]
        },
    ];

    const filteredTips = selectedCategory === "all"
        ? tips
        : tips.filter(tip => tip.category === selectedCategory);

    return (
        <MainLayout showBanner={false}>
            <div className="max-w-7xl mx-auto px-6 py-12">
                {/* Header */}
                <div className="text-center mb-12">
                    <h1 className="text-4xl font-bold text-slate-900 mb-4">Mẹo Nghề Nghiệp</h1>
                    <p className="text-lg text-slate-600">
                        Khám phá những bí quyết giúp bạn thành công trong sự nghiệp
                    </p>
                </div>

                {/* Categories */}
                <div className="flex flex-wrap justify-center gap-3 mb-12">
                    {categories.map((category) => {
                        const Icon = category.icon;
                        return (
                            <button
                                key={category.id}
                                onClick={() => setSelectedCategory(category.id)}
                                className={`flex items-center space-x-2 px-4 py-2 rounded-full font-medium transition ${selectedCategory === category.id
                                        ? "bg-emerald-600 text-white shadow-lg"
                                        : "bg-white text-slate-700 border border-slate-300 hover:border-emerald-500"
                                    }`}
                            >
                                <Icon className="w-5 h-5" />
                                <span>{category.name}</span>
                            </button>
                        );
                    })}
                </div>

                {/* Tips Grid */}
                <div className="grid md:grid-cols-2 lg:grid-cols-3 gap-8">
                    {filteredTips.map((tip) => (
                        <article
                            key={tip.id}
                            className="bg-white rounded-xl overflow-hidden shadow-md hover:shadow-xl transition group"
                        >
                            {/* Image */}
                            <div className="relative h-48 overflow-hidden">
                                <img
                                    src={tip.image}
                                    alt={tip.title}
                                    className="w-full h-full object-cover group-hover:scale-110 transition duration-300"
                                />
                                <div className="absolute top-4 left-4">
                                    <span className="bg-emerald-600 text-white text-xs font-semibold px-3 py-1 rounded-full">
                                        {categories.find(c => c.id === tip.category)?.name}
                                    </span>
                                </div>
                            </div>

                            {/* Content */}
                            <div className="p-6">
                                <div className="flex items-center text-sm text-slate-500 mb-3">
                                    <span>{tip.date}</span>
                                    <span className="mx-2">•</span>
                                    <span>{tip.readTime}</span>
                                </div>

                                <h3 className="text-xl font-bold text-slate-900 mb-3 group-hover:text-emerald-600 transition">
                                    {tip.title}
                                </h3>

                                <p className="text-slate-600 mb-4 line-clamp-2">
                                    {tip.excerpt}
                                </p>

                                {/* Preview Content */}
                                <div className="bg-slate-50 rounded-lg p-4 mb-4">
                                    <ul className="space-y-2 text-sm text-slate-700">
                                        {tip.content.slice(0, 3).map((item, index) => (
                                            <li key={index} className="flex items-start">
                                                <span className="text-emerald-600 mr-2">✓</span>
                                                <span className="line-clamp-1">{item}</span>
                                            </li>
                                        ))}
                                    </ul>
                                </div>

                                <button className="text-emerald-600 hover:text-emerald-700 font-semibold text-sm flex items-center group">
                                    Đọc Thêm
                                    <svg
                                        className="w-4 h-4 ml-1 group-hover:translate-x-1 transition"
                                        fill="none"
                                        stroke="currentColor"
                                        viewBox="0 0 24 24"
                                    >
                                        <path
                                            strokeLinecap="round"
                                            strokeLinejoin="round"
                                            strokeWidth={2}
                                            d="M9 5l7 7-7 7"
                                        />
                                    </svg>
                                </button>
                            </div>
                        </article>
                    ))}
                </div>

                {/* CTA Section */}
                <div className="mt-16 bg-gradient-to-br from-emerald-600 to-cyan-600 rounded-2xl p-12 text-center text-white">
                    <h2 className="text-3xl font-bold mb-4">Muốn Nhận Thêm Mẹo Nghề Nghiệp?</h2>
                    <p className="text-emerald-50 mb-6 max-w-2xl mx-auto">
                        Đăng ký nhận bản tin để cập nhật những bài viết mới nhất về phát triển sự nghiệp
                    </p>
                    <div className="flex flex-col sm:flex-row gap-3 max-w-md mx-auto">
                        <input
                            type="email"
                            placeholder="Nhập email của bạn"
                            className="flex-1 px-4 py-3 rounded-lg text-slate-900 focus:ring-2 focus:ring-white focus:outline-none"
                        />
                        <button className="px-8 py-3 bg-white text-emerald-600 font-semibold rounded-lg hover:bg-emerald-50 transition">
                            Đăng Ký
                        </button>
                    </div>
                </div>
            </div>
        </MainLayout>
    );
}

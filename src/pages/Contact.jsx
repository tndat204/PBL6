import { useState } from "react";
import MainLayout from "../layouts/MainLayout";
import { MapPinIcon, PhoneIcon, EnvelopeIcon } from "@heroicons/react/24/outline";

export default function Contact() {
    const [formData, setFormData] = useState({
        name: "",
        email: "",
        phone: "",
        subject: "",
        message: "",
    });

    const [submitted, setSubmitted] = useState(false);

    const handleChange = (e) => {
        const { name, value } = e.target;
        setFormData({
            ...formData,
            [name]: value,
        });
    };

    const handleSubmit = (e) => {
        e.preventDefault();
        // TODO: Gửi dữ liệu đến API
        console.log("Form data:", formData);
        setSubmitted(true);
        setTimeout(() => {
            setSubmitted(false);
            setFormData({
                name: "",
                email: "",
                phone: "",
                subject: "",
                message: "",
            });
        }, 3000);
    };

    return (
        <MainLayout showBanner={false}>
            <div className="max-w-7xl mx-auto px-6 py-12">
                {/* Header */}
                <div className="text-center mb-12">
                    <h1 className="text-4xl font-bold text-slate-900 mb-4">Liên Hệ Với Chúng Tôi</h1>
                    <p className="text-lg text-slate-600">
                        Chúng tôi luôn sẵn sàng lắng nghe và hỗ trợ bạn
                    </p>
                </div>

                <div className="grid md:grid-cols-2 gap-12">
                    {/* Contact Information */}
                    <div>
                        <h2 className="text-2xl font-bold text-slate-900 mb-6">Thông Tin Liên Hệ</h2>

                        <div className="space-y-6">
                            {/* Address */}
                            <div className="flex items-start space-x-4">
                                <div className="flex-shrink-0 w-12 h-12 bg-emerald-100 rounded-lg flex items-center justify-center">
                                    <MapPinIcon className="w-6 h-6 text-emerald-600" />
                                </div>
                                <div>
                                    <h3 className="font-semibold text-slate-900 mb-1">Địa Chỉ</h3>
                                    <p className="text-slate-600">
                                        54 Nguyễn Lương Bằng, Liên Chiểu, Đà Nẵng
                                    </p>
                                </div>
                            </div>

                            {/* Phone */}
                            <div className="flex items-start space-x-4">
                                <div className="flex-shrink-0 w-12 h-12 bg-blue-100 rounded-lg flex items-center justify-center">
                                    <PhoneIcon className="w-6 h-6 text-blue-600" />
                                </div>
                                <div>
                                    <h3 className="font-semibold text-slate-900 mb-1">Điện Thoại</h3>
                                    <p className="text-slate-600">+84 123 456 789</p>
                                    <p className="text-slate-600">+84 987 654 321</p>
                                </div>
                            </div>

                            {/* Email */}
                            <div className="flex items-start space-x-4">
                                <div className="flex-shrink-0 w-12 h-12 bg-purple-100 rounded-lg flex items-center justify-center">
                                    <EnvelopeIcon className="w-6 h-6 text-purple-600" />
                                </div>
                                <div>
                                    <h3 className="font-semibold text-slate-900 mb-1">Email</h3>
                                    <p className="text-slate-600">support@itjobhunt.com</p>
                                    <p className="text-slate-600">contact@itjobhunt.com</p>
                                </div>
                            </div>
                        </div>

                        {/* Working Hours */}
                        <div className="mt-8 bg-slate-50 rounded-xl p-6">
                            <h3 className="font-semibold text-slate-900 mb-4">Giờ Làm Việc</h3>
                            <div className="space-y-2 text-slate-600">
                                <div className="flex justify-between">
                                    <span>Thứ Hai - Thứ Sáu:</span>
                                    <span className="font-medium">8:00 - 17:00</span>
                                </div>
                                <div className="flex justify-between">
                                    <span>Thứ Bảy:</span>
                                    <span className="font-medium">8:00 - 12:00</span>
                                </div>
                                <div className="flex justify-between">
                                    <span>Chủ Nhật:</span>
                                    <span className="font-medium text-red-600">Nghỉ</span>
                                </div>
                            </div>
                        </div>

                        {/* Social Media */}
                        <div className="mt-8">
                            <h3 className="font-semibold text-slate-900 mb-4">Theo Dõi Chúng Tôi</h3>
                            <div className="flex space-x-4">
                                <a
                                    href="#"
                                    className="w-10 h-10 bg-blue-600 rounded-full flex items-center justify-center text-white hover:bg-blue-700 transition"
                                >
                                    <span className="text-lg">f</span>
                                </a>
                                <a
                                    href="#"
                                    className="w-10 h-10 bg-blue-400 rounded-full flex items-center justify-center text-white hover:bg-blue-500 transition"
                                >
                                    <span className="text-lg">t</span>
                                </a>
                                <a
                                    href="#"
                                    className="w-10 h-10 bg-blue-700 rounded-full flex items-center justify-center text-white hover:bg-blue-800 transition"
                                >
                                    <span className="text-lg">in</span>
                                </a>
                            </div>
                        </div>
                    </div>

                    {/* Contact Form */}
                    <div>
                        <h2 className="text-2xl font-bold text-slate-900 mb-6">Gửi Tin Nhắn</h2>

                        {submitted && (
                            <div className="mb-6 bg-emerald-50 border border-emerald-200 text-emerald-800 px-4 py-3 rounded-lg">
                                Cảm ơn bạn đã liên hệ! Chúng tôi sẽ phản hồi sớm nhất có thể.
                            </div>
                        )}

                        <form onSubmit={handleSubmit} className="space-y-4">
                            <div>
                                <label className="block text-sm font-medium text-slate-700 mb-2">
                                    Họ và Tên <span className="text-red-500">*</span>
                                </label>
                                <input
                                    type="text"
                                    name="name"
                                    value={formData.name}
                                    onChange={handleChange}
                                    required
                                    className="w-full px-4 py-3 border border-slate-300 rounded-lg focus:ring-2 focus:ring-emerald-500 focus:outline-none"
                                    placeholder="Nhập họ và tên của bạn"
                                />
                            </div>

                            <div>
                                <label className="block text-sm font-medium text-slate-700 mb-2">
                                    Email <span className="text-red-500">*</span>
                                </label>
                                <input
                                    type="email"
                                    name="email"
                                    value={formData.email}
                                    onChange={handleChange}
                                    required
                                    className="w-full px-4 py-3 border border-slate-300 rounded-lg focus:ring-2 focus:ring-emerald-500 focus:outline-none"
                                    placeholder="email@example.com"
                                />
                            </div>

                            <div>
                                <label className="block text-sm font-medium text-slate-700 mb-2">
                                    Số Điện Thoại
                                </label>
                                <input
                                    type="tel"
                                    name="phone"
                                    value={formData.phone}
                                    onChange={handleChange}
                                    className="w-full px-4 py-3 border border-slate-300 rounded-lg focus:ring-2 focus:ring-emerald-500 focus:outline-none"
                                    placeholder="0123 456 789"
                                />
                            </div>

                            <div>
                                <label className="block text-sm font-medium text-slate-700 mb-2">
                                    Chủ Đề <span className="text-red-500">*</span>
                                </label>
                                <input
                                    type="text"
                                    name="subject"
                                    value={formData.subject}
                                    onChange={handleChange}
                                    required
                                    className="w-full px-4 py-3 border border-slate-300 rounded-lg focus:ring-2 focus:ring-emerald-500 focus:outline-none"
                                    placeholder="Chủ đề tin nhắn"
                                />
                            </div>

                            <div>
                                <label className="block text-sm font-medium text-slate-700 mb-2">
                                    Nội Dung <span className="text-red-500">*</span>
                                </label>
                                <textarea
                                    name="message"
                                    value={formData.message}
                                    onChange={handleChange}
                                    required
                                    rows={6}
                                    className="w-full px-4 py-3 border border-slate-300 rounded-lg focus:ring-2 focus:ring-emerald-500 focus:outline-none resize-none"
                                    placeholder="Nhập nội dung tin nhắn của bạn..."
                                />
                            </div>

                            <button
                                type="submit"
                                className="w-full bg-emerald-600 hover:bg-emerald-700 text-white font-semibold py-3 rounded-lg transition shadow-lg"
                            >
                                Gửi Tin Nhắn
                            </button>
                        </form>
                    </div>
                </div>

                {/* Map Section */}
                <div className="mt-16">
                    <h2 className="text-2xl font-bold text-slate-900 mb-6 text-center">Vị Trí Của Chúng Tôi</h2>
                    <div className="bg-slate-200 rounded-xl overflow-hidden h-96 flex items-center justify-center">
                        <p className="text-slate-600">
                            [Google Maps sẽ được tích hợp tại đây]
                        </p>
                    </div>
                </div>
            </div>
        </MainLayout>
    );
}

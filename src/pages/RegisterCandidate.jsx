import { useState } from "react";
import { UserIcon, EnvelopeIcon, LockClosedIcon, PhoneIcon, HomeIcon, CalendarIcon } from "@heroicons/react/24/outline";
import Button from "../components/Button";

export default function Register() {
  const [formData, setFormData] = useState({
    name: "",
    email: "",
    password: "",
    confirmPassword: "",
    address: "",
    phone: "",
    birthDate: "",
    agree: false,
  });

  // Tính ngày hôm nay (yyyy-mm-dd) để set max cho input date
  const today = new Date().toISOString().split("T")[0];

  const handleChange = (e) => {
    const { name, value, type, checked } = e.target;
    setFormData({
      ...formData,
      [name]: type === "checkbox" ? checked : value,
    });
  };

  const handleSubmit = async (e) => {
    e.preventDefault();

    // ✅ 1. Kiểm tra mật khẩu
    if (formData.password !== formData.confirmPassword) {
      alert("Mật khẩu nhập lại không khớp!");
      return;
    }

    // ✅ 2. Kiểm tra checkbox
    if (!formData.agree) {
      alert("Bạn cần đồng ý với điều khoản!");
      return;
    }

    // ✅ 3. Tạo dữ liệu giống backend yêu cầu
    const payload = {
      username: formData.email,      // dùng email làm username
      password: formData.password,
      email: formData.email,
      phone: formData.phone,
      fullName: formData.name,
      address: formData.address,
      // taxCode: "",
      // nameCompany: "",
      avatarUrl: "",
      birthDate: formData.birthDate, // dạng yyyy-MM-dd
    };

    try {
      const response = await fetch("https://gateway-service.jollybeach-1fb67642.southeastasia.azurecontainerapps.io/api/internal/users", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify(payload),
      });

      // 📌 Nếu response lỗi, đọc nội dung lỗi trả về từ server
      if (!response.ok) {
        const errorData = await response.json(); // đọc body JSON
        console.error("Chi tiết lỗi từ server:", errorData);

        // Nếu backend trả về message
        if (errorData.message) {
          alert(`Lỗi: ${errorData.message}`);
        } else {
          alert(`Đăng ký thất bại (HTTP ${response.status})`);
        }
        return; // dừng luôn
      }

      // 📌 Nếu thành công
      const data = await response.json();
      console.log("Phản hồi từ server:", data);
      alert("Đăng ký thành công!");
      window.location.href = "/login";
    } catch (error) {
      // 📌 Lỗi do network (không kết nối được server)
      console.error("Lỗi khi gọi API:", error);
      alert("Không thể kết nối đến server. Vui lòng thử lại sau.");
    }

  };

  return (
    <div className="min-h-screen flex items-center justify-center bg-gradient-to-br from-green-50 to-cyan-50">
      <div className="bg-white shadow-lg rounded-2xl w-full max-w-md p-8">
        {/* Tiêu đề */}
        <h2 className="text-2xl font-bold text-center text-gray-800 mb-2">
          Chào bạn mới!
        </h2>
        <p className="text-center text-gray-500 mb-6">
          Đăng ký để bắt đầu hành trình của bạn
        </p>

        {/* Form */}
        <form onSubmit={handleSubmit} className="space-y-4">
          {/* Full Name */}
          <div className="relative">
            <UserIcon className="absolute left-3 top-2.5 w-5 h-5 text-gray-400" />
            <input
              type="text"
              name="name"
              placeholder="Họ và Tên"
              value={formData.name}
              onChange={handleChange}
              className="w-full pl-10 pr-4 py-2 border rounded-lg focus:ring-2 focus:ring-emerald-500 focus:outline-none"
            />
          </div>

          {/* Email */}
          <div className="relative">
            <EnvelopeIcon className="absolute left-3 top-2.5 w-5 h-5 text-gray-400" />
            <input
              type="email"
              name="email"
              placeholder="Nhập email của bạn"
              value={formData.email}
              onChange={handleChange}
              className="w-full pl-10 pr-4 py-2 border rounded-lg focus:ring-2 focus:ring-emerald-500 focus:outline-none"
            />
          </div>

          {/* Password */}
          <div className="relative">
            <LockClosedIcon className="absolute left-3 top-2.5 w-5 h-5 text-gray-400" />
            <input
              type="password"
              name="password"
              placeholder="Nhập mật khẩu của bạn"
              value={formData.password}
              onChange={handleChange}
              className="w-full pl-10 pr-4 py-2 border rounded-lg focus:ring-2 focus:ring-emerald-500 focus:outline-none"
            />
          </div>

          {/* Confirm Password */}
          <div className="relative">
            <LockClosedIcon className="absolute left-3 top-2.5 w-5 h-5 text-gray-400" />
            <input
              type="password"
              name="confirmPassword"
              placeholder="Nhập lại mật khẩu"
              value={formData.confirmPassword}
              onChange={handleChange}
              className="w-full pl-10 pr-4 py-2 border rounded-lg focus:ring-2 focus:ring-emerald-500 focus:outline-none"
            />
          </div>

          {/* Address */}
          <div className="relative">
            <HomeIcon className="absolute left-3 top-2.5 w-5 h-5 text-gray-400" />
            <input
              type="text"
              name="address"
              placeholder="Địa chỉ"
              value={formData.address}
              onChange={handleChange}
              className="w-full pl-10 pr-4 py-2 border rounded-lg focus:ring-2 focus:ring-emerald-500 focus:outline-none"
            />
          </div>

          {/* Phone */}
          <div className="relative">
            <PhoneIcon className="absolute left-3 top-2.5 w-5 h-5 text-gray-400" />
            <input
              type="tel"
              name="phone"
              placeholder="Số điện thoại"
              value={formData.phone}
              onChange={handleChange}
              className="w-full pl-10 pr-4 py-2 border rounded-lg focus:ring-2 focus:ring-emerald-500 focus:outline-none"
            />
          </div>

          {/* Birth Date */}
          <div className="relative">
            <CalendarIcon className="absolute left-3 top-2.5 w-5 h-5 text-gray-400" />
            <input
              type="date"
              name="birthDate"
              value={formData.birthDate}
              onChange={handleChange}
              max={today}  // 👈 không cho chọn ngày tương lai
              className="w-full pl-10 pr-4 py-2 border rounded-lg focus:ring-2 focus:ring-emerald-500 focus:outline-none"
            />
          </div>

          {/* Checkbox */}
          <div className="flex items-center space-x-2">
            <input
              type="checkbox"
              name="agree"
              checked={formData.agree}
              onChange={handleChange}
              className="w-4 h-4 border-gray-300 rounded text-emerald-600 focus:ring-emerald-500"
            />
            <label className="text-sm text-gray-600">
              Tôi đồng ý với điều khoản
            </label>
          </div>

          {/* Button */}
          <Button type="submit"
            className="from-sea-400 to-sea-300 bg-gradient-to-l">
            Đăng ký
          </Button>
        </form>

        {/* Divider */}
        <div className="mt-6 text-center text-sm text-gray-500">hoặc</div>

        {/* Login link */}
        <p className="mt-2 text-sm text-center text-gray-600">
          Bạn đã có tài khoản?{" "}
          <a href="/login" className="text-sea-400 font-medium hover:underline">
            Đăng nhập
          </a>
        </p>
      </div>
    </div>
  );
}

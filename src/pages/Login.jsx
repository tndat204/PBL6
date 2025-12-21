import { useState } from "react";
import { UserIcon, EnvelopeIcon, LockClosedIcon, EyeIcon, EyeSlashIcon } from "@heroicons/react/24/outline";
import Button from "../components/Button";
import { useAuth } from "../hooks/useAuth";
// import { authService } from "../services"; 
// thêm authService*

export default function Login() {
  console.log("GOOGLE CLIENT:", import.meta.env.VITE_GOOGLE_CLIENT_ID);
  const { login } = useAuth();
  const [showPassword, setShowPassword] = useState(false);
  const [formData, setFormData] = useState({
    name: "",
    email: "",
    password: "",
    confirmPassword: "",
    agree: false,
  });

  const handleChange = (e) => {
    const { name, value, type, checked } = e.target;
    setFormData({
      ...formData,
      [name]: type === "checkbox" ? checked : value,
    });
  };


  const handleSubmit = async (e) => {
    e.preventDefault();
    const payload = {
      email: formData.email,
      password: formData.password,
    };
    try {
      const response = await fetch("https://gateway-service.jollybeach-1fb67642.southeastasia.azurecontainerapps.io/api/auth/token", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify(payload),
      });

      // ❌ Nếu đăng nhập thất bại (HTTP status != 2xx)
      if (!response.ok) {
        const errorData = await response.json();
        console.error("Chi tiết lỗi:", errorData);
        // log ra cái lôi 
        if (errorData.message) {
          alert(`Lỗi: ${errorData.message}`);
        } else {
          alert(`Đăng nhập thất bại (HTTP ${response.status})`);
        }
        return;
      }

      // Đăng nhập thành công
      const data = await response.json();
      console.log("Đăng nhập thành công:", data);
      if (data.result?.token) {
        await login(data.result.token);
      }
      // // lưu token vào localStorage
      // if (data.result && data.result.token) {
      //   localStorage.setItem("token", data.result.token);
      // }
      // window.location.href = "/"; // chuyển về trang chủ
    } catch (error) {
      console.error("Lỗi khi gọi API:", error);
      alert("Không thể kết nối đến server. Vui lòng thử lại sau.");
    }
  };
  const googleClientId = import.meta.env.VITE_GOOGLE_CLIENT_ID;
  const redirectUri = "http://localhost:3000/authenticate";
  const authUri = "https://accounts.google.com/o/oauth2/auth";

  const handleGoogleLogin = () => {
    const scope = encodeURIComponent("email profile openid");
    const responseType = "code";

    const url =
      `${authUri}?client_id=${googleClientId}` +
      `&redirect_uri=${encodeURIComponent(redirectUri)}` +
      `&response_type=${responseType}` +
      `&scope=${scope}`;

    window.location.href = url;
  };


  return (
    <div className="min-h-screen flex items-center justify-center bg-gradient-to-br from-green-50 to-cyan-50">
      <div className="bg-white shadow-lg rounded-2xl w-full max-w-md p-8">
        {/* Tiêu đề */}
        <h2 className="text-2xl font-bold text-center text-gray-800 mb-2">
          Chào bạn quay trở lại!
        </h2>
        <p className="text-center text-gray-500 mb-6">
          Đăng nhập để tiếp tục hành trình của bạn
        </p>

        {/* Form */}
        <form onSubmit={handleSubmit} className="space-y-4">

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
              type={showPassword ? "text" : "password"}
              name="password"
              placeholder="Nhập mật khẩu của bạn"
              value={formData.password}
              onChange={handleChange}
              className="w-full pl-10 pr-10 py-2 border rounded-lg focus:ring-2 focus:ring-emerald-500 focus:outline-none"
            />
            <button
              type="button"
              className="absolute right-3 top-2.5 text-gray-400 hover:text-gray-600 focus:outline-none"
              onClick={() => setShowPassword(!showPassword)}
            >
              {showPassword ? (
                <EyeSlashIcon className="w-5 h-5" />
              ) : (
                <EyeIcon className="w-5 h-5" />
              )}
            </button>
          </div>



          {/* Checkbox */}
          <div className="flex items-center justify-between text-sm">
            <label className="flex items-center space-x-2 text-sm text-gray-600">
              <input type="checkbox" className="rounded" />
              <span>Ghi nhớ đăng nhập</span>
            </label>
            <a href="/forgot-password" className="text-sea-400 hover:underline">
              Quên mật khẩu?
            </a>
          </div>



          {/* Button */}
          <Button
            type="submit"
            className="from-sea-400 to-sea-300 bg-gradient-to-l"
          >
            Đăng nhập
          </Button>
        </form>
        {/* Divider */}
        <div className="flex items-center my-6">
          <div className="flex-grow h-px bg-gray-300"></div>
          <span className="px-2 text-sm text-gray-500">hoặc</span>
          <div className="flex-grow h-px bg-gray-300"></div>
        </div>

        {/* Google Button */}
        <button
          type="button"
          className="w-full flex items-center justify-center gap-2 border border-gray-300 py-2 rounded-lg hover:bg-gray-50 transition"
          onClick={handleGoogleLogin}
        >
          <img
            src="https://www.svgrepo.com/show/355037/google.svg"
            alt="Google"
            className="w-5 h-5"
          />
          <span className="text-gray-700 font-medium">Tiếp tục với Google</span>
        </button>

        {/* Login link */}
        <p className="mt-2 text-sm text-center text-gray-600">
          Bạn chưa có tài khoản?{" "}
          <a href="/register " className="text-sea-400 font-medium hover:underline">
            Tạo tài khoản
          </a>
        </p>
      </div>
    </div>
  );
}

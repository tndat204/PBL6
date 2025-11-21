import { useNavigate } from "react-router-dom";
import { useAuth } from "../hooks/useAuth";

function Unauthorized() {
  const navigate = useNavigate();
  const { user } = useAuth();

  const handleGoBack = () => {
    navigate(-1); // Quay lại trang trước đó
  };

  const handleGoHome = () => {
    navigate("/");
  };

  const handleLogin = () => {
    navigate("/login");
  };

  return (
    <div className="min-h-screen bg-gray-50 flex flex-col justify-center py-12 sm:px-6 lg:px-8">
      <div className="sm:mx-auto sm:w-full sm:max-w-md">
        <div className="text-center">
          {/* Icon cảnh báo */}
          <div className="mx-auto flex items-center justify-center h-24 w-24 rounded-full bg-red-100 mb-6">
            <svg
              className="h-12 w-12 text-red-600"
              fill="none"
              stroke="currentColor"
              viewBox="0 0 24 24"
              xmlns="http://www.w3.org/2000/svg"
            >
              <path
                strokeLinecap="round"
                strokeLinejoin="round"
                strokeWidth="2"
                d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-2.5L13.732 4c-.77-.833-1.964-.833-2.732 0L4.082 16.5c-.77.833.192 2.5 1.732 2.5z"
              />
            </svg>
          </div>

          {/* Tiêu đề */}
          <h1 className="text-4xl font-bold text-gray-900 mb-4">
            Không có quyền truy cập
          </h1>

          {/* Mô tả */}
          <p className="text-lg text-gray-600 mb-8">
            Xin lỗi, bạn không có quyền truy cập vào trang này.
            {!user && " Vui lòng đăng nhập để tiếp tục."}
          </p>

          {/* Thông tin bổ sung */}
          {/* <div className="bg-white shadow rounded-lg p-6 mb-8">
            <div className="text-sm text-gray-500 mb-4">
              <p>
                <strong>Mã lỗi:</strong> 403 - Forbidden
              </p>
              {user && (
                <p>
                  <strong>Tài khoản hiện tại:</strong> {user.fullName || user.username}
                </p>
              )}
            </div>
            
            <div className="text-sm text-gray-600">
              <p className="mb-2">
                Trang này yêu cầu quyền truy cập đặc biệt. Nếu bạn cho rằng đây là lỗi, 
                vui lòng liên hệ với quản trị viên.
              </p>
            </div>
          </div> */}

          {/* Các nút hành động */}
          <div className="flex flex-col sm:flex-row gap-4 justify-center items-center">
            <button
              onClick={handleGoBack}
              className="w-full sm:w-auto px-6 py-3 bg-gray-600 text-white rounded-md hover:bg-gray-700 transition-colors duration-200 focus:outline-none focus:ring-2 focus:ring-gray-500 focus:ring-offset-2"
            >
              ← Quay lại
            </button>

            <button
              onClick={handleGoHome}
              className="w-full sm:w-auto px-6 py-3 bg-sea-400 text-white rounded-md hover:bg-sea-500 transition-colors duration-200 focus:outline-none focus:ring-2 focus:ring-sea-300 focus:ring-offset-2"
            >
              🏠 Về trang chủ
            </button>

            {!user && (
              <button
                onClick={handleLogin}
                className="w-full sm:w-auto px-6 py-3 bg-green-600 text-white rounded-md hover:bg-green-700 transition-colors duration-200 focus:outline-none focus:ring-2 focus:ring-green-500 focus:ring-offset-2"
              >
                🔑 Đăng nhập
              </button>
            )}
          </div>

          {/* Thông tin liên hệ */}
          <div className="mt-8 text-sm text-gray-500">
            <p>
              Cần hỗ trợ? Liên hệ với chúng tôi tại:{" "}
              <a 
                href="mailto:support@itjobhunt.com" 
                className="text-sea-600 hover:text-sea-800 underline"
              >
                support@itjobhunt.com
              </a>
            </p>
          </div>
        </div>
      </div>
    </div>
  );
}

export default Unauthorized;
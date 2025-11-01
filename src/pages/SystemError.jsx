import React from "react";

function SystemError() {
  return (
    <div className="flex flex-col items-center justify-center min-h-screen bg-[#f3f8f6] text-gray-800 px-6">
      <div className="text-center">
        {/* Hình minh họa */}
        <img
          src="../images/error.png"
          alt="System Error"
          className="w-46 mx-auto mb-8"
        />

        {/* Tiêu đề */}
        <h1 className="text-4xl font-extrabold text-gray-900 mb-4">
          System Error
        </h1>

        {/* Mô tả */}
        <p className="text-lg text-gray-500 mb-8 max-w-md mx-auto">
          Oops! Có vẻ như hệ thống đang gặp sự cố.  
          Vui lòng thử lại sau hoặc quay lại trang chủ.
        </p>

        {/* Nút hành động */}
        <div className="space-x-4">
          <a
            href="/"
            className="bg-sea-300 hover:bg-sea-400 text-white px-6 py-2 rounded-lg font-medium shadow transition"
          >
            Back to Home
          </a>
          <button
            onClick={() => window.location.reload()}
            className="border border-sea-300 text-sea-400 hover:bg-sea-100 px-6 py-2 rounded-lg font-medium transition"
          >
            Try Again
          </button>
        </div>
      </div>

      {/* Footer */}
      <footer className="mt-16 text-sm text-gray-500">
        © 2025 IT Job Hunt.
      </footer>
    </div>
  );
}

export default SystemError;

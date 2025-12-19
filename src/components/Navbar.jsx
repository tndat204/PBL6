import { useState, useEffect } from "react";
import { useRef } from "react";
import { useAuth } from "../hooks/useAuth";
import { Navigate } from "react-router-dom";
import { USER_ROLES } from "../contexts/AuthContext";
function Navbar() {
  const { user, logout } = useAuth();
  const role = user?.roles?.[0]?.name || null;
  console.log("role", role);
  const [isMenuOpen, setIsMenuOpen] = useState(false);
  // const [user, setUser] = useState(null);
  const [isUserMenuOpen, setIsUserMenuOpen] = useState(false);
  const toggleMenu = () => {
    setIsMenuOpen(!isMenuOpen);
  };
  const toggleUserMenu = (e) => {
    e.stopPropagation();
    setIsUserMenuOpen(!isUserMenuOpen);
  };
  const onLogout = () => {
    // Xoa token va user khoi LocalStorage
    if (confirm("Bạn có chắc chắn muốn đăng xuất?")) {
      logout();
    }
  };
  const userMenuRef = useRef(null);
  const userToggleRef = useRef(null);

  useEffect(() => {
    function handleClickOutside(event) {
      if (
        isUserMenuOpen &&
        userMenuRef.current &&
        !userMenuRef.current.contains(event.target) &&
        userToggleRef.current &&
        !userToggleRef.current.contains(event.target)
      ) {
        setIsUserMenuOpen(false);
      }
    }
    document.addEventListener("mousedown", handleClickOutside);
    return () => {
      document.removeEventListener("mousedown", handleClickOutside);
    };
  }, [isUserMenuOpen]);

  const getUserMenuItems = () => {
    const commonItems = [{ href: "/profile", label: "Hồ sơ cá nhân" }];

    switch (role) {
      case USER_ROLES.USER:
        return [
          ...commonItems,
          { href: "/my-applications", label: "Đơn ứng tuyển" },
        ];

      case USER_ROLES.RECRUITER:
        return [
          ...commonItems,
          { href: "/post-job", label: "Đăng tin tuyển dụng" },
          { href: "/company-posts", label: "Quản lý tin đăng" },
          { href: "/applications", label: "Đơn ứng tuyển" },
        ];

      case USER_ROLES.ADMIN:
        return [
          ...commonItems,
          { href: "/admin", label: "Quản trị hệ thống" },
          { href: "/manage-users", label: "Quản lý người dùng" },
        ];

      default:
        return commonItems;
    }
  };

  return (
    <nav className="bg-gradient-to-br from-slate-700 via-slate-800 to-slate-900 text-white p-4 shadow-lg sticky top-0 z-50">
      <div className="max-w-7xl mx-auto px-6 flex justify-between items-center">
        <div className="flex items-center space-x-3">
          <a
            href="http://localhost:3000/"
            className="text-2xl font-bold text-white"
          >
            IT Job Hunt
          </a>
        </div>
        <ul className="hidden md:flex space-x-6 font-medium">
          <li>
            <a
              href="/"
              className="relative px-3 py-2 transition-all duration-300 hover:text-emerald-400"
            >
              Trang Chủ
            </a>
          </li>
          <li>
            <a
              href="/jobs"
              className="relative px-3 py-2 transition-all duration-300 hover:text-emerald-400"
            >
              Việc Làm
            </a>
          </li>
          <li>
            <a
              href="/career-tips"
              className="relative px-3 py-2 transition-all duration-300 hover:text-emerald-400"
            >
              Mẹo Nghề Nghiệp
            </a>
          </li>
          <li>
            <a
              href="/contact"
              className="relative px-3 py-2 transition-all duration-300 hover:text-emerald-400"
            >
              Liên Hệ
            </a>
          </li>
        </ul>
        <div className="flex items-center space-x-4">
          {/* <div className="flex items-center space-x-2">
            <div className="w-10 h-10 bg-gradient-to-br from-green-400 to-blue-500 rounded-full flex items-center justify-center text-white font-semibold">
              U
            </div>
            <span className="hidden md:block text-gray-200 font-medium">Thanh Huy</span>
          </div> */}
          {user ? (
            //  Nếu có user, hiển thị avatar + tên
            // <div className="flex items-center space-x-2">
            //   <div className="w-10 h-10 bg-gradient-to-br from-green-400 to-blue-500 rounded-full flex items-center justify-center text-white font-semibold">
            //     {user.fullName?.charAt(0)?.toUpperCase() || "U"}
            //   </div>
            //   <span className="hidden md:block text-gray-200 font-medium">
            //     {user.username || "Người dùng"}
            //   </span>
            // </div>
            <div className="relative">
              <button
                ref={userToggleRef}
                onClick={toggleUserMenu}
                className="flex items-center space-x-2 hover:bg-slate-700 rounded-lg px-3 py-2 transition-colors"
              >
                <div className="w-10 h-10 bg-gradient-to-br from-green-400 to-blue-500 rounded-full flex items-center justify-center text-white font-semibold">
                  {user.fullName?.charAt(0)?.toUpperCase() ||
                    user.username?.charAt(0)?.toUpperCase() ||
                    "U"}
                </div>
                <span className="hidden md:block text-gray-200 font-medium">
                  {user.fullName || user.username || "Người dùng"}
                </span>
                <svg
                  className={`w-4 h-4 transition-transform ${isUserMenuOpen ? "rotate-180" : ""
                    }`}
                  fill="none"
                  stroke="currentColor"
                  viewBox="0 0 24 24"
                >
                  <path
                    strokeLinecap="round"
                    strokeLinejoin="round"
                    strokeWidth="2"
                    d="M19 9l-7 7-7-7"
                  />
                </svg>
              </button>

              {/* Dropdown Menu */}
              {isUserMenuOpen && (
                <div
                  ref={userMenuRef}
                  className="absolute right-0 mt-2 w-48 bg-white rounded-md shadow-lg py-1 z-50"
                >
                  {getUserMenuItems().map((item, index) => (
                    <a
                      key={index}
                      href={item.href}
                      className="block px-4 py-2 text-sm text-gray-700 hover:bg-gray-100 transition-colors"
                      onClick={() => setIsUserMenuOpen(false)}
                    >
                      {item.label}
                    </a>
                  ))}
                  <hr className="my-1" />
                  <button
                    onClick={onLogout}
                    className="block w-full text-left px-4 py-2 text-sm text-red-600 hover:bg-gray-100 transition-colors"
                  >
                    Đăng xuất
                  </button>
                </div>
              )}
            </div>
          ) : (
            <div className="flex items-center space-x-0">
              <a
                href="/login"
                className="px-4 rounded-lg hover:text-emerald-400 transition"
              >
                Đăng nhập
              </a>
              <p>|</p>
              <a
                href="/register"
                className="px-4 rounded-lg hover:text-emerald-400 transition"
              >
                Đăng ký
              </a>
            </div>
          )}
          <button
            className="md:hidden text-white focus:outline-none"
            onClick={toggleMenu}
            aria-label="Toggle menu"
          >
            <svg
              className="w-7 h-7"
              fill="none"
              stroke="currentColor"
              viewBox="0 0 24 24"
              xmlns="http://www.w3.org/2000/svg"
            >
              <path
                strokeLinecap="round"
                strokeLinejoin="round"
                strokeWidth="2"
                d={
                  isMenuOpen
                    ? "M6 18L18 6M6 6l12 12"
                    : "M4 6h16M4 12h16M4 18h16"
                }
              ></path>
            </svg>
          </button>
        </div>
      </div>
      {isMenuOpen && (
        <ul className="md:hidden mt-2 space-y-3 bg-slate-800 rounded-lg p-4 shadow-lg absolute right-4 top-16">
          <li>
            <a
              href="/"
              className="block px-3 py-2 hover:text-gray-200 transition-colors duration-300"
              onClick={() => setIsMenuOpen(false)}
            >
              Trang Chủ
            </a>
          </li>
          <li>
            <a
              href="/jobs"
              className="block px-3 py-2 hover:text-gray-200 transition-colors duration-300"
              onClick={() => setIsMenuOpen(false)}
            >
              Việc Làm
            </a>
          </li>
          <li>
            <a
              href="/career-tips"
              className="block px-3 py-2 hover:text-gray-200 transition-colors duration-300"
              onClick={() => setIsMenuOpen(false)}
            >
              Mẹo Nghề Nghiệp
            </a>
          </li>
          <li>
            <a
              href="/contact"
              className="block px-3 py-2 hover:text-gray-200 transition-colors duration-300"
              onClick={() => setIsMenuOpen(false)}
            >
              Liên Hệ
            </a>
          </li>
        </ul>
      )}
    </nav>
  );
}

export default Navbar;

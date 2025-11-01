import { useState, useEffect  } from 'react';

function Navbar() {
  const [isMenuOpen, setIsMenuOpen] = useState(false);
  const [user, setUser] = useState(null);
  const toggleMenu = () => {
    setIsMenuOpen(!isMenuOpen);
  };
  useEffect(() => {
      const storedUser = localStorage.getItem("user");
      if (storedUser) {
        try {
          setUser(JSON.parse(storedUser));
        } catch {
          console.error("Dữ liệu user trong localStorage không hợp lệ");
        }
      }
    }, []);
  return (
    <nav className="bg-sea-400 text-white p-4 shadow-lg sticky top-0 z-50">
      <div className="max-w-7xl mx-auto px-6 flex justify-between items-center">
        <div className="flex items-center space-x-3">
          <a href='http://localhost:3000/' className="text-2xl font-bold text-white">IT Job Hunt</a>
        </div>
        <ul className="hidden md:flex space-x-6 font-medium">
          {['Home', 'Jobs',  'Contact'].map((item) => (
            <li key={item}>
              <a
                href="#"
                className="relative px-3 py-2 transition-all duration-300 hover:text-green-300"
              >
                {item}
              </a>
            </li>
          ))}
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
            <div className="flex items-center space-x-2">
              <div className="w-10 h-10 bg-gradient-to-br from-green-400 to-blue-500 rounded-full flex items-center justify-center text-white font-semibold">
                {user.name?.charAt(0)?.toUpperCase() || "U"}
              </div>
              <span className="hidden md:block text-gray-200 font-medium">
                {user.username || "Người dùng"}
              </span>
            </div>
          ) : (
            <div className="flex items-center space-x-0">
              <a
                href="/login"
                className="px-4 rounded-lg hover:text-sea-200 transition"
              >
                Đăng nhập
              </a>
              <p>|</p>
              <a
                href="/register"
                className="px-4 rounded-lg hover:text-sea-200 transition"
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
                d={isMenuOpen ? 'M6 18L18 6M6 6l12 12' : 'M4 6h16M4 12h16M4 18h16'}
              ></path>
            </svg>
          </button>
        </div>
      </div>
      {isMenuOpen && (
        <ul className="md:hidden mt-2 space-y-3 bg-green-700 rounded-lg p-4 shadow-lg absolute right-4 top-16">
          {['Home', 'Jobs', 'Pages', 'Contact'].map((item) => (
            <li key={item}>
              <a
                href="#"
                className="block px-3 py-2 hover:text-gray-200 transition-colors duration-300"
                onClick={() => setIsMenuOpen(false)}
              >
                {item}
              </a>
            </li>
          ))}
        </ul>
      )}
    </nav>
  );
}

export default Navbar;
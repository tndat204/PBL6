import { useState } from "react";
import { AuthContext } from "../contexts/AuthContext";
import { handleLoginSuccess, handleLogout } from "./authUtils";

export function AuthProvider({ children }) {
   const [user, setUser] = useState(() => {
    const storedUser = localStorage.getItem("user");
    if (!storedUser) return null;

    try {
      return JSON.parse(storedUser);
    } catch (error) {
      console.error("Dữ liệu user không hợp lệ", error);
      localStorage.removeItem("user");
      return null;
    }
  });

  const login = async (token) => {
    await handleLoginSuccess(token);
    const storedUser = localStorage.getItem("user");
    if (storedUser) {
      try {
        setUser(JSON.parse(storedUser));
      } catch (error) {
        console.error("Lỗi khi parse user data", error);
      }
    }
  };

  const logout = async () => {
    await handleLogout();
    setUser(null);
  };
  const role = user?.roles?.[0]?.name || null;

  return (
    <AuthContext.Provider value={{ user, role, login, logout }}>
      {children}
    </AuthContext.Provider>
  );
}

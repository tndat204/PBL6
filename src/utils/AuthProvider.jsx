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

  // State company
  const [company, setCompany] = useState(() => {
    const storedCompany = localStorage.getItem("company");
    if (!storedCompany) return null;
    try {
        return JSON.parse(storedCompany);
    } catch (error) {
        console.error("Error parsing company data", error);
        localStorage.removeItem("company");
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
    // Update company state
    const storedCompany = localStorage.getItem("company");
    if (storedCompany) {
        try {
            setCompany(JSON.parse(storedCompany));
        } catch (error) {
            console.error("Error parsing company data on login", error);
        }
    } else {
        setCompany(null);
    }
  };

  const logout = async () => {
    await handleLogout();
    setUser(null);
    setCompany(null);
  };
  
  // Update user data (for profile updates)
  const updateUser = (updates) => {
    const updatedUser = { ...user, ...updates };
    setUser(updatedUser);
    localStorage.setItem("user", JSON.stringify(updatedUser));
  };
  const role = user?.roles?.[0]?.name || null;

  return (
    <AuthContext.Provider value={{ user, company, role, login, logout, updateUser }}>
      {children}
    </AuthContext.Provider>
  );
}

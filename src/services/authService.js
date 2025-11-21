import apiService from "./api";

export const authService = {
  // Đăng nhập
  async login(credentials) {
    try {
      
      const response = await apiService.post("/auth/token", credentials, { auth: false });
      return response.result || response;
    } catch (error) {
      console.error("Lỗi khi đăng nhập:", error);
      throw error;
    }
  },

  // Đăng xuất
  async logout() {
    try {
      await apiService.post("/auth/logout");
    } catch (error) {
      console.error("Lỗi khi đăng xuất:", error);
      throw error;
    }
  },

  // Đăng nhập Google
  async googleLogin(code) {
    try {
      const response = await apiService.post(`/auth/google-web?code=${code}`, {}, { auth: false });
      return response.result || response;
    } catch (error) {
      console.error("Lỗi khi đăng nhập Google:", error);
      throw error;
    }
  },

  // Lấy thông tin user hiện tại
  async getCurrentUser() {
    try {
      const response = await apiService.get("/users/me");
      return response.result || response;
    } catch (error) {
      console.error("Lỗi khi lấy thông tin user:", error);
      throw error;
    }
  },
};
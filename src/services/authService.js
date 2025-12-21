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

  // ===== FORGOT PASSWORD FLOW =====
  
  /**
   * Send OTP to email for password reset
   * @param {string} email 
   */
  async sendPasswordResetOTP(email) {
    try {
      const response = await apiService.post('/auth/otp/password/send', { email }, { auth: false });
      return response;
    } catch (error) {
      console.error('Error sending OTP:', error);
      throw error;
    }
  },

  /**
   * Verify OTP code
   * @param {string} email 
   * @param {string} otp 
   */
  async verifyOTP(email, otp) {
    try {
      const response = await apiService.post('/auth/otp/verify', { email, otp }, { auth: false });
      return response;
    } catch (error) {
      console.error('Error verifying OTP:', error);
      throw error;
    }
  },

  /**
   * Reset password (requires verified OTP session)
   * @param {string} newPassword 
   * @param {string} token - Reset token from OTP verification
   */
  async resetPassword(newPassword, token) {
    try {
      const response = await apiService.post(
        '/auth/password/reset', 
        { newPassword }, 
        { 
          auth: false,
          headers: {
            'Authorization': `Bearer ${token}`
          }
        }
      );
      return response;
    } catch (error) {
      console.error('Error resetting password:', error);
      throw error;
    }
  },
};
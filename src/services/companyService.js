import apiService from "./api";

export const companyService = {
  // Lấy thông tin company theo ID
  async getCompanyById(id) {
    try {
      const response = await apiService.get(`/companies/${id}`);
      return response.result || response;
    } catch (error) {
      console.error(`Lỗi khi lấy company ${id}:`, error);
      throw error;
    }
  },

  // Lấy danh sách companies
  async getAllCompanies() {
    try {
      const response = await apiService.get("/companies");
      return response.result || response;
    } catch (error) {
      console.error("Lỗi khi lấy danh sách companies:", error);
      throw error;
    }
  },

  // Kích hoạt company
  async activateCompany(id) {
    try {
      const response = await apiService.put(`/companies/${id}/activate`, {});
      return response;
    } catch (error) {
      console.error(`Lỗi khi kích hoạt company ${id}:`, error);
      throw error;
    }
  },

  // Vô hiệu hóa company
  async deactivateCompany(id) {
    try {
      const response = await apiService.put(`/companies/${id}/deactivate`, {});
      return response;
    } catch (error) {
      console.error(`Lỗi khi vô hiệu hóa company ${id}:`, error);
      throw error;
    }
  },

  // Tạo mới company
  async createCompany(companyData) {
    try {
      const response = await apiService.post("/companies", companyData);
      return response.result || response;
    } catch (error) {
      console.error("Lỗi khi tạo company:", error);
      throw error;
    }
  },

  // Xóa company
  async deleteCompany(id) {
    try {
      const response = await apiService.delete(`/companies/${id}`);
      return response;
    } catch (error) {
      console.error(`Lỗi khi xóa company ${id}:`, error);
      throw error;
    }
  },
  // Lấy thông tin company của user hiện tại (Recruiter)
  async getMyCompany() {
    try {
      // Endpoint provided by user: /api/companies/me
      const response = await apiService.get("/companies/me");
      return response.result || response;
    } catch (error) {
      console.error("Lỗi khi lấy thông tin company của tôi:", error);
      // Suppress error if 404 (user might not have created company yet)
      return null;
    }
  },

  // Cập nhật thông tin company
  async updateCompany(id, companyData) {
    try {
      const response = await apiService.put(`/companies/${id}`, companyData);
      return response.result || response;
    } catch (error) {
      console.error(`Lỗi khi cập nhật company ${id}:`, error);
      throw error;
    }
  },

  // Upload logo company
  async uploadLogo(id, file) {
    try {
      const formData = new FormData();
      formData.append("file", file);

      // Note: apiService.put handles FormData automatically
      const response = await apiService.put(`/companies/${id}/logo`, formData);
      return response.result || response;
    } catch (error) {
      console.error(`Lỗi khi upload logo company ${id}:`, error);
      throw error;
    }
  },
};
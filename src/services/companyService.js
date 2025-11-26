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
};
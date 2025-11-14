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
};
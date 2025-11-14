import apiService from "./api";

export const categoryService = {
  // Lấy danh sách categories
  async getAllCategories() {
    try {
      const response = await apiService.get("/categories");
      return response.result || response;
    } catch (error) {
      console.error("Lỗi khi lấy danh sách categories:", error);
      throw error;
    }
  },

  // Lấy category theo ID
  async getCategoryById(id) {
    try {
      const response = await apiService.get(`/categories/${id}`);
      return response.result || response;
    } catch (error) {
      console.error(`Lỗi khi lấy category ${id}:`, error);
      throw error;
    }
  },
};
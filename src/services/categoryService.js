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

  // Tạo category mới
  async createCategory(categoryData) {
    try {
      const response = await apiService.post("/categories", categoryData);
      return response.result || response;
    } catch (error) {
      console.error("Lỗi khi tạo category:", error);
      throw error;
    }
  },

  // Cập nhật category
  async updateCategory(id, categoryData) {
    try {
      const response = await apiService.put(`/categories/${id}`, categoryData);
      return response.result || response;
    } catch (error) {
      console.error(`Lỗi khi cập nhật category ${id}:`, error);
      throw error;
    }
  },

  // Xóa category
  async deleteCategory(id) {
    try {
      const response = await apiService.delete(`/categories/${id}`);
      return response;
    } catch (error) {
      console.error(`Lỗi khi xóa category ${id}:`, error);
      throw error;
    }
  },
};
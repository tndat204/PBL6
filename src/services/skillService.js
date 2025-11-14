import apiService from "./api";

export const skillService = {
  // Lấy thông tin skill theo ID
  async getSkillById(id) {
    try {
      const response = await apiService.get(`/skills/${id}`);
      return response.result || response;
    } catch (error) {
      console.error(`Lỗi khi lấy skill ${id}:`, error);
      throw error;
    }
  },

  // Lấy danh sách skills theo category ID
  async getSkillsByCategory(categoryId) {
    try {
      const response = await apiService.get(`/skills?categoryId=${categoryId}`);
      return response.result || response;
    } catch (error) {
      console.error("Lỗi khi lấy danh sách skills:", error);
      throw error;
    }
  },

  // Lấy nhiều skills theo danh sách IDs
  async getSkillsByIds(skillIds) {
    try {
      const skillPromises = skillIds.map(id => this.getSkillById(id));
      const skills = await Promise.all(skillPromises);
      return skills.map(skill => skill?.name || "Unknown");
    } catch (error) {
      console.error("Lỗi khi lấy skills:", error);
      return skillIds; // Fallback trả về IDs
    }
  },
};
import apiService from "./api";

export const skillService = {
  // Lấy tất cả skills
  async getAllSkills() {
    try {
      const response = await apiService.get("/skills");
      return response.result || response;
    } catch (error) {
      console.error("Lỗi khi lấy danh sách skills:", error);
      throw error;
    }
  },

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

  // Tạo skill mới
  async createSkill(skillData) {
    try {
      const response = await apiService.post("/skills", skillData);
      console.log("response", response);
      return response.result || response;
    } catch (error) {
      console.error("Lỗi khi tạo skill:", error);
      throw error;
    }
  },

  // Cập nhật skill
  async updateSkill(id, skillData) {
    try {
      const response = await apiService.put(`/skills/${id}`, skillData);
      return response.result || response;
    } catch (error) {
      console.error(`Lỗi khi cập nhật skill ${id}:`, error);
      throw error;
    }
  },

  // Xóa skill
  async deleteSkill(id) {
    try {
      const response = await apiService.delete(`/skills/${id}`);
      return response;
    } catch (error) {
      console.error(`Lỗi khi xóa skill ${id}:`, error);
      throw error;
    }
  },
};
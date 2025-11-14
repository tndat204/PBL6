import apiService from "./api";
// Đặt tên cho đối tượng ApiService là apiService

export const jobService = {
  // Lấy danh sách jobs
  async getAllJobs() {
    try {
      const response = await apiService.get("/jobs");
      return response.result || response;
    } catch (error) {
      console.error("Lỗi khi lấy danh sách jobs:", error);
      throw error;
    }
  },

  // Lấy job theo ID
  async getJobById(id) {
    try {
      const response = await apiService.get(`/jobs/${id}`);
      return response.result || response;
    } catch (error) {
      console.error(`Lỗi khi lấy job ${id}:`, error);
      throw error;
    }
  },

  // Tạo job mới
  async createJob(jobData) {
    try {
      const response = await apiService.post("/jobs", jobData);
      return response.result || response;
    } catch (error) {
      console.error("Lỗi khi tạo job:", error);
      throw error;
    }
  },

  // Cập nhật job
  async updateJob(id, jobData) {
    try {
      const response = await apiService.put(`/jobs/${id}`, jobData);
      return response.result || response;
    } catch (error) {
      console.error(`Lỗi khi cập nhật job ${id}:`, error);
      throw error;
    }
  },

  // Xóa job
  async deleteJob(id) {
    try {
      const response = await apiService.delete(`/jobs/${id}`);
      return response.result || response;
    } catch (error) {
      console.error(`Lỗi khi xóa job ${id}:`, error);
      throw error;
    }
  },
};
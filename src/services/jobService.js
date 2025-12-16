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
      // Backend chỉ chấp nhận multipart/form-data, nên luôn dùng FormData
      const formData = new FormData();

      // Append required fields
      formData.append('companyId', jobData.companyId);
      formData.append('title', jobData.title);
      formData.append('description', jobData.description);
      formData.append('status', jobData.status);
      formData.append('jobType', jobData.jobType);
      formData.append('experienceLevel', jobData.experienceLevel);
      formData.append('location', jobData.location);

      // Format expiryDate for LocalDateTime backend
      // date input returns: "2025-12-31"
      // Backend needs: "2025-12-31T23:59:59" (end of day)
      const expiryDateFormatted = jobData.expiryDate.includes('T')
        ? jobData.expiryDate  // Already has time
        : `${jobData.expiryDate}T23:59:59`;  // Add end of day time
      formData.append('expiryDate', expiryDateFormatted);

      // Append optional numeric fields only if they have values
      if (jobData.salaryMin !== undefined && jobData.salaryMin !== null && jobData.salaryMin !== '') {
        formData.append('salaryMin', jobData.salaryMin);
      }
      if (jobData.salaryMax !== undefined && jobData.salaryMax !== null && jobData.salaryMax !== '') {
        formData.append('salaryMax', jobData.salaryMax);
      }
      if (jobData.requiredYearsOfExpMin !== undefined && jobData.requiredYearsOfExpMin !== null && jobData.requiredYearsOfExpMin !== '') {
        formData.append('requiredYearsOfExpMin', jobData.requiredYearsOfExpMin);
      }
      if (jobData.requiredYearsOfExpMax !== undefined && jobData.requiredYearsOfExpMax !== null && jobData.requiredYearsOfExpMax !== '') {
        formData.append('requiredYearsOfExpMax', jobData.requiredYearsOfExpMax);
      }

      // Append file if exists
      if (jobData.jdFile) {
        formData.append('jdFile', jobData.jdFile);
      }

      // Append arrays
      if (jobData.categoryIds && jobData.categoryIds.length > 0) {
        jobData.categoryIds.forEach(id => formData.append('categoryIds', id));
      }
      if (jobData.skillIds && jobData.skillIds.length > 0) {
        jobData.skillIds.forEach(id => formData.append('skillIds', id));
      }

      // Debug: Log FormData contents
      console.log('=== Creating Job - FormData Contents ===');
      for (let [key, value] of formData.entries()) {
        console.log(`${key}:`, value);
      }
      console.log('========================================');

      // Use apiService.post with FormData
      const response = await apiService.post("/jobs", formData);
      return response.result || response;
    } catch (error) {
      console.error("Lỗi khi tạo job:", error);
      throw error;
    }
  },

  // Cập nhật job
  async updateJob(id, jobData) {
    try {
      // Backend chỉ chấp nhận multipart/form-data, nên luôn dùng FormData
      const formData = new FormData();

      // Append required fields
      formData.append('companyId', jobData.companyId);
      formData.append('title', jobData.title);
      formData.append('description', jobData.description);
      formData.append('status', jobData.status);
      formData.append('jobType', jobData.jobType);
      formData.append('experienceLevel', jobData.experienceLevel);
      formData.append('location', jobData.location);

      // Format expiryDate for LocalDateTime backend
      const expiryDateFormatted = jobData.expiryDate.includes('T')
        ? jobData.expiryDate
        : `${jobData.expiryDate}T23:59:59`;
      formData.append('expiryDate', expiryDateFormatted);

      // Append optional numeric fields only if they have values
      if (jobData.salaryMin !== undefined && jobData.salaryMin !== null && jobData.salaryMin !== '') {
        formData.append('salaryMin', jobData.salaryMin);
      }
      if (jobData.salaryMax !== undefined && jobData.salaryMax !== null && jobData.salaryMax !== '') {
        formData.append('salaryMax', jobData.salaryMax);
      }
      if (jobData.requiredYearsOfExpMin !== undefined && jobData.requiredYearsOfExpMin !== null && jobData.requiredYearsOfExpMin !== '') {
        formData.append('requiredYearsOfExpMin', jobData.requiredYearsOfExpMin);
      }
      if (jobData.requiredYearsOfExpMax !== undefined && jobData.requiredYearsOfExpMax !== null && jobData.requiredYearsOfExpMax !== '') {
        formData.append('requiredYearsOfExpMax', jobData.requiredYearsOfExpMax);
      }

      // Append file if exists
      if (jobData.jdFile) {
        formData.append('jdFile', jobData.jdFile);
      }

      // Append arrays
      if (jobData.categoryIds && jobData.categoryIds.length > 0) {
        jobData.categoryIds.forEach(id => formData.append('categoryIds', id));
      }
      if (jobData.skillIds && jobData.skillIds.length > 0) {
        jobData.skillIds.forEach(id => formData.append('skillIds', id));
      }

      // Debug: Log FormData contents
      console.log(`=== Updating Job ${id} - FormData Contents ===`);
      for (let [key, value] of formData.entries()) {
        console.log(`${key}:`, value);
      }
      console.log('========================================');

      // Use apiService.put with FormData
      const response = await apiService.put(`/jobs/${id}`, formData);
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
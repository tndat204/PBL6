import api from "./api";

/**
 * Application Service
 * Handles all API calls related to job applications
 */

const applicationService = {
  /**
   * Apply for a job (for candidates)
   */
  async applyJob(formData) {
    return api.post("/applications", formData);
  },

  /**
   * Get all applications for jobs posted by a company
   */
  // async getApplicationsByCompany(companyId) {
  //   try {
  //     const jobsResponse = await api.get(`/jobs/company/${companyId}`);
  //     const jobs = jobsResponse.data.result || jobsResponse.data;

  //     const applicationPromises = jobs.map(job => 
  //       this.getApplicationsByJob(job.id).catch(() => [])
  //     );

  //     const applicationsArrays = await Promise.all(applicationPromises);
  //     const allApplications = applicationsArrays.flat();

  //     return allApplications;
  //   } catch (error) {
  //     console.error("Error fetching company applications:", error);
  //     throw error;
  //   }
  // },

  /**
   * Get applications for a specific job
   */
  async getApplicationsByJob(jobId) {
    try {
      const response = await api.get(`/applications/job/${jobId}`);
      console.log(`RAW Response for job ${jobId}:`, response);
      console.log('Response type:', typeof response);
      console.log('Response keys:', Object.keys(response || {}));

      // Handle different response structures
      if (response.result !== undefined) {
        return response.result;
      }
      if (response.data !== undefined) {
        return response.data.result || response.data;
      }
      return response;
    } catch (error) {
      console.error(`Error fetching applications for job ${jobId}:`, error);
      throw error;
    }
  },

  /**
   * Get application details by ID
   */
  async getApplicationById(id) {
    try {
      const response = await api.get(`/applications/${id}`);
      return response.data.result || response.data;
    } catch (error) {
      console.error(`Error fetching application ${id}:`, error);
      throw error;
    }
  },

  /**
   * Get applications for current user (candidate)
   */
  async getMyApplications() {
    try {
      const response = await api.get("/applications/me");
      return response.result || response;
    } catch (error) {
      console.error("Error fetching my applications:", error);
      throw error;
    }
  },

  /**
   * Update application status
   */
  async updateApplicationStatus(id, status) {
    try {
      const response = await api.put(`/applications/${id}/status`, { status });
      return response.data.result || response.data;
    } catch (error) {
      console.error(`Error updating application ${id} status:`, error);
      throw error;
    }
  },

  /**
   * Add or update notes for an application
   */
  async updateApplicationNotes(id, notes) {
    try {
      const response = await api.put(`/applications/${id}/notes`, { notes });
      return response.data.result || response.data;
    } catch (error) {
      console.error(`Error updating application ${id} notes:`, error);
      throw error;
    }
  },

  /**
   * Delete an application
   */
  async deleteApplication(id) {
    try {
      const response = await api.delete(`/applications/${id}`);
      return response.data;
    } catch (error) {
      console.error(`Error deleting application ${id}:`, error);
      throw error;
    }
  },
};

export default applicationService;
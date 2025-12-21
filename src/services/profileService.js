import apiService from "./api";

export const profileService = {
  /**
   * Get current user's profile
   * GET /api/profiles/me
   * @returns {Promise<Object>} Current user's profile data
   */
  async getMyProfile() {
    try {
      const response = await apiService.get("/profiles/me");
      return response.result || response;
    } catch (error) {
      console.error("Error fetching my profile:", error);
      throw error;
    }
  },

  /**
   * Update current user's profile
   * PUT /api/profiles/me
   * @param {Object} profileData - Profile data to update
   * @returns {Promise<Object>} Updated profile data
   */
  async updateMyProfile(profileData) {
    try {
      const response = await apiService.put("/profiles/me", profileData);
      return response.result || response;
    } catch (error) {
      console.error("Error updating my profile:", error);
      throw error;
    }
  },

  /**
   * Update profile status
   * PUT /api/profiles/me/status
   * @param {string} status - New status
   * @returns {Promise<Object>} Updated profile
   */
  async updateProfileStatus(status) {
    try {
      const response = await apiService.put("/profiles/me/status", { status });
      return response.result || response;
    } catch (error) {
      console.error("Error updating profile status:", error);
      throw error;
    }
  },

  /**
   * Get CV file
   * GET /api/profiles/me/cv
   * @returns {Promise<Blob>} CV file blob
   */
  async getMyCv() {
    try {
      const response = await apiService.get("/profiles/me/cv", {
        responseType: 'blob'
      });
      return response;
    } catch (error) {
      console.error("Error fetching CV:", error);
      throw error;
    }
  },

  /**
   * Upload/Update CV file
   * PUT /api/profiles/me/cv
   * @param {File} cvFile - CV file to upload
   * @returns {Promise<Object>} Upload result with CV URL
   */
  async uploadMyCv(cvFile) {
    try {
      const formData = new FormData();
      formData.append('file', cvFile);

      const response = await apiService.put("/profiles/me/cv", formData);
      return response.result || response;
    } catch (error) {
      console.error("Error uploading CV:", error);
      throw error;
    }
  },

  /**
   * Create a new profile
   * POST /api/profiles
   * @param {Object} profileData - Profile data for new profile
   * @returns {Promise<Object>} Created profile
   */
  async createProfile(profileData) {
    try {
      const response = await apiService.post("/profiles", profileData);
      return response.result || response;
    } catch (error) {
      console.error("Error creating profile:", error);
      throw error;
    }
  },

  /**
   * Get profile by user ID
   * GET /api/profiles/{userId}
   * @param {string} userId - User ID
   * @returns {Promise<Object>} User's profile data
   */
  async getProfileByUserId(userId) {
    try {
      const response = await apiService.get(`/profiles/${userId}`);
      return response.result || response;
    } catch (error) {
      console.error(`Error fetching profile for user ${userId}:`, error);
      throw error;
    }
  }
};

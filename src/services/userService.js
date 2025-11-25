import apiService from './api';

class UserService {
    /**
     * Get all users from the user service
     * @returns {Promise<Object>} Response with user list
     */
    async getAllUsers() {
        try {
            const response = await apiService.get("/users");
            console.log('User response:', response);
            return response; // Return full response so component can check response.code
        } catch (error) {
            console.error("Lỗi khi lấy danh sách users:", error);
            throw error;
        }
    }

    /**
     * Get user by ID
     * @param {string} userId - User ID
     * @returns {Promise<Object>} User data
     */
    async getUserById(userId) {
        try {
            const response = await apiService.get(`/users/${userId}`);
            return response.result || response;
        } catch (error) {
            console.error(`Error fetching user ${userId}:`, error);
            throw error;
        }
    }

    /**
     * Update user information
     * @param {string} userId - User ID
     * @param {Object} userData - Updated user data
     * @returns {Promise<Object>} Updated user data
     */
    async updateUser(userId, userData) {
        try {
            const response = await apiService.put(`/users/${userId}`, userData);
            return response.result || response;
        } catch (error) {
            console.error(`Error updating user ${userId}:`, error);
            throw error;
        }
    }

    /**
     * Delete user
     * @param {string} userId - User ID
     * @returns {Promise<Object>} Updated user data
     */
    async deleteUser(userId) {
        try {
            const response = await apiService.delete(`/users/${userId}`);
            return response.result || response;
        } catch (error) {
            console.error(`Error deleting user ${userId}:`, error);
            throw error;
        }
    }
    /**
     * Create a new user
     * @param {Object} userData - User data to create
     * @returns {Promise<Object>} Created user response
     */
    async createUser(userData) {
        try {
            const token = apiService.getToken();
            const response = await fetch("http://localhost:8080/api/internal/users", {
                method: "POST",
                headers: {
                    "Content-Type": "application/json",
                    ...(token ? { "Authorization": `Bearer ${token}` } : {})
                },
                body: JSON.stringify(userData)
            });

            if (!response.ok) {
                const errorData = await response.json().catch(() => ({}));
                throw new Error(errorData.message || `HTTP error! status: ${response.status}`);
            }

            const data = await response.json();
            return data.result || data;
        } catch (error) {
            console.error('Error creating user:', error);
            throw error;
        }
    }


    /**
     * Toggle user status (enable/disable)
     * @param {string} userId - User ID
     * @param {boolean} isEnabled - Enable/disable status
     * @returns {Promise<Object>} Updated user data
     */
    async toggleUserStatus(userId, isEnabled) {
        try {
            const response = await apiService.put(`/users/${userId}/status`, { isEnabled });
            return response.result || response;
        } catch (error) {
            console.error(`Error toggling user status ${userId}:`, error);
            throw error;
        }
    }

    /**
     * Transform backend user data to frontend format
     * @param {Object} backendUser - User data from backend
     * @returns {Object} Transformed user data
     */
    transformUser(backendUser) {
        const name = backendUser.fullName || backendUser.username || 'Unknown';
        const avatarLetter = name.charAt(0).toUpperCase();

        return {
            id: backendUser.id,
            name: name,
            email: backendUser.email,
            phone: backendUser.phone || 'N/A',
            address: backendUser.address || 'N/A',
            location: backendUser.address || 'Chưa cập nhật',
            avatar: backendUser.avatarUrl || avatarLetter,
            role: backendUser.roles?.[0]?.name || 'USER',
            status: backendUser.isEnabled ? 'Active' : 'Banned',
            // Additional fields that might be useful
            username: backendUser.username,
            permissions: backendUser.roles?.[0]?.permissions || [],
            isEnabled: backendUser.isEnabled
        };
    }

    /**
     * Transform multiple users
     * @param {Array} users - Array of backend users
     * @returns {Array} Array of transformed users
     */
    transformUsers(users) {
        return users.map(user => this.transformUser(user));
    }
}

export default new UserService();

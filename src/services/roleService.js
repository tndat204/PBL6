import apiService from "./api";

export const roleService = {
    // Lấy danh sách tất cả roles
    async getAllRoles() {
        try {
            const response = await apiService.get("/roles");
            return response.result || response;
        } catch (error) {
            console.error("Lỗi khi lấy danh sách roles:", error);
            throw error;
        }
    },

    // Tạo mới role
    async createRole(roleData) {
        try {
            const response = await apiService.post("/roles", roleData);
            return response.result || response;
        } catch (error) {
            console.error("Lỗi khi tạo role:", error);
            throw error;
        }
    },

    // Cập nhật role
    async updateRole(roleId, roleData) {
        try {
            const response = await apiService.put(`/roles/${roleId}`, roleData);
            return response.result || response;
        } catch (error) {
            console.error(`Lỗi khi cập nhật role ${roleId}:`, error);
            throw error;
        }
    },

    // Xóa role
    async deleteRole(roleId) {
        try {
            const response = await apiService.delete(`/roles/${roleId}`);
            return response;
        } catch (error) {
            console.error(`Lỗi khi xóa role ${roleId}:`, error);
            throw error;
        }
    },
};

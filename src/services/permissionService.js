import apiService from "./api";

export const permissionService = {
    // Lấy danh sách tất cả permissions
    async getAllPermissions() {
        try {
            const response = await apiService.get("/permissions");
            return response.result || response;
        } catch (error) {
            console.error("Lỗi khi lấy danh sách permissions:", error);
            throw error;
        }
    },

    // Tạo mới permission
    async createPermission(permissionData) {
        try {
            const response = await apiService.post("/permissions", permissionData);
            return response.result || response;
        } catch (error) {
            console.error("Lỗi khi tạo permission:", error);
            throw error;
        }
    },

    // Cập nhật permission
    async updatePermission(permissionId, permissionData) {
        try {
            const response = await apiService.put(`/permissions/${permissionId}`, permissionData);
            return response.result || response;
        } catch (error) {
            console.error(`Lỗi khi cập nhật permission ${permissionId}:`, error);
            throw error;
        }
    },

    // Xóa permission
    async deletePermission(permissionId) {
        try {
            const response = await apiService.delete(`/permissions/${permissionId}`);
            return response;
        } catch (error) {
            console.error(`Lỗi khi xóa permission ${permissionId}:`, error);
            throw error;
        }
    },
};

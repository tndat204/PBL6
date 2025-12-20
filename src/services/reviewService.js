import apiService from "./api";

export const reviewService = {
    // Lấy danh sách reviews của công ty
    async getCompanyReviews(companyId, page = 0, size = 10) {
        try {
            const response = await apiService.get(`/reviews/company/${companyId}`, {
                params: {
                    page,
                    size,
                    sort: "createdAt,desc"
                }
            });
            return response.result || response;
        } catch (error) {
            console.error(`Lỗi khi lấy reviews của company ${companyId}:`, error);
            throw error;
        }
    },

    // Lấy danh sách báo cáo
    async getReports(page = 0, size = 10, status = '') {
        try {
            const params = {
                page,
                size,
                sort: "createdAt,desc"
            };
            if (status) {
                params.status = status;
            }
            const response = await apiService.get("/reviews/reports", { params });
            return response.result || response;
        } catch (error) {
            console.error("Lỗi khi lấy danh sách báo cáo:", error);
            throw error;
        }
    }
};

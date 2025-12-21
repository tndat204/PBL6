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
    },

    // Tạo đánh giá mới
    async createReview(reviewData) {
        const formData = new FormData();
        formData.append('companyId', reviewData.companyId);
        formData.append('title', reviewData.title);
        formData.append('comment', reviewData.comment);
        formData.append('rating', reviewData.rating);

        if (reviewData.images && reviewData.images.length > 0) {
            reviewData.images.forEach((image) => {
                formData.append('images', image);
            });
        }

        try {
            const response = await apiService.post("/reviews", formData);
            return response.result || response;
        } catch (error) {
            console.error("Lỗi khi tạo review:", error);
            throw error;
        }
    },

    // Toggle like review
    async toggleLikeReview(reviewId) {
        try {
            const response = await apiService.post(`/reviews/${reviewId}/toggle-like`);
            return response.result || response;
        } catch (error) {
            console.error(`Lỗi khi toggle like review ${reviewId}:`, error);
            throw error;
        }
    }
};

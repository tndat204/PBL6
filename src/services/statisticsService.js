import apiService from './api';

const statisticsService = {
    // Lấy tổng quan thống kê
    getSummary: async () => {
        return await apiService.get('/statistics/summary');
    },

    // Lấy top skills
    getTopSkills: async () => {
        return await apiService.get('/statistics/top-skills');
    },

    // Lấy thống kê lương theo kinh nghiệm
    getSalaryStats: async () => {
        return await apiService.get('/statistics/salary');
    },

    // Lấy thống kê tăng trưởng
    getGrowthStats: async () => {
        return await apiService.get('/statistics/growth');
    },

    // Lấy thống kê theo kinh nghiệm
    getExperienceStats: async () => {
        return await apiService.get('/statistics/experience');
    },

    // Lấy thống kê theo địa điểm
    getLocationStats: async () => {
        return await apiService.get('/statistics/locations');
    },
};

export default statisticsService;

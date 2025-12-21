import axios from 'axios';

const API_URL = 'http://jobhuntai.c5etagb0eja7f7hf.southeastasia.azurecontainer.io:8000';

export const cvService = {
    reviewCV: async (file) => {
        const formData = new FormData();
        formData.append('cv_file', file);

        try {
            const response = await axios.post(`${API_URL}/review-cv`, formData, {
                headers: {
                    'Content-Type': 'multipart/form-data',
                    'X-API-Key': import.meta.env.VITE_CV_MATCHING_API_KEY || ''
                },
            });
            return response.data;
        } catch (error) {
            console.error('Error reviewing CV:', error);
            throw error;
        }
    }
};

const AI_API_URL = 'http://jobhuntai.c5etagb0eja7f7hf.southeastasia.azurecontainer.io:8000';

class AIService {
  /**
   * Parse job description from PDF file using AI
   * @param {File} pdfFile - PDF file to parse
   * @returns {Promise<Object>} Parsed job description data
   */
  async parseJobDescription(pdfFile) {
    try {
      const API_KEY = import.meta.env.VITE_AI_API_KEY;
      
      if (!API_KEY) {
        throw new Error('AI API key not configured. Please add VITE_AI_API_KEY to .env file');
      }

      const formData = new FormData();
      formData.append('jd_file', pdfFile);

      const response = await fetch(`${AI_API_URL}/summarize-jd`, {
        method: 'POST',
        headers: {
          'X-API-Key': API_KEY,
          // No Content-Type header - browser sets it automatically for FormData
        },
        body: formData,
      });

      if (!response.ok) {
        const errorData = await response.json().catch(() => ({}));
        throw new Error(errorData.message || `AI API error: ${response.status}`);
      }

      const result = await response.json();
      return result;
    } catch (error) {
      console.error('AI Service Error:', error);
      throw error;
    }
  }
}

export default new AIService();

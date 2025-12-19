const BASE_URL = "https://gateway-service.jollybeach-1fb67642.southeastasia.azurecontainerapps.io/api";

class ApiService {
  constructor() {
    this.baseURL = BASE_URL;
  }

  // Helper method để lấy token
  getToken() {
    return localStorage.getItem("token");
  }

  // Helper method để tạo headers
  getHeaders(includeAuth = true, isFormData = false) {
    const headers = {};

    // Don't set Content-Type for FormData, browser will set it with boundary
    if (!isFormData) {
      headers["Content-Type"] = "application/json";
    }

    if (includeAuth) {
      const token = this.getToken();
      if (token) {
        headers.Authorization = `Bearer ${token}`;
      }
    }

    return headers;
  }

  // Generic method để gọi API
  async request(endpoint, options = {}) {

    const url = `${this.baseURL}${endpoint}`;
    const config = {
      headers: this.getHeaders(options.auth !== false, options.isFormData),
      ...options,
    };

    try {
      const response = await fetch(url, config);

      if (!response.ok) {
        // Try to get error message from response body
        let errorMessage = `HTTP error! status: ${response.status}`;
        try {
          const errorData = await response.json();
          console.log('Error response data:', errorData);
          if (errorData.message) {
            errorMessage = errorData.message;
          } else if (errorData.error) {
            errorMessage = errorData.error;
          } else if (typeof errorData === 'string') {
            errorMessage = errorData;
          }
        } catch (e) {
          // If response is not JSON, use default error message
          console.log('Could not parse error response as JSON');
        }
        const error = new Error(errorMessage);
        error.status = response.status;
        throw error;
      }

      return await response.json();
    } catch (error) {
      console.error(`API Error (${endpoint}):`, error);
      throw error;
    }
  }

  // GET request
  async get(endpoint, options = {}) {
    return this.request(endpoint, { method: "GET", ...options });
  }

  // POST request
  async post(endpoint, data, options = {}) {
    const isFormData = data instanceof FormData;

    return this.request(endpoint, {
      method: "POST",
      body: isFormData ? data : JSON.stringify(data),
      isFormData,
      ...options,
    });
  }

  // PUT request
  async put(endpoint, data, options = {}) {
    const isFormData = data instanceof FormData;

    return this.request(endpoint, {
      method: "PUT",
      body: isFormData ? data : JSON.stringify(data),
      isFormData,
      ...options,
    });
  }

  // DELETE request
  async delete(endpoint, options = {}) {
    return this.request(endpoint, { method: "DELETE", ...options });
  }
}

export default new ApiService();
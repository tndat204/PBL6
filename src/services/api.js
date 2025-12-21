
const BASE_URL = "https://gateway-service.jollybeach-1fb67642.southeastasia.azurecontainerapps.io/api";
// const BASE_URL = "http://localhost:8080/api";


class ApiService {
  constructor() {
    this.baseURL = BASE_URL;
  }

  getToken() {
    return localStorage.getItem("token");
  }


  // Sửa: Thêm tham số isFormData
  getHeaders(includeAuth = true, isFormData = false) {
    const headers = {};

    // Chỉ thêm Content-Type là JSON nếu KHÔNG phải là FormData
    // Nếu là FormData, để trình duyệt tự xử lý (để nó thêm boundary)

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

  async request(endpoint, options = {}) {
    const url = `${this.baseURL}${endpoint}`;

    // Lấy flag isFormData từ options truyền vào
    const { isFormData, ...fetchOptions } = options;

    const config = {

      // Truyền flag xuống getHeaders
      headers: this.getHeaders(options.auth !== false, isFormData),
      ...fetchOptions,

    };

    try {
      const response = await fetch(url, config);

      if (!response.ok) {

        // Thử đọc lỗi từ server trả về nếu có
        const errorData = await response.json().catch(() => ({}));
        console.error("Server Error Response:", errorData); // Log full error data
        throw new Error(errorData.message || JSON.stringify(errorData) || `HTTP error! status: ${response.status}`);

      }

      return await response.json();
    } catch (error) {
      console.error(`API Error (${endpoint}):`, error);
      throw error;
    }
  }

  async get(endpoint, options = {}) {
    return this.request(endpoint, { method: "GET", ...options });
  }

  // Sửa: Kiểm tra data có phải FormData không
  async post(endpoint, data, options = {}) {
    const isFormData = data instanceof FormData;

    return this.request(endpoint, {
      method: "POST",

      // Nếu là FormData thì giữ nguyên, nếu không thì stringify
      body: isFormData ? data : JSON.stringify(data),
      isFormData, // Đánh dấu để request biết đường xử lý header

      ...options,
    });
  }

  async put(endpoint, data, options = {}) {
    const isFormData = data instanceof FormData;
    return this.request(endpoint, {
      method: "PUT",
      body: isFormData ? data : JSON.stringify(data),
      isFormData,
      ...options,
    });
  }

  async delete(endpoint, options = {}) {
    return this.request(endpoint, { method: "DELETE", ...options });
  }
}

export default new ApiService();
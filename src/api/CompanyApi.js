// src/api/CompanyApi.js
const BASE_URL = "/api/companies"; // URL backend của bạn

// Lấy danh sách công ty
export const getCompanies = async (token) => {
  const res = await fetch(`${BASE_URL}`, {
    method: "GET",
    headers: {
      "Authorization": `Bearer ${token}`,
      "Content-Type": "application/json"
    }
  });
  if (!res.ok) {
    throw new Error(`Lỗi ${res.status}: ${res.statusText}`);
  }
  return res.json(); // trả về dữ liệu JSON
};

// Tạo công ty mới
export const createCompany = async (data, token) => {
  const res = await fetch(BASE_URL, {
    method: "POST",
    headers: {
      "Authorization": `Bearer ${token}`,
      "Content-Type": "application/json"
    },
    body: JSON.stringify(data)
  });
  if (!res.ok) {
    const err = await res.json().catch(() => ({}));
    throw new Error(err.message || "Tạo công ty thất bại");
  }
  return res.json();
};

// Cập nhật công ty
export const updateCompany = async (id, data, token) => {
  const res = await fetch(`${BASE_URL}/${id}`, {
    method: "PUT",
    headers: {
      "Authorization": `Bearer ${token}`,
      "Content-Type": "application/json"
    },
    body: JSON.stringify(data)
  });
  if (!res.ok) {
    const err = await res.json().catch(() => ({}));
    throw new Error(err.message || "Cập nhật công ty thất bại");
  }
  return res.json();
};

// Xóa công ty
export const deleteCompany = async (id, token) => {
  const res = await fetch(`${BASE_URL}/${id}`, {
    method: "DELETE",
    headers: {
      "Authorization": `Bearer ${token}`
    }
  });
  if (!res.ok) {
    const err = await res.json().catch(() => ({}));
    throw new Error(err.message || "Xóa công ty thất bại");
  }
  return res.json();
};

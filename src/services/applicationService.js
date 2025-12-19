import api from "./api";

const applyJob = async (formData) => {
  // Chỉ cần truyền formData vào, api.js mới sửa sẽ tự lo phần còn lại
  return api.post("/applications", formData);
};

export default {
  applyJob,
};
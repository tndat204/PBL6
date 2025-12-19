import { authService } from '../services';

export async function handleLoginSuccess(token) {
  try {
    localStorage.setItem("token", token);
    // lấy ra token từ localStorage

    // Lấy thông tin người dùng
    const userData = await authService.getCurrentUser();
    localStorage.setItem("user", JSON.stringify(userData));

    // Điều hướng về trang chủ
    window.location.href = "/";
  } catch (err) {
    console.error("Lỗi khi xử lý đăng nhập:", err);
    alert("Đăng nhập thất bại, vui lòng thử lại!");
  }
}

//Thêm function đăng xuất
export async function handleLogout() {
  try {
    // xóa token và user khỏi LocalStorage
    const token = localStorage.getItem("token");
    await fetch("https://gateway-service.jollybeach-1fb67642.southeastasia.azurecontainerapps.io/api/auth/logout", {
      method: "POST",
      headers: {
        Authorization: `Bearer ${token}`,
        "Content-Type": "application/json"
      },
    });
    localStorage.removeItem("token");
    localStorage.removeItem("user");
    //Chuyển hướng về trang chủ
    window.location.href = "/";
  }
  catch (err) {
    console.error("Lỗi khi đăng xuất: ", err);
    alert("Đăng xuất thất bại, vui lòng thử lại!");
  }
}
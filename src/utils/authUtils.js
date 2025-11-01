export async function handleLoginSuccess(token) {
  try {
    localStorage.setItem("token", token);

    // Lấy thông tin người dùng
    const res = await fetch("http://localhost:8080/api/user/my-info", {
      headers: {
        Authorization: `Bearer ${token}`,
        "Content-Type": "application/json",
      },
    });

    if (!res.ok) {
      throw new Error("Không thể lấy thông tin người dùng");
    }

    const data = await res.json();
    localStorage.setItem("user", JSON.stringify(data.result || data));
    // Điều hướng về trang chủ
    window.location.href = "/";
  } catch (err) {
    console.error("Lỗi khi xử lý đăng nhập:", err);
    alert("Đăng nhập thất bại, vui lòng thử lại!");
  }
}

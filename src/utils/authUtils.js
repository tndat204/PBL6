export async function handleLoginSuccess(token) {
  try {
    localStorage.setItem("token", token); 
    // lấy ra token từ localStorage

    // Lấy thông tin người dùng
    const res = await fetch("http://localhost:8080/api/users/me", {
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

//Thêm function đăng xuất
export async function handleLogout(){
  try{
    // xóa token và user khỏi LocalStorage
    const token = localStorage.getItem("token");
    await fetch("http://localhost:8080/api/auth/logout", {
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
  catch(err){
    console.error("Lỗi khi đăng xuất: ", err);
    alert("Đăng xuất thất bại, vui lòng thử lại!");
  }
}
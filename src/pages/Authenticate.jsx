import { useEffect } from "react";
import { useNavigate } from "react-router-dom";
import { useAuth } from "../hooks/useAuth";
import Login from './Login';
export default function Authenticate() {
  const { login } = useAuth();  
  const navigate = useNavigate();

  useEffect(() => {
    const params = new URLSearchParams(window.location.search);
    const code = params.get("code");

    const sleep = (ms) => new Promise((resolve) => setTimeout(resolve, ms));

    const authenticate = async () => {
      if (!code) {
        navigate("/login");
        return;
      }

      try {
        const res = await fetch(`http://localhost:8080/api/auth/google-web?code=${code}`, {
          method: "POST",
        });

        if (!res.ok) throw new Error("Đăng nhập Google thất bại");

        const data = await res.json();
        console.log("Phản hồi backend:", data);

        if (data.result?.token) {
          await login(data.result.token);
          await sleep(400); 
          navigate("/"); // về trang chính
        } else {
          navigate("/login");
        }
      } catch (err) {
        console.error(err);
        navigate("/login");
      }
    };

    authenticate();
  }, [navigate, login]);

  return <p>Đang xác thực Google...</p>;
}

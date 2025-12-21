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
        console.log("❌ No code parameter found in URL");
        navigate("/login");
        return;
      }

      console.log("✅ Google code received:", code);

      try {
        const apiUrl = `https://gateway-service.jollybeach-1fb67642.southeastasia.azurecontainerapps.io/api/auth/google-web?code=${code}`;
        console.log("📡 Calling backend API:", apiUrl);

        const res = await fetch(apiUrl, {
          method: "POST",
        });

        console.log("📊 Response status:", res.status);
        console.log("📊 Response ok:", res.ok);

        // Read response body
        const responseText = await res.text();
        console.log("📄 Response body:", responseText);

        if (!res.ok) {
          console.error("❌ Backend returned error status:", res.status);
          console.error("❌ Error details:", responseText);
          throw new Error("Đăng nhập Google thất bại");
        }

        const data = JSON.parse(responseText);
        console.log("✅ Phản hồi backend:", data);

        if (data.result?.token) {
          console.log("✅ Token received, logging in...");
          await login(data.result.token);
          await sleep(400);
          navigate("/"); // về trang chính
        } else {
          console.error("❌ No token in response");
          navigate("/login");
        }
      } catch (err) {
        console.error("❌ Authentication error:", err);
        navigate("/login");
      }
    };

    authenticate();
  }, [navigate, login]);

  return <p>Đang xác thực Google...</p>;
}

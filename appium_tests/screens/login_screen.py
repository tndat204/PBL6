# file: screens/login_screen.py
from appium.webdriver.common.appiumby import AppiumBy
from selenium.webdriver.support import expected_conditions as EC
from selenium.common.exceptions import TimeoutException
from .base_screen import BaseScreen
import time

class LoginScreen(BaseScreen):
    # nếu bạn sẽ dùng ACCESSIBILITY_ID cho semantics(label)
    EMAIL_FIELD = (AppiumBy.XPATH, '//android.view.View[@content-desc="emailField"]//android.widget.EditText')
    PASSWORD_FIELD = (AppiumBy.XPATH, '//android.view.View[@content-desc="passwordField"]//android.widget.EditText')
    LOGIN_BUTTON = (AppiumBy.ACCESSIBILITY_ID, "LoginButton")
    EMAIL_ERROR = (AppiumBy.ACCESSIBILITY_ID, "Vui lòng nhập email")
    PASSWORD_ERROR = (AppiumBy.ACCESSIBILITY_ID, "Vui lòng nhập mật khẩu")
    INVALID_EMAIL_ERROR = (AppiumBy.ACCESSIBILITY_ID, "Email không đúng định dạng")
    INVALID_PASSWORD_ERROR = (AppiumBy.ACCESSIBILITY_ID, "Mật khẩu phải có ít nhất 8 ký tự")
    
    # ✅ Locators cho lỗi server (hiển thị bằng Text widget)
    WRONG_PASSWORD_ERROR = (AppiumBy.ACCESSIBILITY_ID, "Sai mật khẩu")
    LOGIN_FAILED_ERROR = (AppiumBy.ACCESSIBILITY_ID, "Đăng nhập thất bại, vui lòng thử lại")

    # Locator cho toast thành công
    SUCCESS_TOAST = (AppiumBy.ACCESSIBILITY_ID, "Đăng nhập thành công")

    def login(self, email, password, wait_after_click=2):
        """
        Nhập, click login. Sau khi click chờ một chút để app điều hướng / hiển thị toast.
        Ghi log trạng thái.
        """
        print(f"[ACTION] Đăng nhập với email='{email}' password='{'*' * len(password)}'")
        try:
            # Click để focus và nhập email
            self.click(self.EMAIL_FIELD[0], self.EMAIL_FIELD[1])
            time.sleep(0.2) 
            self.input_text(self.EMAIL_FIELD[0], self.EMAIL_FIELD[1], email)
        except Exception as e:
            print(f"[WARN] Không nhập được email field: {e}")
        try:
            # Click để focus và nhập password
            self.click(self.PASSWORD_FIELD[0], self.PASSWORD_FIELD[1])
            time.sleep(0.2) 
            self.input_text(self.PASSWORD_FIELD[0], self.PASSWORD_FIELD[1], password)
        except Exception as e:
            print(f"[WARN] Không nhập được password field: {e}")
            
        print("[ACTION] Click nút 'Đăng nhập'")
        try:
            self.click(self.LOGIN_BUTTON[0], self.LOGIN_BUTTON[1])
        except Exception as e:
            print(f"[ERROR] Click login failed: {e}")
            
        # Chờ app xử lý
        time.sleep(wait_after_click)
        

    def is_error_displayed(self):
        # ✅ Cập nhật danh sách các lỗi cần tìm
        for locator in [
            # Lỗi validation
            self.EMAIL_ERROR, self.PASSWORD_ERROR,
            self.INVALID_EMAIL_ERROR, self.INVALID_PASSWORD_ERROR,
            # Lỗi server
            self.WRONG_PASSWORD_ERROR, self.LOGIN_FAILED_ERROR
        ]:
            try:
                if self.is_element_displayed(locator[0], locator[1], timeout=2):
                    print(f"[INFO] Tìm thấy lỗi: {locator[1]}")
                    return True
            except Exception:
                pass
        print("[INFO] Không tìm thấy lỗi (validation/server).")
        return False

    def is_login_successful(self, timeout=5):
        try:
            # Chỉ tìm toast thành công
            if self.is_element_displayed(self.SUCCESS_TOAST[0], self.SUCCESS_TOAST[1], timeout):
                print("[INFO] Tìm thấy toast 'Đăng nhập thành công'.")
                return True
        except Exception:
            pass
        print("[INFO] Không tìm thấy toast 'Đăng nhập thành công'.")
        return False
    def is_login_button_displayed(self, timeout=10):
        """
        Kiểm tra xem nút 'Đăng nhập' (LOGIN_BUTTON) có hiển thị không.
        Dùng để xác minh đã chuyển về màn hình Login thành công từ Signup.
        """
        print(f"[INFO] Đang chờ tìm LOGIN_BUTTON (ID: {self.LOGIN_BUTTON[1]}) trong {timeout} giây...")
        try:
        # Dùng lại helper is_element_displayed từ BaseScreen (giống is_login_successful)
            if self.is_element_displayed(self.LOGIN_BUTTON[0], self.LOGIN_BUTTON[1], timeout):
                print("[INFO] Đã tìm thấy LOGIN_BUTTON.")
                return True
        except Exception:
        # Bắt Exception (có thể là TimeoutException từ helper)
            pass
        
        print(f"[INFO] Không tìm thấy LOGIN_BUTTON sau {timeout} giây.")
        return False

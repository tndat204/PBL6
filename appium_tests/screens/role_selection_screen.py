from appium.webdriver.common.appiumby import AppiumBy
from selenium.webdriver.support import expected_conditions as EC
from .base_screen import BaseScreen
import time

class RoleSelectionScreen(BaseScreen):
    """
    Screen Object cho màn hình chọn vai trò (RoleSelectionScreen)
    """
    RECRUITER_BUTTON = (AppiumBy.ACCESSIBILITY_ID, "recruiterButton")
    USER_BUTTON = (AppiumBy.ACCESSIBILITY_ID, "userButton")

    def select_recruiter(self):
        """
        Nhấn nút 'Tôi là nhà tuyển dụng'
        """
        print("[ACTION] Chọn vai trò 'Nhà tuyển dụng'...")
        try:
            button = self.wait.until(EC.element_to_be_clickable(self.RECRUITER_BUTTON))
            button.click()
            time.sleep(1) # Chờ chuyển màn hình
            print("[INFO] Đã nhấn nút 'Nhà tuyển dụng'.")
        except Exception as e:
            print(f"[ERROR] Không thể nhấn nút 'Nhà tuyển dụng': {e}")
            raise

    def select_user(self):
        """
        Nhấn nút 'Tôi là ứng viên'
        """
        print("[ACTION] Chọn vai trò 'Ứng viên'...")
        try:
            button = self.wait.until(EC.element_to_be_clickable(self.USER_BUTTON))
            button.click()
            time.sleep(1) # Chờ chuyển màn hình
            print("[INFO] Đã nhấn nút 'Ứng viên'.")
        except Exception as e:
            print(f"[ERROR] Không thể nhấn nút 'Ứng viên': {e}")
            raise

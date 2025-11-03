# file: screens/welcome_screen.py
from appium.webdriver.common.appiumby import AppiumBy
from selenium.webdriver.support import expected_conditions as EC
from .base_screen import BaseScreen

class WelcomeScreen(BaseScreen):
    GO_TO_LOGIN_BUTTON = (AppiumBy.ACCESSIBILITY_ID, "LoginButton")
    GO_TO_REGISTER_BUTTON = (AppiumBy.ACCESSIBILITY_ID, "RegisterButton")
    def go_to_login_page(self):
        print("[INFO] Chờ nút 'Đăng nhập' trên màn hình chào...")
        button = self.wait.until(EC.element_to_be_clickable(self.GO_TO_LOGIN_BUTTON))
        button.click()
        print("[INFO] Đã nhấn nút Đăng nhập.")
    def go_to_role_selection(self):
        print("[INFO] Chờ nút 'Đăng ký' trên màn hình chào...")
        button = self.wait.until(EC.element_to_be_clickable(self.GO_TO_REGISTER_BUTTON))
        button.click()
        print("[INFO] Đã nhấn nút Đăng ký.")
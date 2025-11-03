import pytest
from ..screens.login_screen import LoginScreen
from ..screens.home_screen import HomeScreen
from ..screens.welcome_screen import WelcomeScreen
import time
import os

@pytest.mark.usefixtures("appium_driver")
class TestLogin:
    def setup_method(self, method):
        print(f"\n=== Bắt đầu test case: {method.__name__} ===")

    def _debug_dump(self, driver, name_prefix):
        ts = int(time.time())
        
        # ✅ Đảm bảo thư mục screenshots tồn tại
        if not os.path.exists("screenshots"):
            os.makedirs("screenshots")
            
        screenshot = os.path.join("screenshots", f"{name_prefix}_{ts}.png")
        pagesrc = os.path.join("screenshots", f"{name_prefix}_page_source_{ts}.xml")
        
        try:
            driver.get_screenshot_as_file(screenshot)
            print(f"[DEBUG] Saved screenshot: {screenshot}")
        except Exception as e:
            print(f"[DEBUG] Could not save screenshot: {e}")
        try:
            with open(pagesrc, "w", encoding="utf-8") as f:
                f.write(driver.page_source)
            print(f"[DEBUG] Saved page source: {pagesrc}")
        except Exception as e:
            print(f"[DEBUG] Could not save page source: {e}")

    def test_login_success(self, appium_driver):
        """✅ Test: Đăng nhập thành công (ứng viên)"""
        welcome = WelcomeScreen(appium_driver)
        welcome.go_to_login_page()

        login = LoginScreen(appium_driver)
        login.login("nguyenquangdung177@gmail.com", "Abc@123456", wait_after_click=3)

        home = HomeScreen(appium_driver)
        ok = home.is_dashboard_displayed(timeout=8)
        if not ok:
            self._debug_dump(appium_driver, "login_success_failed")
        assert ok, "Không chuyển tới dashboard ứng viên!"

    def test_login_wrong_password(self, appium_driver):
        """❌ Test: Đúng email nhưng sai mật khẩu"""
        welcome = WelcomeScreen(appium_driver)
        welcome.go_to_login_page()

        login = LoginScreen(appium_driver)
        login.login("nguyenquangdung177@gmail.com", "saimatkhau", wait_after_click=2)
        
        # ✅ Hàm is_error_displayed() đã được cập nhật để tìm lỗi 'Sai mật khẩu'
        ok = login.is_error_displayed()
        if not ok:
            self._debug_dump(appium_driver, "login_wrong_password_failed")
        assert ok, "Không hiện thông báo lỗi 'Sai mật khẩu'!"

    def test_login_empty_fields(self, appium_driver):
        """❌ Test: Không điền gì"""
        welcome = WelcomeScreen(appium_driver)
        welcome.go_to_login_page()

        login = LoginScreen(appium_driver)
        login.login("", "", wait_after_click=1)
        
        ok = login.is_error_displayed()
        if not ok:
            self._debug_dump(appium_driver, "login_empty_failed")
        assert ok, "Không hiện lỗi khi bỏ trống email & mật khẩu!"

    def test_login_invalid_email(self, appium_driver):
        """❌ Test: Email sai định dạng"""
        welcome = WelcomeScreen(appium_driver)
        welcome.go_to_login_page()

        login = LoginScreen(appium_driver)
        login.login("saiemail", "12345678", wait_after_click=1)
        
        ok = login.is_error_displayed()
        if not ok:
            self._debug_dump(appium_driver, "login_invalid_email_failed")
        assert ok, "Không hiện lỗi định dạng email sai!"

    def test_login_invalid_password(self, appium_driver):
        """❌ Test: Mật khẩu sai định dạng (quá ngắn)"""
        welcome = WelcomeScreen(appium_driver)
        welcome.go_to_login_page()

        login = LoginScreen(appium_driver)
        login.login("nguyenquangdung177@gmail.com", "123", wait_after_click=1)
        
        ok = login.is_error_displayed()
        if not ok:
            self._debug_dump(appium_driver, "login_invalid_password_failed")
        assert ok, "Không hiện lỗi mật khẩu sai định dạng!"

    def test_login_unregistered_user(self, appium_driver):
        """❌ Test: Người dùng chưa đăng ký"""
        welcome = WelcomeScreen(appium_driver)
        welcome.go_to_login_page()

        login = LoginScreen(appium_driver)
        login.login("chua_dangky@example.com", "12345678", wait_after_click=2)
        
        # ✅ Hàm is_error_displayed() đã được cập nhật để tìm lỗi 'Đăng nhập thất bại...'
        ok = login.is_error_displayed()
        if not ok:
            self._debug_dump(appium_driver, "login_unregistered_failed")
        assert ok, "Không hiện thông báo lỗi khi tài khoản chưa đăng ký!"


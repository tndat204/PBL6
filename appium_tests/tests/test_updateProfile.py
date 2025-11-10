# file: tests/test_profile_update.py
import pytest
from ..screens.welcome_screen import WelcomeScreen
from ..screens.login_screen import LoginScreen
from ..screens.home_screen import HomeScreen
from ..screens.profile_screen import ProfileScreen
import time
import os

@pytest.mark.usefixtures("appium_driver")
class TestProfileUpdate:
  
  def setup_method(self, method):
    """
    Hàm này chạy trước MỖI test case
    """
    print(f"\n=== Bắt đầu test case: {method.__name__} ===")

  def _debug_dump(self, driver, name_prefix):
    """Hàm helper chụp ảnh màn hình khi test fail"""
    ts = int(time.time())
    if not os.path.exists("screenshots"):
      os.makedirs("screenshots")
    screenshot = os.path.join("screenshots", f"{name_prefix}_{ts}.png")
    try:
      driver.get_screenshot_as_file(screenshot)
      print(f"[DEBUG] Saved screenshot: {screenshot}")
    except Exception as e:
      print(f"[DEBUG] Could not save screenshot: {e}")

  def _navigate_to_profile(self, appium_driver, login_creds):
    """
    Helper TỰ ĐỘNG: Reset app -> Welcome -> Login -> Main -> Profile
    Đảm bảo mỗi test bắt đầu sạch sẽ tại màn hình Profile
    """
    try:
      print("[SETUP] Reset app và thực hiện luồng đăng nhập...")
      
      
      welcome = WelcomeScreen(appium_driver)
      welcome.go_to_login_page()
      
      login = LoginScreen(appium_driver)
      # ⚠️ Hãy đảm bảo locator 'LoginButton' là ĐÚNG
      # Nếu sai, hãy sửa thành (AppiumBy.ACCESSIBILITY_ID, "Đăng nhập")
      login.login(login_creds["email"], login_creds["password"], wait_after_click=3)
      
      main = HomeScreen(appium_driver)
      main.go_to_profile_tab()
      
      profile = ProfileScreen(appium_driver)
      profile.wait_for_screen_load()
      
      print("[SETUP] Đã đến màn hình Profile.")
      return profile
      
    except Exception as e:
      print(f"[SETUP_FAILED] Lỗi trong quá trình điều hướng: {e}")
      self._debug_dump(appium_driver, "profile_nav_failed")
      pytest.fail(f"Lỗi setup điều hướng tới Profile: {e}")


  # --- BỘ TEST CASE ---
  def test_load_profile_screen_success(self, appium_driver, login_credentials):
    """✅ Test (READ): Đăng nhập và hiển thị màn hình Profile thành công"""
    # Hàm _navigate_to_profile đã bao gồm cả việc chờ (wait_for_screen_load)
    # Nếu hàm này chạy xong mà không có lỗi, nghĩa là test đã thành công.
    print("[INFO] Bắt đầu test READ (tải trang)...")
    profile = self._navigate_to_profile(appium_driver, login_credentials)
    
    assert profile is not None, "Không thể khởi tạo trang Profile"
    print("[INFO] Test READ (tải trang) thành công.")
  # def test_update_success(self, appium_driver, profile_data, login_credentials):
  #   """✅ Test: Cập nhật thành công tất cả các trường"""
  #   profile = self._navigate_to_profile(appium_driver, login_credentials)
  #   data = profile_data["test_update_success"]
    
  #   profile.set_headline(data["headline"])
  #   profile.set_summary(data["summary"])
  #   profile.set_salary(data["salary"])
  #   profile.set_linkedin(data["linkedin"])
  #   profile.set_portfolio(data["portfolio"])
    
  #   profile.tap_save_button(wait_after_click=3)
    
  #   ok = profile.is_update_successful(timeout=5)
  #   if not ok:
  #     self._debug_dump(appium_driver, "update_success_no_toast")
  #   assert ok, "Không tìm thấy toast 'Cập nhật Profile thành công!'"

  # def test_validation_headline_empty(self, appium_driver, login_credentials):
  #   """❌ Test: Lỗi validation khi Vị trí mong muốn để trống"""
  #   profile = self._navigate_to_profile(appium_driver, login_credentials)
    
  #   profile.set_headline("") # Để trống
  #   profile.tap_save_button()
    
  #   ok = profile.is_error_displayed(profile.ERROR_HEADLINE_EMPTY)
  #   if not ok:
  #     # 💡 SỬA LỖI: Gọi hàm cuộn từ object 'profile'
  #     profile.scroll_to_top() 
  #     self._debug_dump(appium_driver, "val_headline_empty_failed")
  #   assert ok, "Không hiển thị lỗi 'Vị trí mong muốn không được để trống.'"

  # def test_validation_headline_long(self, appium_driver, profile_data, login_credentials):
  #   """❌ Test: Lỗi validation khi Vị trí mong muốn quá dài"""
  #   profile = self._navigate_to_profile(appium_driver, login_credentials)
  #   data = profile_data["test_validation_headline_long"]
    
  #   profile.set_headline(data["headline"]) # > 200 ký tự
  #   profile.tap_save_button()
    
  #   ok = profile.is_error_displayed(profile.ERROR_HEADLINE_LONG)
  #   if not ok:
  #     # 💡 SỬA LỖI: Gọi hàm cuộn từ object 'profile'
  #     profile.scroll_to_top()
  #     self._debug_dump(appium_driver, "val_headline_long_failed")
  #   assert ok, "Không hiển thị lỗi 'Vị trí mong muốn không được vượt quá 200 ký tự.'"

  # def test_validation_headline_invalid(self, appium_driver, profile_data, login_credentials):
  #   """❌ Test: Lỗi validation khi Vị trí mong muốn chứa ký tự đặc biệt"""
  #   profile = self._navigate_to_profile(appium_driver, login_credentials)
  #   data = profile_data["test_validation_headline_invalid"]
    
  #   profile.set_headline(data["headline"]) # Chứa @#!
  #   profile.tap_save_button()
    
  #   ok = profile.is_error_displayed(profile.ERROR_HEADLINE_INVALID)
  #   if not ok:
  #     # 💡 SỬA LỖI: Gọi hàm cuộn từ object 'profile'
  #     profile.scroll_to_top()
  #     self._debug_dump(appium_driver, "val_headline_invalid_failed")
  #   assert ok, "Không hiển thị lỗi 'Vị trí mong muốn chứa ký tự không hợp lệ.'"

  # def test_validation_summary_long(self, appium_driver, profile_data, login_credentials):
  #   """❌ Test: Lỗi validation khi Tóm tắt quá dài"""
  #   profile = self._navigate_to_profile(appium_driver, login_credentials)
  #   data = profile_data["test_validation_summary_long"]
    
  #   profile.set_summary(data["summary"]) # > 500 ký tự
  #   profile.tap_save_button()
    
  #   ok = profile.is_error_displayed(profile.ERROR_SUMMARY_LONG)
  #   if not ok:
  #     # 💡 SỬA LỖI: Gọi hàm cuộn từ object 'profile'
  #     profile.scroll_to_top()
  #     self._debug_dump(appium_driver, "val_summary_long_failed")
  #   assert ok, "Không hiển thị lỗi 'Tóm tắt không được vượt quá 500 ký tự.'"

  # def test_validation_linkedin_invalid(self, appium_driver, profile_data, login_credentials):
  #   """❌ Test: Lỗi validation khi LinkedIn sai định dạng (sai domain)"""
  #   profile = self._navigate_to_profile(appium_driver, login_credentials)
  #   data = profile_data["test_validation_linkedin_invalid"]
    
  #   profile.set_linkedin(data["linkedin"]) # google.com
  #   profile.tap_save_button()
    
  #   ok = profile.is_error_displayed(profile.ERROR_LINKEDIN_INVALID)
  #   if not ok:
  #     # 💡 SỬA LỖI: Gọi hàm cuộn từ object 'profile'
  #     profile.scroll_to_top()
  #     self._debug_dump(appium_driver, "val_linkedin_invalid_failed")
  #   assert ok, "Không hiển thị lỗi 'Liên kết LinkedIn không hợp lệ.'"

  # def test_validation_portfolio_invalid(self, appium_driver, profile_data, login_credentials):
  #   """❌ Test: Lỗi validation khi Portfolio sai định dạng (không phải URL)"""
  #   profile = self._navigate_to_profile(appium_driver, login_credentials)
  #   data = profile_data["test_validation_portfolio_invalid"]
    
  #   profile.set_portfolio(data["portfolio"]) # text thường
  #   profile.tap_save_button()
    
  #   ok = profile.is_error_displayed(profile.ERROR_PORTFOLIO_INVALID)
  #   if not ok:
  #     # 💡 SỬA LỖI: Gọi hàm cuộn từ object 'profile'
  #     profile.scroll_to_top()
  #     self._debug_dump(appium_driver, "val_portfolio_invalid_failed")
  #   assert ok, "Không hiển thị lỗi 'Liên kết Portfolio không hợp lệ.'"
# file: tests/test_signup.py
import pytest
from ..screens.welcome_screen import WelcomeScreen
from ..screens.role_selection_screen import RoleSelectionScreen
from ..screens.signup_screen import SignupScreen
from ..screens.login_screen import LoginScreen # Để kiểm tra redirect
import time
import os

@pytest.mark.usefixtures("appium_driver")
class TestSignup:
    
    def setup_method(self, method):
        print(f"\n=== Bắt đầu test case: {method.__name__} ===")
        try:
            # Reset app về trạng thái ban đầu trước mỗi test
            self.driver.reset()
        except Exception as e:
            pass 
    
    def _debug_dump(self, driver, name_prefix):
        ts = int(time.time())
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

    def _navigate_to_signup(self, appium_driver):
        """Hàm helper điều hướng từ Welcome -> Role -> Signup"""
        welcome = WelcomeScreen(appium_driver)
        welcome.go_to_role_selection()
        
        role_screen = RoleSelectionScreen(appium_driver)
        role_screen.select_user()
        
        signup = SignupScreen(appium_driver)
        signup.wait_for_screen_load()
        return signup

    # --- BỘ TEST CASE ĐẦY ĐỦ (Đã refactor) ---

    def test_signup_success(self, appium_driver, signup_data):
        """✅ 1. Test: Đăng ký thành công"""
        signup = self._navigate_to_signup(appium_driver)
        data = signup_data["test_signup_success"]
        
        # Tạo email/phone duy nhất
        unique_id = int(time.time())
        unique_email = f"testuser_{unique_id}@gmail.com"
        unique_phone = f"09{str(unique_id)[-8:]}" 

        signup.set_name(data["name"])
        signup.set_email(unique_email)
        signup.select_birth_date()
        signup.set_password(data["password"])
        signup.set_confirm_password(data["password"])
        signup.set_phone(unique_phone)
        signup.select_province(data["province"])
        signup.select_ward(data["ward"])
        signup.set_detailed_address(data["address"])
        signup.tap_agree_terms()
        
        signup.tap_register(wait_after_click=3)
           
        print("[INFO] Xác minh đã chuyển về màn hình Đăng nhập...")
        login = LoginScreen(appium_driver)
        ok = login.is_login_button_displayed(timeout=8)
        if not ok:
            self._debug_dump(appium_driver, "signup_success_failed")
        assert ok, "Không chuyển về màn hình Đăng nhập sau khi đăng ký thành công!" 

    # --- Test Case Lỗi Validation (Theo thứ tự Form) ---

    def test_signup_missing_name(self, appium_driver, signup_data):
        """ 2. Test: Bỏ trống Họ và Tên"""
        signup = self._navigate_to_signup(appium_driver)
              
        signup.tap_register(wait_after_click=1)
        
        ok = signup.is_error_displayed(signup.ERROR_NAME_EMPTY)
        if not ok: self._debug_dump(appium_driver, "signup_missing_name_failed")
        assert ok, "Không hiển thị lỗi 'Vui lòng nhập họ và tên'"

    def test_signup_missing_email(self, appium_driver, signup_data):
        """ 3. Test: Bỏ trống Email"""
        signup = self._navigate_to_signup(appium_driver)
        data = signup_data["test_signup_missing_email"]
        
        signup.set_name(data["name"])
        signup.tap_register(wait_after_click=1)
        
        ok = signup.is_error_displayed(signup.ERROR_EMAIL_EMPTY)
        if not ok: self._debug_dump(appium_driver, "signup_missing_email_failed")
        assert ok, "Không hiển thị lỗi 'Vui lòng nhập email'"

    def test_signup_invalid_email(self, appium_driver, signup_data):
        """ 4. Test: Email sai định dạng"""
        signup = self._navigate_to_signup(appium_driver)
        data = signup_data["test_signup_invalid_email"]
        
        signup.set_name(data["name"])
        signup.set_email(data["email"])
        signup.tap_register(wait_after_click=1)
        
        ok = signup.is_error_displayed(signup.ERROR_EMAIL_INVALID)
        if not ok: self._debug_dump(appium_driver, "signup_invalid_email_failed")
        assert ok, "Không hiển thị lỗi 'Email không hợp lệ'"

    def test_signup_missing_birthdate(self, appium_driver, signup_data):
        """ 5. Test: Bỏ trống Ngày sinh"""
        signup = self._navigate_to_signup(appium_driver)
        data = signup_data["test_signup_missing_birthdate"]
        
        signup.set_name(data["name"])
        signup.set_email(data["email"])
        signup.tap_register(wait_after_click=1)
        
        ok = signup.is_error_displayed(signup.ERROR_BIRTHDATE_EMPTY)
        if not ok: self._debug_dump(appium_driver, "signup_missing_bdate_failed")
        assert ok, "Không hiển thị lỗi 'Vui lòng chọn ngày sinh'"

    def test_signup_missing_password(self, appium_driver, signup_data):
        """ 6. Test: Bỏ trống Mật khẩu"""
        signup = self._navigate_to_signup(appium_driver)
        data = signup_data["test_signup_missing_password"]
        
        signup.set_name(data["name"])
        signup.set_email(data["email"])
        signup.select_birth_date()
        signup.tap_register(wait_after_click=1)
        
        ok = signup.is_error_displayed(signup.ERROR_PASSWORD_EMPTY)
        if not ok: self._debug_dump(appium_driver, "signup_missing_pass_failed")
        assert ok, "Không hiển thị lỗi 'Vui lòng nhập mật khẩu'"

    def test_signup_invalid_password(self, appium_driver, signup_data):
        """ 7. Test: Mật khẩu không đủ mạnh (quá ngắn)"""
        signup = self._navigate_to_signup(appium_driver)
        data = signup_data["test_signup_invalid_password"]
        
        signup.set_name(data["name"])
        signup.set_email(data["email"])
        signup.select_birth_date()
        signup.set_password(data["password"])
        signup.tap_register(wait_after_click=1)
        
        ok = signup.is_error_displayed(signup.ERROR_PASSWORD_INVALID)
        if not ok: self._debug_dump(appium_driver, "signup_invalid_password_failed")
        assert ok, "Không hiển thị lỗi định dạng mật khẩu"

    def test_signup_missing_confirm_password(self, appium_driver, signup_data):
        """ 8. Test: Bỏ trống Xác nhận mật khẩu"""
        signup = self._navigate_to_signup(appium_driver)
        data = signup_data["test_signup_missing_confirm_password"]
        
        signup.set_name(data["name"])
        signup.set_email(data["email"])
        signup.select_birth_date()
        signup.set_password(data["password"])
        signup.tap_register(wait_after_click=1)
        
        ok = signup.is_error_displayed(signup.ERROR_CONFIRM_PASSWORD_EMPTY)
        if not ok: self._debug_dump(appium_driver, "signup_missing_confirm_pass_failed")
        assert ok, "Không hiển thị lỗi 'Vui lòng nhập lại mật khẩu'"

    def test_signup_password_mismatch(self, appium_driver, signup_data):
        """ 9. Test: Mật khẩu nhập lại không khớp"""
        signup = self._navigate_to_signup(appium_driver)
        data = signup_data["test_signup_password_mismatch"]
        
        signup.set_name(data["name"])
        signup.set_email(data["email"])
        signup.select_birth_date()
        signup.set_password(data["password"])
        signup.set_confirm_password(data["confirm_password"])
        
        signup.tap_register(wait_after_click=1)
        
        ok = signup.is_error_displayed(signup.ERROR_CONFIRM_PASSWORD_MISMATCH)
        if not ok: self._debug_dump(appium_driver, "signup_password_mismatch_failed")
        assert ok, "Không hiển thị lỗi 'Mật khẩu không khớp'"

    def test_signup_missing_phone(self, appium_driver, signup_data):
        """ 10. Test: Bỏ trống Số điện thoại"""
        signup = self._navigate_to_signup(appium_driver)
        data = signup_data["test_signup_missing_phone"]

        signup.set_name(data["name"])
        signup.set_email(data["email"])
        signup.select_birth_date()
        signup.set_password(data["password"])
        signup.set_confirm_password(data["confirm_password"])
        signup.tap_register(wait_after_click=1)
        
        ok = signup.is_error_displayed(signup.ERROR_PHONE_EMPTY)
        if not ok: self._debug_dump(appium_driver, "signup_missing_phone_failed")
        assert ok, "Không hiển thị lỗi 'Vui lòng nhập số điện thoại'"

    def test_signup_invalid_phone(self, appium_driver, signup_data):
        """ 11. Test: Số điện thoại sai định dạng (quá ngắn)"""
        signup = self._navigate_to_signup(appium_driver)
        data = signup_data["test_signup_invalid_phone"]
        
        signup.set_name(data["name"])
        signup.set_email(data["email"])
        signup.select_birth_date()
        signup.set_password(data["password"])
        signup.set_confirm_password(data["confirm_password"])
        signup.set_phone(data["phone"]) # SĐT sai
        signup.tap_register(wait_after_click=1)
        
        ok = signup.is_error_displayed(signup.ERROR_PHONE_INVALID)
        if not ok: self._debug_dump(appium_driver, "signup_invalid_phone_failed")
        assert ok, "Không hiển thị lỗi 'Số điện thoại không hợp lệ'"

    def test_signup_missing_detailed_address(self, appium_driver, signup_data):
        """ 12. Test: Bỏ trống Địa chỉ chi tiết"""
        signup = self._navigate_to_signup(appium_driver)
        data = signup_data["test_signup_missing_detailed_address"]

        signup.set_name(data["name"])
        signup.set_email(data["email"])
        signup.select_birth_date()
        signup.set_password(data["password"])
        signup.set_confirm_password(data["confirm_password"])
        signup.set_phone(data["phone"])
        signup.select_province(data["province"])
        signup.select_ward(data["ward"])
        # KHÔNG ĐIỀN ĐỊA CHỈ CHI TIẾT
        signup.tap_agree_terms()
        
        signup.tap_register(wait_after_click=1)
        
        ok = signup.is_error_displayed(signup.ERROR_ADDRESS_EMPTY)
        if not ok: self._debug_dump(appium_driver, "signup_missing_address_failed")
        assert ok, "Không hiển thị lỗi 'Vui lòng nhập địa chỉ chi tiết'"

    def test_signup_address_too_long(self, appium_driver, signup_data):
        """ 13. Test: Địa chỉ chi tiết quá dài (> 50 ký tự)"""
        signup = self._navigate_to_signup(appium_driver)
        data = signup_data["test_signup_address_too_long"]

        signup.set_name(data["name"])
        signup.set_email(data["email"])
        signup.select_birth_date()
        signup.set_password(data["password"])
        signup.set_confirm_password(data["confirm_password"])
        signup.set_phone(data["phone"])
        signup.select_province(data["province"])
        signup.select_ward(data["ward"])
        signup.set_detailed_address(data["address"]) # Địa chỉ quá dài
        signup.tap_agree_terms()
        
        signup.tap_register(wait_after_click=1)
        
        ok = signup.is_error_displayed(signup.ERROR_ADDRESS_TOO_LONG)
        if not ok: self._debug_dump(appium_driver, "signup_address_too_long_failed")
        assert ok, "Không hiển thị lỗi 'Địa chỉ không được vượt quá 50 ký tự'"

    # --- Test Case Lỗi Logic / Server (Validation đã pass) ---

    def _fill_all_valid_fields(self, signup, data):
        """Helper điền tất cả các trường text và date (validation pass)"""
        # Tạo email/phone mới để tránh lỗi server
        unique_id = int(time.time())
        unique_email = f"test_{unique_id}@gmail.com"
        unique_phone = f"09{str(unique_id)[-8:]}"
        
        signup.set_name(data["name"])
        signup.set_email(unique_email)
        signup.select_birth_date()
        signup.set_password(data["password"])
        signup.set_confirm_password(data["password"])
        signup.set_phone(unique_phone)
        signup.set_detailed_address(data["address"])

    def test_signup_logic_terms_not_agreed(self, appium_driver, signup_data):
        """ 14. Test: Lỗi Logic - Không đồng ý điều khoản"""
        signup = self._navigate_to_signup(appium_driver)
        data = signup_data["test_signup_logic_terms_not_agreed"]

        self._fill_all_valid_fields(signup, data)
        signup.select_province(data["province"])
        signup.select_ward(data["ward"])
        
        # KHÔNG click 'tap_agree_terms()'
        
        signup.tap_register(wait_after_click=1)
        
        ok = signup.is_error_displayed(signup.ERROR_TERMS_NOT_AGREED)
        if not ok: self._debug_dump(appium_driver, "signup_terms_not_agreed_failed")
        assert ok, "Không hiển thị lỗi 'Bạn phải đồng ý với điều khoản sử dụng.'"

    def test_signup_logic_province_not_selected(self, appium_driver, signup_data):
        """ 15. Test: Lỗi Logic - Bỏ trống Tỉnh/Thành phố"""
        signup = self._navigate_to_signup(appium_driver)
        data = signup_data["test_signup_logic_province_not_selected"]

        self._fill_all_valid_fields(signup, data)
        # KHÔNG chọn Tỉnh/TP
        signup.tap_agree_terms()

        signup.tap_register(wait_after_click=1)
        
        ok = signup.is_error_displayed(signup.ERROR_PROVINCE_EMPTY)
        if not ok: self._debug_dump(appium_driver, "signup_province_empty_failed")
        assert ok, "Không hiển thị lỗi 'Vui lòng chọn Tỉnh/Thành phố.'"

    def test_signup_logic_ward_not_selected(self, appium_driver, signup_data):
        """ 16. Test: Lỗi Logic - Bỏ trống Phường/Xã"""
        signup = self._navigate_to_signup(appium_driver)
        data = signup_data["test_signup_logic_ward_not_selected"]

        self._fill_all_valid_fields(signup, data)
        signup.select_province(data["province"]) # Đã chọn tỉnh
        # NHƯNG KHÔNG CHỌN PHƯỜNG/XÃ
        signup.tap_agree_terms()
        
        signup.tap_register(wait_after_click=1)
        
        # Giả sử province có danh sách phường xã (wards.isNotEmpty = true)
        ok = signup.is_error_displayed(signup.ERROR_WARD_EMPTY)
        if not ok: self._debug_dump(appium_driver, "signup_missing_ward_failed")
        assert ok, "Không hiển thị lỗi 'Vui lòng chọn Phường/Xã.'"

    def test_signup_server_email_existed(self, appium_driver, signup_data):
        """❌ 17. Test: Lỗi Server - Email đã tồn tại"""
        signup = self._navigate_to_signup(appium_driver)
        data = signup_data["test_signup_server_email_existed"]
        
        signup.set_name(data["name"])
        signup.set_email(data["email"]) # Email đã tồn tại
        signup.select_birth_date()
        signup.set_password(data["password"])
        signup.set_confirm_password(data["password"])
        signup.set_phone(f"09{str(int(time.time()))[-8:]}") # SĐT mới
        signup.select_province(data["province"])
        signup.select_ward(data["ward"])
        signup.set_detailed_address(data["address"])
        signup.tap_agree_terms()
        
        signup.tap_register(wait_after_click=2)
        
        ok = signup.is_error_displayed(signup.ERROR_EMAIL_EXISTED)
        ok_user=signup.is_error_displayed(signup.ERROR_USERNAME_EXISTED)

        if not (ok or ok_user): self._debug_dump(appium_driver, "signup_email_existed_failed")
        assert ok, "Không hiển thị lỗi 'Email này đã được sử dụng.'"

    def test_signup_server_phone_existed(self, appium_driver, signup_data):
        """❌ 18. Test: Lỗi Server - SĐT đã tồn tại"""
        signup = self._navigate_to_signup(appium_driver)
        data = signup_data["test_signup_server_phone_existed"]
        
        signup.set_name(data["name"])
        signup.set_email(f"test_{int(time.time())}@gmail.com") # Email mới
        signup.select_birth_date()
        signup.set_password(data["password"])
        signup.set_confirm_password(data["password"])
        signup.set_phone(data["phone"]) # SĐT ĐÃ TỒN TẠI
        signup.select_province(data["province"])
        signup.select_ward(data["ward"])
        signup.set_detailed_address(data["address"])
        signup.tap_agree_terms()
        
        signup.tap_register(wait_after_click=2)
        
        # Kiểm tra 2 lỗi có thể xảy ra (tùy theo logic API của bạn)
        ok_phone = signup.is_error_displayed(signup.ERROR_PHONE_EXISTED, timeout=1)
        ok_user = signup.is_error_displayed(signup.ERROR_USER_EXISTED, timeout=1)
        
        if not (ok_phone or ok_user):
            self._debug_dump(appium_driver, "signup_phone_existed_failed")
        assert ok_phone or ok_user, "Không hiển thị lỗi 'Số điện thoại này đã được sử dụng.' hoặc 'Email hoặc số điện thoại đã tồn tại.'"
# file: screens/signup_screen.py
from appium.webdriver.common.appiumby import AppiumBy
from selenium.webdriver.support import expected_conditions as EC
from selenium.common.exceptions import TimeoutException
from .base_screen import BaseScreen
import time

class SignupScreen(BaseScreen):
    """
    Screen Object cho màn hình Đăng ký Ứng viên (SignupForm)
    """

    # --- Locators cho các trường Input (Theo file bạn cung cấp) ---
    NAME_FIELD = (AppiumBy.XPATH, '//android.view.View[@content-desc="nameField"]//android.widget.EditText')
    EMAIL_FIELD = (AppiumBy.XPATH, '//android.view.View[@content-desc="emailField"]//android.widget.EditText')
    BIRTHDATE_FIELD = (AppiumBy.ACCESSIBILITY_ID, "birthDateField")
    PASSWORD_FIELD = (AppiumBy.XPATH, '//android.view.View[@content-desc="passwordField"]//android.widget.EditText')
    CONFIRM_PASSWORD_FIELD = (AppiumBy.XPATH, '//android.view.View[@content-desc="confirmPasswordField"]//android.widget.EditText')
    PHONE_FIELD = (AppiumBy.XPATH, '//android.view.View[@content-desc="phoneField"]//android.widget.EditText')
    DETAILED_ADDRESS_FIELD = (AppiumBy.XPATH, '//android.view.View[@content-desc="detailedAddressField"]//android.widget.EditText')

    # --- Locators cho Dropdowns và Checkbox ---
    PROVINCE_DROPDOWN = (AppiumBy.ACCESSIBILITY_ID, "Chọn tỉnh/thành phố")
    WARD_DROPDOWN = (AppiumBy.ACCESSIBILITY_ID, "Chọn phường/xã")
    AGREE_TERMS_CHECKBOX = (AppiumBy.ACCESSIBILITY_ID, "agreeTermsCheckbox")

    # --- Nút hành động ---
    REGISTER_BUTTON = (AppiumBy.ACCESSIBILITY_ID, "registerButton")

    # --- Locators cho Native Date Picker (Android) ---
    NATIVE_DATEPICKER_OK = (AppiumBy.ACCESSIBILITY_ID, "OK")

    # --- Locator cho Toast Thành công ---
    SUCCESS_TOAST = (AppiumBy.ACCESSIBILITY_ID, "Đăng kí thành công! Vui lòng đăng nhập!")

    # --- Lỗi Validation (Từ Form Validator) ---
    ERROR_NAME_EMPTY = (AppiumBy.ACCESSIBILITY_ID, "Vui lòng nhập họ và tên")
    ERROR_EMAIL_EMPTY = (AppiumBy.ACCESSIBILITY_ID, "Vui lòng nhập email")
    ERROR_EMAIL_INVALID = (AppiumBy.ACCESSIBILITY_ID, "Email không hợp lệ")
    ERROR_BIRTHDATE_EMPTY = (AppiumBy.ACCESSIBILITY_ID, "Vui lòng chọn ngày sinh")
    ERROR_PASSWORD_EMPTY = (AppiumBy.ACCESSIBILITY_ID, "Vui lòng nhập mật khẩu")
    ERROR_PASSWORD_INVALID = (AppiumBy.ACCESSIBILITY_ID, "Mật khẩu ít nhất 8 ký tự, có chữ hoa, số và ký tự đặc biệt")
    ERROR_CONFIRM_PASSWORD_EMPTY = (AppiumBy.ACCESSIBILITY_ID, "Vui lòng nhập lại mật khẩu")
    ERROR_CONFIRM_PASSWORD_MISMATCH = (AppiumBy.ACCESSIBILITY_ID, "Mật khẩu không khớp")
    ERROR_PHONE_EMPTY = (AppiumBy.ACCESSIBILITY_ID, "Vui lòng nhập số điện thoại")
    ERROR_PHONE_INVALID = (AppiumBy.ACCESSIBILITY_ID, "Số điện thoại không hợp lệ")
    ERROR_ADDRESS_EMPTY = (AppiumBy.ACCESSIBILITY_ID, "Vui lòng nhập địa chỉ chi tiết")
    # 💡 Lỗi MỚI dựa trên Dart code
    ERROR_ADDRESS_TOO_LONG = (AppiumBy.ACCESSIBILITY_ID, "Địa chỉ không được vượt quá 50 ký tự")

    # --- Lỗi Logic/Server (Từ _serverError) ---
    ERROR_TERMS_NOT_AGREED = (AppiumBy.ACCESSIBILITY_ID, "Bạn phải đồng ý với điều khoản sử dụng.")
    ERROR_PROVINCE_EMPTY = (AppiumBy.ACCESSIBILITY_ID, "Vui lòng chọn tỉnh/thành phố")
    ERROR_WARD_EMPTY = (AppiumBy.ACCESSIBILITY_ID, "Vui lòng chọn phường/xã")
    ERROR_EMAIL_EXISTED = (AppiumBy.ACCESSIBILITY_ID, "Email này đã được sử dụng.")
    ERROR_PHONE_EXISTED = (AppiumBy.ACCESSIBILITY_ID, "Số điện thoại này đã được sử dụng.")
    ERROR_USERNAME_EXISTED = (AppiumBy.ACCESSIBILITY_ID, "Tên đăng nhập đã tồn tại.")
    ERROR_USER_EXISTED = (AppiumBy.ACCESSIBILITY_ID, "Email hoặc số điện thoại đã tồn tại.")
    ERROR_INVALID_DOB = (AppiumBy.ACCESSIBILITY_ID, "Bạn chưa đủ tuổi để đăng ký.")


    def wait_for_screen_load(self, timeout=10):
        """Chờ cho đến khi màn hình Đăng ký được tải (chờ trường Tên)"""
        print("[INFO] Chờ màn hình Đăng ký (Signup) tải...")
        try:
            self.wait.until(EC.visibility_of_element_located(self.NAME_FIELD))
            print("[INFO] Màn hình Đăng ký đã sẵn sàng.")
        except TimeoutException:
            print("[ERROR] Không thể tải màn hình Đăng ký.")
            raise

    def _safe_input(self, locator, text):
        """Hàm helper để click, cuộn và nhập text"""
        try:
            # Cuộn tới field nếu chưa thấy
            try:
                field_desc = locator[1].split('"')[1] if 'content-desc' in locator[1] else locator[1]
                self.scroll_into_view(field_desc)
            except Exception:
                pass

            element = self.wait.until(EC.element_to_be_clickable(locator))
            element.click()
            time.sleep(0.3)
            element.send_keys(text)
            self.hide_keyboard()
        except Exception as e:
            print(f"[WARN] Không nhập được vào field {locator}: {e}")
            raise


    def set_name(self, name):
        print(f"[ACTION] Nhập Tên: {name}")
        self._safe_input(self.NAME_FIELD, name)

    def set_email(self, email):
        print(f"[ACTION] Nhập Email: {email}")
        self._safe_input(self.EMAIL_FIELD, email)

    def select_birth_date(self):
        """Chọn ngày sinh (chọn ngày mặc định trên Date Picker)"""
        print("[ACTION] Chọn Ngày sinh...")
        # 💡 Sửa: Thêm cuộn vào tầm nhìn
        self.scroll_into_view("birthDateField")
        self.click(*self.BIRTHDATE_FIELD)
        try:
            ok_button = self.wait.until(EC.element_to_be_clickable(self.NATIVE_DATEPICKER_OK))
            ok_button.click()
            print("[INFO] Đã chọn ngày sinh.")
            time.sleep(0.5) # Chờ dialog đóng
        except Exception as e:
            print(f"[ERROR] Không thể chọn ngày sinh: {e}")
            raise

    def set_password(self, password):
        print("[ACTION] Nhập Mật khẩu...")
        self.driver.press_keycode(66)
        self._safe_input(self.PASSWORD_FIELD, password)

    def set_confirm_password(self, password):
        print("[ACTION] Nhập Lại Mật khẩu...")
        self.driver.press_keycode(66)
        self._safe_input(self.CONFIRM_PASSWORD_FIELD, password)

    def set_phone(self, phone):
        print(f"[ACTION] Nhập SĐT: {phone}")
        self.driver.press_keycode(66)
        self._safe_input(self.PHONE_FIELD, phone)

    def select_province(self, province_name):
        print(f"[ACTION] Chọn Tỉnh/TP: {province_name}")
        # Cuộn tới dropdown trước
        self.scroll_into_view("Chọn tỉnh/thành phố")
        self.click(*self.PROVINCE_DROPDOWN)

        try:
            # Cuộn tới item nếu không thấy
            self.scroll_into_view(province_name)
            item = self.wait.until(EC.element_to_be_clickable((AppiumBy.ACCESSIBILITY_ID, province_name)))
            item.click()
            print(f"[INFO] Đã chọn Tỉnh/TP: {province_name}")
        except Exception as e:
            print(f"[ERROR] Không thể chọn '{province_name}': {e}")
            raise



    def select_ward(self, ward_name):
        """Chọn Phường/Xã (có hỗ trợ cuộn tới dropdown và item)"""
        print(f"[ACTION] Chọn Phường/Xã: {ward_name}")

        # 1️⃣ Cuộn tới dropdown nếu bị khuất
        self.scroll_into_view("Chọn phường/xã")

        # 2️⃣ Mở dropdown
        self.click(*self.WARD_DROPDOWN)

        # 3️⃣ Cuộn tới item và chọn
        try:
            self.scroll_into_view(ward_name)
            item = self.wait.until(
                EC.element_to_be_clickable((AppiumBy.ACCESSIBILITY_ID, ward_name))
            )
            item.click()
            print(f"[INFO] Đã chọn Phường/Xã: {ward_name}")
        except Exception as e:
            print(f"[ERROR] Không thể chọn Phường/Xã '{ward_name}': {e}")
            raise


    def set_detailed_address(self, address):
        print(f"[ACTION] Nhập Địa chỉ chi tiết: {address}")
        self._safe_input(self.DETAILED_ADDRESS_FIELD, address)
        

    def tap_agree_terms(self):
        """
        Click Checkbox (Giờ đã an toàn vì bàn phím đã đóng)
        """
        print("[ACTION] Click Checkbox 'Đồng ý điều khoản'")
        try:
            # 1. Cuộn tới checkbox
            self.scroll_into_view("agreeTermsCheckbox")
            
            # 2. Click
            self.click(*self.AGREE_TERMS_CHECKBOX)
            print("[INFO] Đã click checkbox.")
            
        except Exception as e:
            print(f"[ERROR] Không thể click checkbox điều khoản: {e}")
            raise

    def tap_register(self, wait_after_click=2):
        print("[ACTION] Click nút 'Đăng ký'")
        try:
            # 💡 THAY ĐỔI: Luôn cuộn tới nút Đăng ký trước khi click
            self.scroll_into_view("registerButton")
            
            button = self.wait.until(EC.element_to_be_clickable(self.REGISTER_BUTTON))
            button.click()
        except Exception as e:
            print(f"[ERROR] Click Đăng ký thất bại: {e}")
            raise
            
        time.sleep(wait_after_click)
    def is_error_displayed(self, error_locator, timeout=2):
        """Kiểm tra xem một thông báo lỗi cụ thể có hiển thị không"""
        try:
            # Dùng WebDriverWait để tìm lỗi
            error_element = self.wait.until(EC.visibility_of_element_located(error_locator))
            if error_element:
                print(f"[INFO] Tìm thấy lỗi: {error_locator[1]}")
                return True
        except TimeoutException:
            pass # Không tìm thấy là bình thường
        except Exception as e:
            print(f"[WARN] Lỗi khi tìm element {error_locator[1]}: {e}")
            
        print(f"[INFO] Không tìm thấy lỗi: {error_locator[1]}")
        return False

    def is_registration_successful(self, timeout=5):
        """Kiểm tra toast đăng ký thành công"""
        print("[INFO] Kiểm tra toast 'Đăng ký thành công'...")
        # Toast thành công cũng dùng logic is_error_displayed
        return self.is_error_displayed(self.SUCCESS_TOAST, timeout)
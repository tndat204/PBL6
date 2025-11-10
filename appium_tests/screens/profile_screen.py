# file: screens/profile_screen.py
from appium.webdriver.common.appiumby import AppiumBy
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.support.ui import WebDriverWait
from selenium.common.exceptions import TimeoutException
from .base_screen import BaseScreen
import time

class ProfileScreen(BaseScreen):
    """
    Đại diện cho Tab Hồ sơ (ProfileInfoTab)
    """

    # --- Locators cho các trường Input (từ Semantics label) ---
    HEADLINE_FIELD = (AppiumBy.XPATH, '//android.widget.EditText[@hint="Vị trí mong muốn"]')
    SUMMARY_FIELD = (AppiumBy.XPATH, '//android.widget.EditText[@hint="Tóm tắt bản thân"]')
    SALARY_FIELD = (AppiumBy.XPATH, '//android.widget.EditText[@hint="Mức lương mong muốn (VNĐ)"]')
    LINKEDIN_FIELD = (AppiumBy.XPATH, '//android.widget.EditText[@hint="Liên kết LinkedIn"]')
    PORTFOLIO_FIELD = (AppiumBy.XPATH, '//android.widget.EditText[@hint="Liên kết Portfolio"]')

    # --- Nút hành động ---
    # Lấy từ text: `_isCreating ? 'Tạo Profile' : 'Cập nhật Profile'`
    # Vì ta đang test "Cập nhật" nên _isCreating = false
    SAVE_BUTTON = (AppiumBy.ACCESSIBILITY_ID, "saveProfileButton")
    ADD_SKILL_BUTTON = (AppiumBy.ACCESSIBILITY_ID, "Thêm")

    # --- Lỗi Validation (từ code Flutter) ---
    ERROR_HEADLINE_EMPTY = (AppiumBy.ACCESSIBILITY_ID, "Vị trí mong muốn không được để trống.")
    ERROR_HEADLINE_LONG = (AppiumBy.ACCESSIBILITY_ID, "Vị trí mong muốn không được vượt quá 200 ký tự.")
    ERROR_HEADLINE_INVALID = (AppiumBy.ACCESSIBILITY_ID, "Vị trí mong muốn chứa ký tự không hợp lệ.")
    ERROR_SUMMARY_LONG = (AppiumBy.ACCESSIBILITY_ID, "Tóm tắt không được vượt quá 500 ký tự.")
    ERROR_LINKEDIN_INVALID = (AppiumBy.ACCESSIBILITY_ID, "Liên kết LinkedIn không hợp lệ.")
    ERROR_PORTFOLIO_INVALID = (AppiumBy.ACCESSIBILITY_ID, "Liên kết Portfolio không hợp lệ.")

    # --- Toast thành công ---
    SUCCESS_TOAST = (AppiumBy.ACCESSIBILITY_ID, "Cập nhật Profile thành công!")


    def wait_for_screen_load(self, timeout=10):
        """Chờ cho đến khi màn hình Profile được tải (chờ trường Headline)"""
        print("[INFO] Chờ màn hình Profile (ProfileInfoTab) tải...")
        try:
            self.wait.until(
                EC.visibility_of_element_located(self.HEADLINE_FIELD)
            )
            print("[INFO] Màn hình Profile đã sẵn sàng.")
        except TimeoutException:
            print("[ERROR] Không thể tải màn hình Profile.")
            raise

    # --- Các hàm nhập liệu (dùng input_text từ BaseScreen) ---
    def scroll_into_view_by_hint(self, hint_text):
 
        print(f"[INFO] Đang cuộn tới trường có hint: '{hint_text}'...")
        try:
            # UiSelector().textContains(hint_text) sẽ tìm @hint
            element = self.driver.find_element(
                AppiumBy.ANDROID_UIAUTOMATOR,
                f'new UiScrollable(new UiSelector().scrollable(true)).scrollIntoView(new UiSelector().className("android.widget.EditText").textContains("{hint_text}"))'
            )
            print(f"[INFO] Đã cuộn tới hint '{hint_text}' bằng UiScrollable")
            return element
        except Exception as e:
            print(f"[WARN] UiScrollable (hint) thất bại: {e}. Thử cuộn thủ công...")
          
        pass
    def set_headline(self, text):
        print(f"[ACTION] Nhập Vị trí mong muốn: {text}")
        self.scroll_into_view_by_hint("Vị trí mong muốn") # Sửa
        self.input_text(self.HEADLINE_FIELD[0], self.HEADLINE_FIELD[1], text)
        self.hide_keyboard() 

    def set_summary(self, text):
        print(f"[ACTION] Nhập Tóm tắt: {text[:20]}...")
        self.scroll_into_view_by_hint("Tóm tắt bản thân") # Sửa
        self.input_text(self.SUMMARY_FIELD[0], self.SUMMARY_FIELD[1], text)
        self.hide_keyboard()

    def set_salary(self, text):
        print(f"[ACTION] Nhập Lương: {text}")
        self.scroll_into_view_by_hint("Mức lương mong muốn (VNĐ)") # Sửa
        self.input_text(self.SALARY_FIELD[0], self.SALARY_FIELD[1], text)
        self.hide_keyboard()

    def set_linkedin(self, text):
        print(f"[ACTION] Nhập LinkedIn: {text}")
        self.scroll_into_view_by_hint("Liên kết LinkedIn") # Sửa
        self.input_text(self.LINKEDIN_FIELD[0], self.LINKEDIN_FIELD[1], text)
        self.hide_keyboard()

    def set_portfolio(self, text):
        print(f"[ACTION] Nhập Portfolio: {text}")
        self.scroll_into_view_by_hint("Liên kết Portfolio") # Sửa
        self.input_text(self.PORTFOLIO_FIELD[0], self.PORTFOLIO_FIELD[1], text)
        self.hide_keyboard()

    def tap_save_button(self, wait_after_click=2):
        print("[ACTION] Click nút 'Cập nhật Profile'")
        try:
            self.scroll_into_view("saveProfileButton") 
            self.click(self.SAVE_BUTTON[0], self.SAVE_BUTTON[1])
        except Exception as e:
            print(f"[ERROR] Click Cập nhật thất bại: {e}")
            raise
        
        print(f"[INFO] Chờ xử lý {wait_after_click}s...")
        time.sleep(wait_after_click)
    
    # --- Các hàm kiểm tra (Assert) ---

    def is_error_displayed(self, error_locator, timeout=2):
        """
        Kiểm tra lỗi, nếu không thấy sẽ tự cuộn lên đầu trang và tìm lại
        (Giống hệt hàm trong signup_screen)
        """
        try:
            # 1. Thử tìm nhanh (1 giây)
            WebDriverWait(self.driver, 1).until(
                EC.visibility_of_element_located(error_locator)
            )
            print(f"[INFO] Tìm thấy lỗi: {error_locator[1]}")
            return True
        except TimeoutException:
            # 2. Không thấy, cuộn lên đầu trang
            print(f"[INFO] Không thấy lỗi '{error_locator[1]}'. Đang cuộn lên đầu...")
            self.scroll_to_top() # <-- Gọi hàm cuộn lên đầu trang từ BaseScreen
            
            # 3. Thử tìm lại với timeout gốc
            try:
                WebDriverWait(self.driver, timeout).until(
                    EC.visibility_of_element_located(error_locator)
                )
                print(f"[INFO] Tìm thấy lỗi sau khi cuộn lên: {error_locator[1]}")
                return True
            except TimeoutException:
                print(f"[INFO] Vẫn không thấy lỗi '{error_locator[1]}' sau khi cuộn.")
                return False
        except Exception as e:
            print(f"[WARN] Lỗi lạ khi tìm element {error_locator[1]}: {e}")
            return False

    def is_update_successful(self, timeout=5):
        """Kiểm tra toast cập nhật thành công"""
        print("[INFO] Kiểm tra toast 'Cập nhật Profile thành công!'...")
        try:
            WebDriverWait(self.driver, timeout).until(
                EC.visibility_of_element_located(self.SUCCESS_TOAST)
            )
            print("[INFO] Tìm thấy toast 'Cập nhật Profile thành công!'")
            return True
        except TimeoutException:
            print("[INFO] Không tìm thấy toast 'Cập nhật Profile thành công!'")
            return False
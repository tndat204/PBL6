# file: screens/base_screen.py
from appium.webdriver.common.appiumby import AppiumBy
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.common.exceptions import TimeoutException, NoSuchElementException
import time # 💡 Thêm import time

class BaseScreen:
    def __init__(self, driver):
        self.driver = driver
        self.wait = WebDriverWait(self.driver, 20) # Tăng timeout chờ mặc định

    def _find_element(self, locator_type, locator_value, timeout=20, condition="presence"):
        """
        💡 Cập nhật: Hàm tìm kiếm nội bộ với các điều kiện chờ khác nhau.
        condition: 'presence' (tồn tại), 'clickable' (có thể nhấp), 'visible' (hiển thị)
        """
        try:
            if condition == "clickable":
                wait_condition = EC.element_to_be_clickable((locator_type, locator_value))
            elif condition == "visible":
                wait_condition = EC.visibility_of_element_located((locator_type, locator_value))
            else: # Mặc định là 'presence'
                wait_condition = EC.presence_of_element_located((locator_type, locator_value))
                
            return WebDriverWait(self.driver, timeout).until(wait_condition)
            
        except TimeoutException:
            screenshot_path = "fail_debug.png"
            self.driver.get_screenshot_as_file(screenshot_path)
            print(f"[DEBUG] Screenshot saved at {screenshot_path}")
            print(f"[DEBUG] Current activity: {self.driver.current_activity}")
            raise NoSuchElementException(f"Không tìm thấy phần tử ({condition}): {locator_value}")

    def click(self, locator_type, locator_value):
        """
        💡 Cập nhật: Hàm click giờ sẽ chờ cho đến khi element CÓ THỂ CLICK ĐƯỢC.
        Đây là thay đổi quan trọng nhất để sửa lỗi của bạn.
        """
        element = self._find_element(locator_type, locator_value, condition="clickable")
        element.click()

    def input_text(self, locator_type, locator_value, text):
        """
        💡 Cập nhật: Hàm input_text cũng nên chờ 'clickable' để an toàn.
        """
        element = self._find_element(locator_type, locator_value, condition="clickable")
        element.clear()
        element.send_keys(text)

    def is_element_displayed(self, locator_type, locator_value, timeout=10, scroll_if_needed=True):
        """
        Kiểm tra phần tử có hiển thị không, có thể tự động cuộn nếu chưa thấy.
        """
        try:
            self._find_element(locator_type, locator_value, timeout, condition="visible")
            return True
        except (TimeoutException, NoSuchElementException):
            if scroll_if_needed:
                print(f"[INFO] Không thấy phần tử {locator_value}, thử cuộn để tìm...")
                try:
                    # 💡 Cuộn nhẹ lên (hoặc xuống) vài lần
                    for i in range(3):
                        size = self.driver.get_window_size()
                        start_x = size['width'] // 2
                        start_y = int(size['height'] * 0.3)
                        end_y = int(size['height'] * 0.8)
                        self.driver.swipe(start_x, start_y, start_x, end_y, 600)
                        time.sleep(0.6)
                        if self.is_element_displayed(locator_type, locator_value, timeout=3, scroll_if_needed=False):
                            print(f"[INFO] Đã tìm thấy phần tử sau khi cuộn {i+1} lần.")
                            return True
                except Exception as e:
                    print(f"[WARN] Lỗi khi cuộn tìm phần tử: {e}")
            return False


    def find_element_by_accessibility_id(self, access_id, timeout=10):
        try:
            return self._find_element(AppiumBy.ACCESSIBILITY_ID, access_id, timeout, condition="presence")
        except (TimeoutException, NoSuchElementException):
            return None
            
    def scroll_to_element(self, text, max_swipes=5):
        """
        Cuộn dọc màn hình (scroll down) cho đến khi tìm thấy phần tử có Accessibility ID = text
        """
        for i in range(max_swipes):
            try:
                # Dùng find_elements (số nhiều) để tránh bị throw exception ngay lập tức
                elements = self.driver.find_elements(AppiumBy.ACCESSIBILITY_ID, text)
                if elements: # Nếu list không rỗng
                    print(f"[INFO] Đã tìm thấy phần tử '{text}' sau {i+1} lần cuộn")
                    return elements[0] # Trả về element đầu tiên
            except:
                pass # Bỏ qua nếu tìm kiếm thất bại
            
            print(f"[DEBUG] Chưa thấy '{text}', đang cuộn lần {i+1}...")
            size = self.driver.get_window_size()
            start_x = size['width'] // 2
            start_y = int(size['height'] * 0.8)
            end_y = int(size['height'] * 0.2)
            self.driver.swipe(start_x, start_y, start_x, end_y, 800)
            time.sleep(0.8)
            
        raise Exception(f"Không tìm thấy phần tử có Accessibility ID: {text}")
    
    def scroll_into_view(self, text):
        """
        Dùng UiScrollable để cuộn đến phần tử có content-desc (description) = text
        """
        try:
            element = self.driver.find_element(
                AppiumBy.ANDROID_UIAUTOMATOR,
                f'new UiScrollable(new UiSelector().scrollable(true)).scrollIntoView(new UiSelector().description("{text}"))'
            )
            print(f"[INFO] Đã cuộn tới '{text}' bằng UiScrollable")
            return element
        except Exception as e:
            print(f"[WARN] UiScrollable thất bại: {e}. Thử cuộn thủ công...")
            return self.scroll_to_element(text)
   
    def hide_keyboard(self):
        """Hàm helper để ẩn bàn phím, bắt lỗi nếu thất bại"""
        try:
            # Dùng API chuẩn của Appium để ẩn bàn phím
            self.driver.hide_keyboard() 
            print("[INFO] Đã ẩn bàn phím.")
            time.sleep(0.5) # Chờ bàn phím đóng
        except Exception as e:
            # Bỏ qua lỗi nếu không có bàn phím để ẩn
            print(f"[WARN] Không thể ẩn bàn phím (có thể nó đã ẩn): {e}")
from appium.webdriver.common.appiumby import AppiumBy
from .base_screen import BaseScreen
import time
import os

class HomeScreen(BaseScreen):
    DASHBOARD_TITLE = (AppiumBy.ACCESSIBILITY_ID, "Chào mừng bạn đến trang tổng quan ứng viên!")

    def is_dashboard_displayed(self, timeout=10):
        """
        Thử tìm element dashboard trong 'timeout' giây.
        Nếu không thấy: lưu screenshot + page_source để debug.
        Trả về True/False.
        """
        try:
            found = self.is_element_displayed(self.DASHBOARD_TITLE[0], self.DASHBOARD_TITLE[1], timeout)
            if found:
                print("[INFO] Đã vào Dashboard (tìm thấy tiêu đề).")
                return True
            else:
                # not found -> debug dump
                print("[DEBUG] Không tìm thấy tiêu đề Dashboard. Chụp ảnh debug...")
                ts = int(time.time())
                
                # Đảm bảo thư mục screenshots tồn tại
                if not os.path.exists("screenshots"):
                    os.makedirs("screenshots")
                    
                screenshot = os.path.join("screenshots", f"debug_dashboard_not_found_{ts}.png")
                pagesrc = os.path.join("screenshots", f"debug_dashboard_page_source_{ts}.xml")
                
                try:
                    self.driver.get_screenshot_as_file(screenshot)
                    print(f"[DEBUG] Screenshot saved: {screenshot}")
                except Exception as e:
                    print(f"[DEBUG] Failed to save screenshot: {e}")
                try:
                    src = self.driver.page_source
                    with open(pagesrc, "w", encoding="utf-8") as f:
                        f.write(src)
                    print(f"[DEBUG] Page source saved: {pagesrc}")
                except Exception as e:
                    print(f"[DEBUG] Failed to save page source: {e}")
                
                return False
        except Exception as e:
            print(f"[ERROR] Exception when checking dashboard: {e}")
            return False

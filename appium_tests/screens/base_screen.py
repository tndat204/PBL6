# file: screens/base_screen.py
from appium.webdriver.common.appiumby import AppiumBy
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.common.exceptions import TimeoutException, NoSuchElementException

class BaseScreen:
    def __init__(self, driver):
        self.driver = driver
        self.wait = WebDriverWait(self.driver, 20)

    def _find_element(self, locator_type, locator_value, timeout=20):
        try:
            return WebDriverWait(self.driver, timeout).until(
                EC.presence_of_element_located((locator_type, locator_value))
            )
        except TimeoutException:
            screenshot_path = "fail_debug.png"
            self.driver.get_screenshot_as_file(screenshot_path)
            print(f"[DEBUG] Screenshot saved at {screenshot_path}")
            print(f"[DEBUG] Current activity: {self.driver.current_activity}")
            raise NoSuchElementException(f"Không tìm thấy phần tử: {locator_value}")

    def click(self, locator_type, locator_value):
        element = self._find_element(locator_type, locator_value)
        element.click()

    def input_text(self, locator_type, locator_value, text):
        element = self._find_element(locator_type, locator_value)
        element.clear()
        element.send_keys(text)

    def is_element_displayed(self, locator_type, locator_value, timeout=10):
        try:
            WebDriverWait(self.driver, timeout).until(
                EC.presence_of_element_located((locator_type, locator_value))
            )
            return True
        except TimeoutException:
            return False

    def find_element_by_accessibility_id(self, access_id, timeout=10):
        try:
            return WebDriverWait(self.driver, timeout).until(
                EC.presence_of_element_located((AppiumBy.ACCESSIBILITY_ID, access_id))
            )
        except TimeoutException:
            return None

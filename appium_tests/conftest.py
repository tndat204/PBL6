# file: conftest.py
import pytest
from appium import webdriver
from appium.options.android import UiAutomator2Options

@pytest.fixture(scope="function")
def appium_driver():
    options = UiAutomator2Options()
    options.platform_name = "Android"
    options.device_name = "emulator-5554"
    options.automation_name = "UiAutomator2"
    options.app = "F:/NAM4/PBL6/PBL6/pbl6/build/app/outputs/flutter-apk/app-debug.apk"
    options.app_package = "com.example.pbl6"
    options.app_activity = "com.example.pbl6.MainActivity"
    options.no_reset = False

    driver = webdriver.Remote("http://localhost:4723", options=options)
    driver.implicitly_wait(10)
    yield driver
    driver.quit()

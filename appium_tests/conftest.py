# file: tests/conftest.py
import pytest
from appium import webdriver
from appium.options.android import UiAutomator2Options

# 💡 Thêm 2 import này
import json
import os

@pytest.fixture(scope="function")
def appium_driver():
    options = UiAutomator2Options()
    options.platform_name = "Android"
    options.device_name = "emulator-5554"
    options.automation_name = "UiAutomator2"
    options.app = "F:/NAM4/PBL6/PBL6/pbl6/build/app/outputs/flutter-apk/app-debug.apk"
    options.app_package = "com.example.pbl6"
    options.app_activity = "com.example.pbl6.MainActivity"
    options.no_reset = False # Đặt là True nếu bạn muốn test nhanh hơn (không cài lại app)

    driver = webdriver.Remote("http://localhost:4723", options=options)
    driver.implicitly_wait(10)
    yield driver
    driver.quit()

# --- HÀM HELPER TẢI DỮ LIỆU ---
def _load_json_data(file_name):
    """
    Hàm helper nội bộ để tải một file JSON cụ thể từ thư mục 'data'.
    """
    # Lấy đường dẫn tuyệt đối đến thư mục 'tests' (nơi file conftest.py này ở)
    base_dir = os.path.dirname(os.path.abspath(__file__))
    
    # Trỏ đường dẫn ra ngoài 'tests' và vào 'data/FILE_NAME'
    data_file_path = os.path.join(base_dir, 'data', file_name)

    try:
        with open(data_file_path, 'r', encoding='utf-8') as f:
            data = json.load(f)
        print(f"\n[INFO] Đã tải dữ liệu test từ {file_name} thành công.")
        return data
    except FileNotFoundError:
        print(f"\n[ERROR] Không tìm thấy file dữ liệu tại: {data_file_path}")
        pytest.fail(f"Không tìm thấy file dữ liệu: {data_file_path}")
    except json.JSONDecodeError:
        print(f"\n[ERROR] File dữ liệu JSON không hợp lệ: {data_file_path}")
        pytest.fail(f"Lỗi đọc file JSON: {data_file_path}")

# --- CÁC FIXTURE DỮ LIỆU RIÊNG BIỆT ---

@pytest.fixture(scope="session")
def login_data():
    """
    Tải dữ liệu test CHỈ cho tính năng Login.
    """
    return _load_json_data('login_data.json')

@pytest.fixture(scope="session")
def signup_data():
    """
    Tải dữ liệu test CHỈ cho tính năng Signup.
    """
    return _load_json_data('signup_data.json')
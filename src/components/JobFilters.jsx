import { useState } from "react";
import { IoIosSearch } from "react-icons/io";

function JobFilters({ onFilterChange }) {
  const [company, setCompany] = useState('');
  const [category, setCategory] = useState('');
  const [location, setLocation] = useState('');
  const [workTypes, setWorkTypes] = useState([]);
  const [salaryRange, setSalaryRange] = useState('');

  const handleWorkTypeChange = (type) => {
    setWorkTypes(prev => {
      if (prev.includes(type)) {
        return prev.filter(t => t !== type);
      } else {
        return [...prev, type];
      }
    });
  };

  const applyFilters = () => {
    onFilterChange({
      company,
      category,
      location,
      workTypes,
      salaryRange
    });
  };

  return (
    <div className="bg-white rounded-lg shadow-md p-4">
      {/* Tiêu đề chính */}
      <h2 className="text-lg font-semibold text-gray-800 mb-4">Bộ lọc</h2>

      {/* Tìm kiếm công ty */}
      <div className="mb-4">
        <label className="block font-medium text-gray-700 mb-1">Tìm kiếm công ty</label>
        <div className="relative">
          <input
            type="text"
            placeholder="Nhập tên công ty..."
            value={company}
            onChange={(e) => setCompany(e.target.value)}
            className="w-full border border-gray-300 rounded px-3 py-2 pl-8 text-gray-700 outline-none"
          />
          <span className="absolute left-2 top-1/2 transform -translate-y-1/2 text-gray-400 flex items-center">
            <IoIosSearch className="text-gray-600 text-xl" />
          </span>
        </div>
      </div>

      {/* Danh mục / Lĩnh vực */}
      <div className="mb-4">
        <label className="block font-medium text-gray-700 mb-1">Lĩnh vực</label>
        <select
          value={category}
          onChange={(e) => setCategory(e.target.value)}
          className="w-full border border-gray-300 rounded px-3 py-2 text-gray-700 outline-none"
        >
          <option value="">Tất cả lĩnh vực</option>
          <option value="Thiết kế Web">Thiết kế Web</option>
          <option value="Thiết kế Đồ họa">Thiết kế Đồ họa</option>
          <option value="Lập trình viên">Lập trình viên</option>
          <option value="Marketing">Marketing</option>
          <option value="Kinh doanh">Kinh doanh</option>
        </select>
      </div>

      {/* Địa điểm */}
      <div className="mb-4">
        <label className="block font-medium text-gray-700 mb-1">Địa điểm</label>
        <select
          value={location}
          onChange={(e) => setLocation(e.target.value)}
          className="w-full border border-gray-300 rounded px-3 py-2 text-gray-700 outline-none"
        >
          <option value="">Tất cả địa điểm</option>
          <option value="Hà Nội">Hà Nội</option>
          <option value="TP. Hồ Chí Minh">TP. Hồ Chí Minh</option>
          <option value="Đà Nẵng">Đà Nẵng</option>
          <option value="Hải Phòng">Hải Phòng</option>
          <option value="Cần Thơ">Cần Thơ</option>
        </select>
      </div>

      {/* Hình thức làm việc */}
      <div className="mb-4">
        <label className="block font-medium text-gray-700 mb-1">Hình thức làm việc</label>
        <div className="space-y-2">
          <label className="flex items-center text-gray-700">
            <input
              type="checkbox"
              checked={workTypes.includes('Full Time')}
              onChange={() => handleWorkTypeChange('Full Time')}
              className="mr-2 border border-gray-300 rounded outline-none"
            />
            Toàn thời gian
          </label>
          <label className="flex items-center text-gray-700">
            <input
              type="checkbox"
              checked={workTypes.includes('Part Time')}
              onChange={() => handleWorkTypeChange('Part Time')}
              className="mr-2 border border-gray-300 rounded outline-none"
            />
            Bán thời gian
          </label>
          <label className="flex items-center text-gray-700">
            <input
              type="checkbox"
              checked={workTypes.includes('Freelance')}
              onChange={() => handleWorkTypeChange('Freelance')}
              className="mr-2 border border-gray-300 rounded outline-none"
            />
            Làm tự do (Freelance)
          </label>
          <label className="flex items-center text-gray-700">
            <input
              type="checkbox"
              checked={workTypes.includes('Remote')}
              onChange={() => handleWorkTypeChange('Remote')}
              className="mr-2 border border-gray-300 rounded outline-none"
            />
            Làm từ xa (Remote)
          </label>
        </div>
      </div>

      {/* Mức lương */}
      <div className="mb-4">
        <label className="block font-medium text-gray-700 mb-1">Mức lương</label>
        <div className="space-y-2">
          <label className="flex items-center text-gray-700">
            <input
              type="radio"
              name="salary"
              value="10-15"
              checked={salaryRange === '10-15'}
              onChange={(e) => setSalaryRange(e.target.value)}
              className="mr-2 border border-gray-300 rounded outline-none"
            />
            10 triệu - 15 triệu
          </label>
          <label className="flex items-center text-gray-700">
            <input
              type="radio"
              name="salary"
              value="15-25"
              checked={salaryRange === '15-25'}
              onChange={(e) => setSalaryRange(e.target.value)}
              className="mr-2 border border-gray-300 rounded outline-none"
            />
            15 triệu - 25 triệu
          </label>
          <label className="flex items-center text-gray-700">
            <input
              type="radio"
              name="salary"
              value="25+"
              checked={salaryRange === '25+'}
              onChange={(e) => setSalaryRange(e.target.value)}
              className="mr-2 border border-gray-300 rounded outline-none"
            />
            Trên 25 triệu
          </label>
        </div>
      </div>

      {/* Nút bấm */}
      <button
        onClick={applyFilters}
        className="bg-sea-400 hover:bg-sea-300 w-full py-2 rounded-lg text-white font-medium transition-colors"
      >
        Áp dụng bộ lọc
      </button>
    </div>
  );
}

export default JobFilters;

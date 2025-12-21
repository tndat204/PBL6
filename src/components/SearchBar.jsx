import { useState } from "react";
import { FaSearch, FaMapMarkerAlt, FaBriefcase } from "react-icons/fa";

function SearchBar({ onSearch }) {
  const [keyword, setKeyword] = useState('');
  const [location, setLocation] = useState('');
  const [jobType, setJobType] = useState('');

  const handleSearch = () => {
    onSearch({
      keyword,
      location,
      jobType
    });
  };

  const handleKeyPress = (e) => {
    if (e.key === 'Enter') {
      handleSearch();
    }
  };

  return (
    <div className="bg-white rounded-lg shadow-md p-4 flex flex-col md:flex-row items-center gap-3 md:gap-0 md:divide-x max-w-5xl mx-auto -mt-10 relative z-10">

      {/* Keywords */}
      <div className="flex items-center px-3 w-full md:flex-1">
        <FaSearch className="text-sea-300 mr-2" />
        <input
          type="text"
          placeholder="Tìm kiếm từ khóa"
          value={keyword}
          onChange={(e) => setKeyword(e.target.value)}
          onKeyPress={handleKeyPress}
          className="w-full outline-none text-gray-700"
        />
      </div>

      {/* Location */}
      <div className="flex items-center px-3 w-full md:flex-1">
        <FaMapMarkerAlt className="text-sea-300 mr-2" />
        <select
          value={location}
          onChange={(e) => setLocation(e.target.value)}
          className="w-full outline-none text-gray-700 bg-transparent"
        >
          <option value="">Tất cả địa điểm</option>
          <option value="Hà Nội">Hà Nội</option>
          <option value="TP. Hồ Chí Minh">TP. Hồ Chí Minh</option>
          <option value="Đà Nẵng">Đà Nẵng</option>
          <option value="Hải Phòng">Hải Phòng</option>
          <option value="Cần Thơ">Cần Thơ</option>
        </select>
      </div>

      {/* Job Type */}
      <div className="flex items-center px-3 w-full md:flex-1">
        <FaBriefcase className="text-sea-300 mr-2" />
        <select
          value={jobType}
          onChange={(e) => setJobType(e.target.value)}
          className="w-full outline-none text-gray-700 bg-transparent"
        >
          <option value="">Tất cả loại hình</option>
          <option value="Full Time">Toàn thời gian</option>
          <option value="Part Time">Bán thời gian</option>
          <option value="Remote">Làm từ xa</option>
          <option value="Freelance">Freelance</option>
        </select>
      </div>

      {/* Search Button */}
      <div className="px-3 w-full md:w-auto">
        <button
          onClick={handleSearch}
          className="bg-sea-400 hover:bg-sea-300 text-white px-6 py-3 rounded-lg font-medium w-full md:w-auto whitespace-nowrap transition-colors"
        >
          Tìm kiếm
        </button>
      </div>
    </div>
  );
}

export default SearchBar;
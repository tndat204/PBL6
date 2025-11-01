import { FaSearch, FaMapMarkerAlt, FaBriefcase } from "react-icons/fa";

function SearchBar() {
  return (
    <div className="bg-white rounded-lg shadow-md p-4 flex flex-col md:flex-row items-center gap-3 md:gap-0 md:divide-x max-w-5xl mx-auto -mt-10 relative z-10">
      {/* Keywords */}
      <div className="flex items-center px-3 w-full md:w-1/3">
        <FaSearch className="text-sea-300 mr-2" />
        <input
          type="text"
          placeholder="Search your Keywords"
          className="w-full outline-none text-gray-700"
        />
      </div>

      {/* Location */}
      <div className="flex items-center px-3 w-full md:w-1/3">
        <FaMapMarkerAlt className="text-sea-300 mr-2" />
        <select className="w-full outline-none text-gray-700 bg-transparent">
          <option>Afghanistan</option>
          <option>Australia</option>
          <option>USA</option>
          <option>Vietnam</option>
        </select>
      </div>

      {/* Job Type */}
      <div className="flex items-center px-3 w-full md:w-1/3">
        <FaBriefcase className="text-sea-300 mr-2" />
        <select className="w-full outline-none text-gray-700 bg-transparent">
          <option>Full Time</option>
          <option>Part Time</option>
          <option>Remote</option>
        </select>
      </div>

      {/* Search Button */}
      <button className="bg-sea-400 hover:bg-sea-300 text-white px-6 py-3 rounded-lg font-medium md:ml-3 w-full md:w-auto mt-3 md:mt-0 transition-colors">
        Search
      </button>
    </div>
  );
}

export default SearchBar;
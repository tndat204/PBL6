// import { IoIosSearch } from "react-icons/io";
// function JobFilters() {
//   return (
//     <div className="bg-white rounded-lg shadow-md p-4">
//       <h2 className="text-lg font-semibold text-gray-800 mb-4">Filters</h2>
//       <div className="mb-4">
//         <label className="block font-medium text-gray-700 mb-1">Search Company</label>
//         <div className="relative">
//            <input
//             type="text"
//             placeholder="Search"
//             className="w-full border border-gray-300 rounded px-3 py-2 pl-8 text-gray-700 outline-none"
//           />
//           <span className="absolute left-2 top-1/2 transform -translate-y-1/2 text-gray-400 flex items-center">
//             <IoIosSearch className="text-gray-600 text-xl" />
//           </span>
//         </div>
//       </div>
//       <div className="mb-4">
//         <label className="block font-medium text-gray-700 mb-1">Categories</label>
//         <select className="w-full border border-gray-300 rounded px-3 py-2 text-gray-700 outline-none">
//           <option>Web Designer</option>
//           <option>Graphic Designer</option>
//           <option>Developer</option>
//         </select>
//       </div>
//       <div className="mb-4">
//         <label className="block font-medium text-gray-700 mb-1">Location</label>
//         <select className="w-full border border-gray-300 rounded px-3 py-2 text-gray-700 outline-none">
//           <option>New York</option>
//           <option>Los Angeles</option>
//           <option>Chicago</option>
//         </select>
//       </div>
//       <div className="mb-4">
//         <label className="block font-medium text-gray-700 mb-1">Job Types</label>
//         <div className="space-y-2">
//           <label className="flex items-center text-gray-700">
//             <input type="checkbox" className="mr-2 border border-gray-300 rounded outline-none" />
//             Full Time
//           </label>
//           <label className="flex items-center text-gray-700">
//             <input type="checkbox" className="mr-2 border border-gray-300 rounded outline-none" />
//             Part Time
//           </label>
//           <label className="flex items-center text-gray-700">
//             <input type="checkbox" className="mr-2 border border-gray-300 rounded outline-none" />
//             Freelancing
//           </label>
//           <label className="flex items-center text-gray-700">
//             <input type="checkbox" className="mr-2 border border-gray-300 rounded outline-none" />
//             Fixed Price
//           </label>
//           <label className="flex items-center text-gray-700">
//             <input type="checkbox" className="mr-2 border border-gray-300 rounded outline-none" />
//             Remote
//           </label>
//           <label className="flex items-center text-gray-700">
//             <input type="checkbox" className="mr-2 border border-gray-300 rounded outline-none" />
//             Hourly Basis
//           </label>
//         </div>
//       </div>
//       <div className="mb-4">
//         <label className="block font-medium text-gray-700 mb-1">Salary</label>
//         <div className="space-y-2">
//           <label className="flex items-center text-gray-700">
//             <input type="radio" name="salary" className="mr-2 border border-gray-300 rounded outline-none" defaultChecked />
//             10k - 15k
//           </label>
//           <label className="flex items-center text-gray-700">
//             <input type="radio" name="salary" className="mr-2 border border-gray-300 rounded outline-none" />
//             15k - 25k
//           </label>
//           <label className="flex items-center text-gray-700">
//             <input type="radio" name="salary" className="mr-2 border border-gray-300 rounded outline-none" />
//             more than 25k
//           </label>
//         </div>
//       </div>
//       <button className="bg-sea-400 hover:bg-sea-300 w-full py-2 rounded-lg text-white font-medium transition-colors">
//         Apply Filter
//       </button>
//     </div>
//   );
// }

// export default JobFilters;

import { IoIosSearch } from "react-icons/io";

function JobFilters() {
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
        <select className="w-full border border-gray-300 rounded px-3 py-2 text-gray-700 outline-none">
          <option>Thiết kế Web</option>
          <option>Thiết kế Đồ họa</option>
          <option>Lập trình viên</option>
        </select>
      </div>

      {/* Địa điểm */}
      <div className="mb-4">
        <label className="block font-medium text-gray-700 mb-1">Địa điểm</label>
        <select className="w-full border border-gray-300 rounded px-3 py-2 text-gray-700 outline-none">
          <option>Hà Nội</option>
          <option>TP. Hồ Chí Minh</option>
          <option>Đà Nẵng</option>
        </select>
      </div>

      {/* Hình thức làm việc */}
      <div className="mb-4">
        <label className="block font-medium text-gray-700 mb-1">Hình thức làm việc</label>
        <div className="space-y-2">
          <label className="flex items-center text-gray-700">
            <input type="checkbox" className="mr-2 border border-gray-300 rounded outline-none" />
            Toàn thời gian
          </label>
          <label className="flex items-center text-gray-700">
            <input type="checkbox" className="mr-2 border border-gray-300 rounded outline-none" />
            Bán thời gian
          </label>
          <label className="flex items-center text-gray-700">
            <input type="checkbox" className="mr-2 border border-gray-300 rounded outline-none" />
            Làm tự do (Freelance)
          </label>
          <label className="flex items-center text-gray-700">
            <input type="checkbox" className="mr-2 border border-gray-300 rounded outline-none" />
            Giá cố định
          </label>
          <label className="flex items-center text-gray-700">
            <input type="checkbox" className="mr-2 border border-gray-300 rounded outline-none" />
            Làm từ xa (Remote)
          </label>
          <label className="flex items-center text-gray-700">
            <input type="checkbox" className="mr-2 border border-gray-300 rounded outline-none" />
            Theo giờ
          </label>
        </div>
      </div>

      {/* Mức lương */}
      <div className="mb-4">
        <label className="block font-medium text-gray-700 mb-1">Mức lương</label>
        <div className="space-y-2">
          <label className="flex items-center text-gray-700">
            <input type="radio" name="salary" className="mr-2 border border-gray-300 rounded outline-none" defaultChecked />
            10 triệu - 15 triệu
          </label>
          <label className="flex items-center text-gray-700">
            <input type="radio" name="salary" className="mr-2 border border-gray-300 rounded outline-none" />
            15 triệu - 25 triệu
          </label>
          <label className="flex items-center text-gray-700">
            <input type="radio" name="salary" className="mr-2 border border-gray-300 rounded outline-none" />
            Trên 25 triệu
          </label>
        </div>
      </div>

      {/* Nút bấm */}
      <button className="bg-sea-400 hover:bg-sea-300 w-full py-2 rounded-lg text-white font-medium transition-colors">
        Áp dụng bộ lọc
      </button>
    </div>
  );
}

export default JobFilters;
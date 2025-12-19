// import MainLayout from "../layouts/MainLayout";
// import JobList from "../components/JobList";
// import { AiOutlineReload } from "react-icons/ai";

// function CompanyPosts() {
//   const company = {
//     name: "CMC Global",
//     location: "London, UK",
//     banner: "/images/banner.jpg", // ảnh banner nền
//     logo: "/images/cmc.png", // logo công ty
//   };

//   const jobs = [
//     {
//       id: 1,
//       title: "UI - UX Designer",
//       company: "CMC Global",
//       type: "Fulltime",
//       hourly: "2000",
//       location: "",
//       tags: ["HTML", "CSS", "Bootstrap"],
//       daysAgo: "",
//       description: "Looking for an experienced Web Designer for our company.",
//     },
//     {
//       id: 2,
//       title: "UI - UX Designer",
//       company: "CMC Global",
//       type: "Fulltime",
//       hourly: "2000",
//       location: "",
//       tags: ["HTML", "CSS", "Bootstrap"],
//       daysAgo: "",
//       description: "Looking for an experienced Web Designer for our company.",
//     },
//   ];

//   return (
//     <MainLayout>
      

//       {/* Company Info Card */}
//       <div className="flex items-center gap-4 mt-[-120px] relative z-30 bg-white p-5 rounded-xl shadow-md">
//         <img
//           src={company.logo}
//           alt="Company logo"
//           className="w-16 h-16 rounded-md border border-gray-300 bg-white p-2"
//         />
//         <div>
//           <h2 className="text-xl font-semibold text-gray-800">
//             {company.name}
//           </h2>
//           <p className="text-gray-500">{company.location}</p>
//         </div>
//       </div>

//       {/* Job Posts Section */}
//       <div className=" mx-auto mt-10">
//         <div className="flex justify-between items-center mb-4 bg-white p-5 rounded-xl shadow-md mb-6">
//           <h3 className="text-lg font-semibold text-gray-800">Job posts</h3>
//           <div className="flex items-center gap-2 text-sm">
//             <select
//                 defaultValue="all"
//                 className="border border-gray-300 rounded-sm px-2 py-2 text-gray-700 
//                         focus:outline-none"
//             >
//                 <option value="all">Tất cả</option>
//                 <option value="active">Đang đăng</option>
//                 <option value="posted">Đã đăng</option>
//                 <option value="draft">Chưa đăng</option>
//             </select>

//             <button className="bg-sea-400 hover:bg-sea-300 text-white px-4 py-2 rounded-sm text-sm transition-colors">
//                 New post
//             </button>
//             </div>
//         </div>

//         {/* Job list */}
//         <div className="space-y-6">
//           <JobList jobs={jobs} columns={1} />
//         </div>

//         {/* Load more div */}
//         <div className="flex justify-center mt-8">
//           <div className="bg-sea-400 hover:bg-sea-300 text-white px-4 py-2 rounded-sm text-sm transition-colors">
//             Load more
//           </div>
//         </div>
//       </div>
//     </MainLayout>
//   );
// }

// export default CompanyPosts;


import MainLayout from "../layouts/MainLayout";
import JobList from "../components/JobList";
import { AiOutlineReload } from "react-icons/ai";

function CompanyPosts() {
  const company = {
    name: "CMC Global",
    location: "Hà Nội, Việt Nam", // Sửa thành địa điểm Việt Nam
    banner: "/images/banner.jpg",
    logo: "/images/cmc.png",
  };

  const jobs = [
    {
      id: 1,
      title: "UI - UX Designer",
      company: "CMC Global",
      type: "Toàn thời gian", // Sửa Fulltime -> Toàn thời gian
      hourly: "2000",
      location: "Hà Nội",
      tags: ["HTML", "CSS", "Bootstrap"],
      daysAgo: "2 ngày trước",
      description: "Tìm kiếm chuyên viên thiết kế Web có kinh nghiệm cho công ty.", // Dịch mô tả
    },
    {
      id: 2,
      title: "Backend Developer",
      company: "CMC Global",
      type: "Toàn thời gian",
      hourly: "2500",
      location: "Hà Nội",
      tags: ["Java", "Spring Boot", "MySQL"],
      daysAgo: "5 ngày trước",
      description: "Cần tuyển lập trình viên Backend thành thạo Java Spring Boot.",
    },
  ];

  return (
    <MainLayout>
      
      {/* Company Info Card */}
      <div className="flex items-center gap-4 mt-[-120px] relative z-30 bg-white p-5 rounded-xl shadow-md max-w-5xl mx-auto">
        <img
          src={company.logo}
          alt="Logo công ty"
          className="w-16 h-16 rounded-md border border-gray-300 bg-white p-2"
        />
        <div>
          <h2 className="text-xl font-semibold text-gray-800">
            {company.name}
          </h2>
          <p className="text-gray-500">{company.location}</p>
        </div>
      </div>

      {/* Job Posts Section */}
      <div className="max-w-5xl mx-auto mt-10">
        <div className="flex justify-between items-center mb-6 bg-white p-5 rounded-xl shadow-md">
          {/* Sửa 'Job posts' thành 'Danh sách tin tuyển dụng' */}
          <h3 className="text-lg font-semibold text-gray-800">Danh sách tin tuyển dụng</h3>
          
          <div className="flex items-center gap-2 text-sm">
            <select
                defaultValue="all"
                className="border border-gray-300 rounded-sm px-2 py-2 text-gray-700 focus:outline-none"
            >
                <option value="all">Tất cả</option>
                <option value="active">Đang hiển thị</option>
                <option value="posted">Đã hết hạn</option>
                <option value="draft">Bản nháp</option>
            </select>

            {/* Sửa 'New post' thành 'Đăng tin mới' */}
            <button className="bg-sea-400 hover:bg-sea-300 text-white px-4 py-2 rounded-sm text-sm transition-colors whitespace-nowrap">
                Đăng tin mới
            </button>
            </div>
        </div>

        {/* Job list */}
        <div className="space-y-6">
          <JobList jobs={jobs} columns={1} />
        </div>

        {/* Load more div */}
        <div className="flex justify-center mt-8 pb-10">
          {/* Sửa 'Load more' thành 'Xem thêm' */}
          <button className="bg-sea-400 hover:bg-sea-300 text-white px-4 py-2 rounded-sm text-sm transition-colors">
            Xem thêm
          </button>
        </div>
      </div>
    </MainLayout>
  );
}

export default CompanyPosts;
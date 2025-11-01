import MainLayout from "../layouts/MainLayout";
import JobList from "../components/JobList";
import { AiOutlineReload } from "react-icons/ai";

function CompanyPosts() {
  const company = {
    name: "CMC Global",
    location: "London, UK",
    banner: "/images/banner.jpg", // ảnh banner nền
    logo: "/images/cmc.png", // logo công ty
  };

  const jobs = [
    {
      id: 1,
      title: "UI - UX Designer",
      company: "CMC Global",
      type: "Fulltime",
      hourly: "2000",
      location: "",
      tags: ["HTML", "CSS", "Bootstrap"],
      daysAgo: "",
      description: "Looking for an experienced Web Designer for our company.",
    },
    {
      id: 2,
      title: "UI - UX Designer",
      company: "CMC Global",
      type: "Fulltime",
      hourly: "2000",
      location: "",
      tags: ["HTML", "CSS", "Bootstrap"],
      daysAgo: "",
      description: "Looking for an experienced Web Designer for our company.",
    },
  ];

  return (
    <MainLayout>
      

      {/* Company Info Card */}
      <div className="flex items-center gap-4 mt-[-120px] relative z-30 bg-white p-5 rounded-xl shadow-md">
        <img
          src={company.logo}
          alt="Company logo"
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
      <div className=" mx-auto mt-10">
        <div className="flex justify-between items-center mb-4 bg-white p-5 rounded-xl shadow-md mb-6">
          <h3 className="text-lg font-semibold text-gray-800">Job posts</h3>
          <div className="flex items-center gap-2 text-sm">
            <select
                defaultValue="all"
                className="border border-gray-300 rounded-sm px-2 py-2 text-gray-700 
                        focus:outline-none"
            >
                <option value="all">Tất cả</option>
                <option value="active">Đang đăng</option>
                <option value="posted">Đã đăng</option>
                <option value="draft">Chưa đăng</option>
            </select>

            <button className="bg-sea-400 hover:bg-sea-300 text-white px-4 py-2 rounded-sm text-sm transition-colors">
                New post
            </button>
            </div>
        </div>

        {/* Job list */}
        <div className="space-y-6">
          <JobList jobs={jobs} columns={1} />
        </div>

        {/* Load more div */}
        <div className="flex justify-center mt-8">
          <div className="bg-sea-400 hover:bg-sea-300 text-white px-4 py-2 rounded-sm text-sm transition-colors">
            Load more
          </div>
        </div>
      </div>
    </MainLayout>
  );
}

export default CompanyPosts;

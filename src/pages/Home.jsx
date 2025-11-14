import SearchBar from "../components/SearchBar";
import JobFilters from "../components/JobFilters";
import JobList from "../components/JobList";
import MainLayout from "../layouts/MainLayout";
import { useEffect, useState } from "react";
import { jobService} from "../services";

function Home() {
    const [jobs, setJobs] = useState([]);

    useEffect(() => {
      async function fetchJobs() {
        try {
          const data  = await jobService.getAllJobs();
          setJobs(data.result || data); // tuỳ theo cấu trúc trả về của API
        } catch (err) {
          console.error("Lỗi khi lấy danh sách job:", err);
          setJobs([]); // Đặt mảng rỗng nếu có lỗi
        }
      }
      fetchJobs();
    }, []);
    console.log(jobs);
  return (
    <MainLayout showBanner={true}>
      {/* SearchBar floating */}
      <div className="relative -mt-24 z-20">
        <SearchBar />
      </div>

      {/* Main content: 12 column grid */}
      <div className="grid grid-cols-12 gap-6 mt-10">
        {/* Left Filter */}
        <aside className="col-span-12 md:col-span-3 md:sticky md:top-24 h-max">
          <JobFilters />
        </aside>

        {/* Right Job Listings */}
        <main className="col-span-12 md:col-span-9">
          <JobList jobs={jobs} columns={2} />
        </main>
      </div>
    </MainLayout>
  );
}

export default Home;
// const jobs = [
//   {
//     id: 1,
//     title: "UI - UX Designer",
//     company: "CMC Global",
//     type: "Fulltime",
//     hourly: "2000",
//     location: "",
//     tags: ["HTML", "CSS", "Bootstrap"],
//     daysAgo: "",
//     description: "Looking for an Web Designer for our company.",
//   },
//   {
//     id: 2,
//     title: "UI - UX Designer",
//     company: "CMC Global",
//     type: "Fulltime",
//     hourly: "2000",
//     location: "",
//     tags: ["HTML", "CSS", "Bootstrap"],
//     daysAgo: "",
//     description: "Looking for an Web Designer for our company.",
//   },
//   {
//     id: 3,
//     title: "UI - UX Designer",
//     company: "CMC Global",
//     type: "Fulltime",
//     hourly: "2000",
//     location: "",
//     tags: ["HTML", "CSS", "Bootstrap"],
//     daysAgo: "",
//     description: "Looking for an Web Designer for our company.",
//   },
//   {
//     id: 4,
//     title: "UI - UX Designer",
//     company: "CMC Global",
//     type: "Fulltime",
//     hourly: "2000",
//     location: "",
//     tags: ["HTML", "CSS", "Bootstrap"],
//     daysAgo: "",
//     description: "Looking for an Web Designer for our company.",
//   },
//   {
//     id: 5,
//     title: "UI - UX Designer",
//     company: "CMC Global",
//     type: "Fulltime",
//     hourly: "2000",
//     location: "",
//     tags: ["HTML", "CSS", "Bootstrap"],
//     daysAgo: "",
//     description: "Looking for an Web Designer for our company.",
//   },
//   {
//     id: 6,
//     title: "UI - UX Designer",
//     company: "CMC Global",
//     type: "Fulltime",
//     hourly: "2000",
//     location: "",
//     tags: ["HTML", "CSS", "Bootstrap"],
//     daysAgo: "",
//     description: "Looking for an Web Designer for our company.",
//   },
//   {
//     id: 7,
//     title: "UI - UX Designer",
//     company: "CMC Global",
//     type: "Fulltime",
//     hourly: "2000",
//     location: "",
//     tags: ["HTML", "CSS", "Bootstrap"],
//     daysAgo: "",
//     description: "Looking for an Web Designer for our company.",
//   },
//   {
//     id: 8,
//     title: "UI - UX Designer",
//     company: "CMC Global",
//     type: "Fulltime",
//     hourly: "2000",
//     location: "",
//     tags: ["HTML", "CSS", "Bootstrap"],
//     daysAgo: "",
//     description: "Looking for an Web Designer for our company.",
//   },
// ];
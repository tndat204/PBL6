import MainLayout from "../layouts/MainLayout";
import JobList from "../components/JobList";
import ReviewList from "../components/ReviewList";
import { AiFillTwitterCircle, AiFillFacebook, AiFillInstagram } from "react-icons/ai";

function CompanyProfile() {
  const company = {
    name: "CMC Global",
    location: "London, UK",
    founded: "2020",
    headquarters: "London, UK",
    employees: "300",
    website: "cmc.com",
    story: `It is a long established fact that a reader will be distracted by the readable content of a page when looking at its layout. 
    The point of using Lorem Ipsum is that it has a more-or-less normal distribution of letters, as opposed. 
    Contrary to popular belief, Lorem Ipsum is not simply random text. 
    It has roots in a piece of classical Latin literature from 45 BC, making it over 2000 years old. 
    Richard McClintock, a Latin professor at Hampden-Sydney College in Virginia, looked up one of the more obscure Latin words, consectetur, from a Lorem Ipsum passage.`,
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
      description: "Looking for an Web Designer for our company.",
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
      description: "Looking for an Web Designer for our company.",
    }
  ];
  const reviews = [
      {
        id: 1,
        name: "Trần Nguyên Đạt",
        rating: 5,
        content: "Công ty có môi trường làm việc tốt, nhiều quyền lợi cho nhân viên.",
        dateTime: "20:15 28/09/2025",
      },
      {
        id: 2,
        name: "Trần Nguyên Đạt",
        rating: 5,
        content: "Công ty có môi trường làm việc tốt, nhiều quyền lợi cho nhân viên.",
        dateTime: "20:15 28/09/2025",
      },
    ];
  return (
    <MainLayout showBanner={true}>
      {/* Header info */}
      <div className="flex items-center gap-4 mt-[-120px] relative z-30 bg-white p-5 rounded-xl shadow-md">
        <img
          src="/images/cmc.png"
          alt="Company logo"
          className="w-20 h-20 rounded-md border border-gray-300 bg-white p-2"
        />
        <div>
          <h2 className="text-2xl font-semibold text-gray-800">{company.name}</h2>
          <p className="text-gray-500">{company.location}</p>
        </div>
      </div>
      <div className="flex flex-col lg:flex-row gap-8 z-20 mt-10">
        {/* Left main content */}
        
        <div className="flex-1">
          {/* Company Story */}
          <div>
            <h3 className="text-xl font-semibold text-gray-800 mb-4">Company Story</h3>
            <p className="text-gray-600 leading-relaxed whitespace-pre-line">
              {company.story}
            </p>
          </div>

          {/* Job posts */}
          <div className="mt-10">
            <h3 className="text-xl font-semibold text-gray-800 mb-4">Job posts</h3>
            <div className="grid gap-6">
              <JobList jobs={jobs} columns={1} />
            </div>
          </div>
          {/* Comments section */}
          <div className="mt-10">
            <h3 className="text-xl font-semibold text-gray-800 mb-4">Comments</h3>
            
            <div className="grid gap-6">
              <ReviewList items={reviews} columns={1} />
            </div>
          </div>
        </div>

        {/* Right Sidebar */}
        <div className="w-full lg:w-1/3 bg-gray-50 p-5 rounded-xl shadow-sm lg:sticky lg:top-20 h-fit self-start">
          <h3 className="text-lg font-semibold text-gray-800 mb-4">Our company</h3>
          <ul className="text-sm text-gray-600 space-y-2">
            <li className="flex justify-between border-b border-gray-200 pb-2">
              <span>Founded:</span>
              <span className="font-medium text-gray-800">{company.founded}</span>
            </li>
            <li className="flex justify-between border-b border-gray-200 pb-2">
              <span>Headquarters:</span>
              <span className="font-medium text-gray-800">{company.headquarters}</span>
            </li>
            <li className="flex justify-between border-b border-gray-200 pb-2">
              <span>Number of employees:</span>
              <span className="font-medium text-gray-800">{company.employees}</span>
            </li>
            <li className="flex justify-between border-b border-gray-200 pb-2">
              <span>Website:</span>
              <a
                href={`https://${company.website}`}
                className="font-medium text-sea-400 hover:underline"
              >
                {company.website}
              </a>
            </li>
          </ul>

          {/* Social links */}
          <div className="mt-5">
            <h4 className="text-gray-600 font-semibold text-sm mb-2">Social</h4>
            <div className="flex gap-3 text-xl text-gray-500">
              <a href="https://twitter.com" target="_blank" rel="noopener noreferrer">
                <AiFillTwitterCircle className="hover:text-sea-400 transition" />
              </a>
              <a href="https://facebook.com" target="_blank" rel="noopener noreferrer">
                <AiFillFacebook className="hover:text-sea-400 transition" />
              </a>
              <a href="https://instagram.com" target="_blank" rel="noopener noreferrer">
                <AiFillInstagram className="hover:text-sea-400 transition" />
              </a>
            </div>
          </div>
        </div>
      </div>
    </MainLayout>
  );
}

export default CompanyProfile;

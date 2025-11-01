import MainLayout from "../layouts/MainLayout";

import employeeIcon from "../assets/images/employee-type-icon.png";
import locationIcon from "../assets/images/location-icon.png";
import jobIcon from "../assets/images/job-type-icon.png";
import experienceIcon from "../assets/images/experience-icon.png";
import salaryIcon from "../assets/images/salary-icon.png";
import JobCard from "../components/JobCard";
import { useNavigate } from "react-router-dom";
const jobs = [
  {
    title: "UI - UX Designer",
    company: "CMC Global",
    type: "Fulltime",
    description: "Looking for an experienced Web Designer for our company.",
    tags: ["HTML", "CSS", "Bootstrap"],
    hourly: 2000,
  },
  {
    title: "Frontend Developer",
    company: "CMC Global",
    type: "Fulltime",
    description: "Join our frontend team to build scalable web apps.",
    tags: ["React", "Tailwind", "REST API"],
    hourly: 1800,
  },
  {
    title: "Backend Developer",
    company: "CMC Global",
    type: "Part-time",
    description: "Develop and maintain backend services with Node.js.",
    tags: ["Node.js", "Express", "MongoDB"],
    hourly: 1500,
  },
  {
    title: "Product Designer",
    company: "CMC Global",
    type: "Fulltime",
    description: "Design intuitive products for millions of users.",
    tags: ["Figma", "UI/UX", "Prototyping"],
    hourly: 2200,
  },
];
function JobDetails() {
  const navigate = useNavigate();
  return (
    <MainLayout showBanner={true}>
      <div className="max-w-7xl mx-auto py-10 grid grid-cols-1 md:grid-cols-4 gap-6">
        {/* Cột trái chiếm 1/4 */}
        <div className="md:col-span-1 space-y-6">
          {/* Job Information box */}
          <div className="bg-white rounded-lg shadow p-5">
            <h2 className="text-xl font-semibold mb-4">Job Information</h2>
            <ul className="space-y-3">
              <li className="flex items-center">
                <img src={employeeIcon} alt="Employee Type" className="w-5 h-5 mr-3" />
                <div>
                  <span className="block text-gray-500 text-md font-semibold">Employee Type</span>
                  <span className="text-sea-400 text-sm">Fulltime</span>
                </div>
              </li>

              <li className="flex items-center">
                <img src={locationIcon} alt="Location" className="w-5 h-5 mr-3" />
                <div>
                  <span className="block text-gray-500 text-md font-semibold">Location</span>
                  <span className="text-sea-400 text-sm">Đà Nẵng, VN</span>
                </div>
              </li>

              <li className="flex items-center">
                <img src={jobIcon} alt="Job Type" className="w-5 h-5 mr-3" />
                <div>
                  <span className="block text-gray-500 text-md font-semibold">Job Type</span>
                  <span className="text-sea-400 text-sm">Fulltime</span>
                </div>
              </li>

              <li className="flex items-center">
                <img src={experienceIcon} alt="Experience" className="w-5 h-5 mr-3" />
                <div>
                  <span className="block text-gray-500 text-md font-semibold">Experience</span>
                  <span className="text-sea-400 text-sm">3 - 5 years</span>
                </div>
              </li>

              <li className="flex items-center">
                <img src={salaryIcon} alt="Salary" className="w-5 h-5 mr-3" />
                <div>
                  <span className="block text-gray-500 text-md font-semibold">Salary</span>
                  <span className="text-sea-400 text-sm">$1,000</span>
                </div>
              </li>
            </ul>
          </div>

          {/* About the company box */}
          <div className="bg-white rounded-lg shadow p-5">
            <h2 className="text-xl font-semibold mb-4">About the company</h2>
            <div className="flex items-center mb-3">
              <img
                src="/images/cmc.png"
                alt="Company logo"
                className="w-12 h-12 border border-gray-300 object-contain mr-3 rounded-full"
              />
              <div>
                <p className="font-semibold text-md">FPT Shop</p>
                <p className="text-sm text-sea-400">Đà Nẵng, VN</p>
              </div>
            </div>
            <p className="text-sm text-sea-400 mb-3">
              FPT Retail aims to become Vietnam’s leading multi-sector retail enterprise,
              pioneering in technology adoption and business model innovation to deliver exceptional
              shopping experiences.
            </p>
            <a href="/company-profile" className="text-blue-600 text-sm font-medium hover:underline">
              Learn more
            </a>
          </div>
        </div>

        {/* Cột phải chiếm 3/4 */}
        <div className="md:col-span-3 bg-white rounded-lg shadow p-8 pt-4">
          <h1 className="text-xl font-semibold mb-4">Job Description</h1>
          <p className="text-sea-400 mb-6 text-sm">
            One disadvantage of Lorem Ipsum is that in Latin certain letters appear more frequently
            than others - which creates a distinct visual impression...
          </p>

          <h2 className="text-lg font-semibold mb-3">Responsibilities and Duties</h2>
          <ul className="list-disc list-inside text-sm text-sea-400 space-y-1 mb-6">
            <li>Participate in requirements analysis</li>
            <li>Write clean, scalable code using C# and .NET frameworks</li>
            <li>Test and deploy applications and systems</li>
            <li>Revise, update, refactor and debug code</li>
            <li>Improve existing software</li>
            <li>Develop documentation throughout the software development life cycle (SDLC)</li>
            <li>Serve as an expert on applications and provide technical support</li>
          </ul>

          <h2 className="text-lg font-semibold mb-3">
            Required Experience, Skills and Qualifications
          </h2>
          <ul className="list-disc list-inside text-sm text-sea-400 space-y-1">
            <li>Proven experience as a .NET Developer or Application Developer</li>
            <li>Good understanding of SQL and Relational Databases</li>
            <li>Experience designing, developing and creating RESTful web services and APIs</li>
            <li>Basic knowledge of Agile processes and practices</li>
            <li>Good understanding of object-oriented programming</li>
            <li>Sound knowledge of application architecture and design</li>
            <li>Excellent problem solving and analytical skills</li>
          </ul>

          <button onClick={() => navigate('/apply-job')} className="mt-8 bg-sea-400 text-white font-semibold px-6 py-2 rounded-sm hover:bg-sea-300 transition">
            Apply
          </button>
        </div>
      </div>
      <section className="mt-12">
      <h2 className="text-center text-2xl font-semibold text-gray-800 mb-8">
        Related Jobs
      </h2>

      <div className="grid grid-cols-1 md:grid-cols-2 gap-6 max-w-7xl mx-auto">
        {jobs.map((job) => (
        <JobCard key={job.id} job={job} />
      ))}
      </div>
    </section>
    </MainLayout>
  );
}

export default JobDetails;

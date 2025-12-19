import { useEffect, useState } from "react";
import { TbPinned } from "react-icons/tb";
import SaveButton from "./SaveButton";
import { companyService, skillService } from "../services";
import { Link } from "react-router-dom";
const JobCard = ({ job }) => {
  const [companyName, setCompanyName] = useState("");
  const [skillNames, setSkillNames] = useState([]);
  useEffect(() => {
    const fetchJobDetails = async () => {
      try {
        // Fetch company name
        if (job.companyId) {
          const company = await companyService.getCompanyById(job.companyId); // ✅ Dùng service
          setCompanyName(company?.name || "Công ty không xác định");
        } else {
          setCompanyName("Công ty không xác định");
        }

        // Fetch skills
        if (job.skillIds?.length) {
          const skills = await skillService.getSkillsByIds(job.skillIds); // ✅ Dùng service
          setSkillNames(skills);
        } else {
          setSkillNames([]);
        }
      } catch (error) {
        console.error("Lỗi khi tải thông tin job:", error);
        setCompanyName("Lỗi tải dữ liệu");
        setSkillNames([]);
      }
    };

    fetchJobDetails();
  }, [job]);
  


  return (
    <div className="bg-white rounded-lg shadow-md p-2 flex flex-col justify-between h-full relative">
      <div className="bg-white rounded-lg shadow-md p-2 flex flex-col justify-between">
            <div className="flex items-start justify-between mb-2">
              <div className="flex items-center space-x-2">
                <div className="w-12 h-12 bg-[url('./assets/images/cmc.png')] bg-cover bg-center rounded flex items-center justify-center ">
                </div>
                <div>
                  <h3 className="text-lg font-semibold text-gray-800">{job.title}</h3>
                  <p className="text-sm text-gray-500">{companyName}</p>
                </div>
              </div>
              <div className="text-gray-400 hover:text-gray-600 focus:outline-none">
                <SaveButton />
              </div>
            </div>
            <div className="mb-2">
              <p className="text-sm text-gray-600 mb-1">{job.jobType}</p>
              <p className="text-gray-700 text-sm mb-2 truncate w-[250px]">{job.description}</p>
              <div className="flex flex-wrap gap-2 mb-2">
                {skillNames.map((name, idx) => (
                  <span
                    key={idx}
                    className="bg-gray-100 text-gray-600 px-2 py-1 rounded-full text-xs border border-gray-300"
                  >
                    {name}
                  </span>
                ))}
              </div>
            </div>
          </div>
          <div className="flex items-center justify-between mt-3">
              <span className="text-lg font-semibold text-gray-800">
                {job.salaryMin && job.salaryMax
                  ? `${job.salaryMin.toLocaleString()} - ${job.salaryMax.toLocaleString()} $`
                  : "1000$"}
              </span>
              <Link
                to={`/job-details/${job.id}`}
                className="bg-sea-400 hover:bg-sea-300 text-white px-4 py-2 rounded-sm text-sm transition-colors"
              >
                Chi tiết
              </Link>
            </div>
    </div>
    
  );
};

export default JobCard;
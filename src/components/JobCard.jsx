import { useEffect, useState } from "react";
import { TbPinned } from "react-icons/tb";
import SaveButton from "./SaveButton";

const JobCard = ({ job }) => {
  const [companyName, setCompanyName] = useState("");
  const [skillNames, setSkillNames] = useState([]);

  useEffect(() => {
    // Lấy tên công ty
    async function fetchCompany() {
      if (!job.companyId) {
        setCompanyName("Công ty không xác định");
        return;
      }

      try {
        const res = await fetch(`http://localhost:8080/api/companies/${job.companyId}`,{
          method: "GET",
           headers:{
              "Content-Type" : "application/json",
              "Authorization": `Bearer eyJhbGciOiJIUzUxMiJ9.eyJzdWIiOiJodXkyMDA0NEBleGFtcGxlLmNvbSIsInNjb3BlIjoiUk9MRV9VU0VSIiwiaXNzIjoiaXRqb2JodW50LmNvbSIsImV4cCI6MTc2MjM2MTk3MiwiaWF0IjoxNzYyMzU0NzcyLCJ1c2VySWQiOiIyZmE1YmMyYi0yNjY1LTRjNjUtYTYxNC1kYzU3ZjM1NDE1NjQiLCJqdGkiOiJiYThkZjk4Yy0wMjYzLTQ2NTMtYjE0Mi1jZDAzYWRlODI5NGQifQ.wRKyndepnOU1CSLUI4VNvmgVp-oLhAXhz8GEDjwiGMuTsMvnq5fhfV8Cz0-Zx5WQQvKdbvm86HddSarqUjnQWA`
            }
        });
        if (res.ok) {
          const data = await res.json();
          setCompanyName(data.result?.name || data.name || "Công ty không xác định");
        } else {
          setCompanyName("Công ty không xác định");
        }
      } catch (err) {
        console.log("Lỗi fetch company:", err);
        setCompanyName("Công ty không xác định");
      }
    }

    // Lấy tên kỹ năng thông qua từng ID
    async function fetchSkills() {
      if (!job.skillIds?.length) {
        setSkillNames([]);
        return;
      }

      try {
        const skillPromises = job.skillIds.map(async (skillId) => {
          try {
            const res = await fetch(`http://localhost:8080/api/skills/${skillId}`,{
              method: "GET",
              headers:{
                "Content-Type": "application/json",
                "Authorization": `Bearer eyJhbGciOiJIUzUxMiJ9.eyJzdWIiOiJodXkyMDA0NEBleGFtcGxlLmNvbSIsInNjb3BlIjoiUk9MRV9VU0VSIiwiaXNzIjoiaXRqb2JodW50LmNvbSIsImV4cCI6MTc2MjM2MTk3MiwiaWF0IjoxNzYyMzU0NzcyLCJ1c2VySWQiOiIyZmE1YmMyYi0yNjY1LTRjNjUtYTYxNC1kYzU3ZjM1NDE1NjQiLCJqdGkiOiJiYThkZjk4Yy0wMjYzLTQ2NTMtYjE0Mi1jZDAzYWRlODI5NGQifQ.wRKyndepnOU1CSLUI4VNvmgVp-oLhAXhz8GEDjwiGMuTsMvnq5fhfV8Cz0-Zx5WQQvKdbvm86HddSarqUjnQWA`
              }
            });
            if (res.ok) {
              const data = await res.json();
              return data.result?.name || data.name || skillId;
            }
            return skillId;
          } catch {
            return skillId; // Nếu lỗi thì trả về ID
          }
        });
        const names = await Promise.all(skillPromises);
        setSkillNames(names);
      } catch (err) {
        console.log("Lỗi fetch skills:", err);
        setSkillNames(job.skillIds || []);
      }
    }

    fetchCompany();
    fetchSkills();
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
              <a href={`http://localhost:3000/job-details`} className="bg-sea-400 hover:bg-sea-300 text-white px-4 py-2 rounded-sm text-sm transition-colors">
                Details
              </a>
            </div>
    </div>
    
  );
};

export default JobCard;
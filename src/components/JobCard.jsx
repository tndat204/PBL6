import { useEffect, useState } from "react";
import { Building2, Briefcase, DollarSign, MapPin } from "lucide-react";
import SaveButton from "./SaveButton";
import { companyService, skillService } from "../services";
import { Link } from "react-router-dom";

const JobCard = ({ job }) => {
  const [companyName, setCompanyName] = useState("");
  const [companyLogo, setCompanyLogo] = useState("");
  const [skillNames, setSkillNames] = useState([]);
  const [isLoading, setIsLoading] = useState(true);

  useEffect(() => {
    const fetchJobDetails = async () => {
      setIsLoading(true);
      try {
        // Fetch company details
        if (job.companyId) {
          const company = await companyService.getCompanyById(job.companyId);
          setCompanyName(company?.name || "Công ty không xác định");
          setCompanyLogo(company?.logoUrl || "");
        } else {
          setCompanyName("Công ty không xác định");
        }

        // Handle skills
        if (job.skills && Array.isArray(job.skills) && job.skills.length > 0) {
          // If skills are already populated
          if (typeof job.skills[0] === 'string') {
            setSkillNames(job.skills);
          } else if (typeof job.skills[0] === 'object' && job.skills[0].name) {
            setSkillNames(job.skills.map(s => s.name));
          }
        } else if (job.skillIds?.length) {
          // Fetch by IDs if needed
          const skills = await skillService.getSkillsByIds(job.skillIds);
          setSkillNames(skills);
        } else {
          setSkillNames([]);
        }
      } catch (error) {
        console.error("Lỗi khi tải thông tin job:", error);
        setCompanyName("Lỗi tải dữ liệu");
        setSkillNames([]);
      } finally {
        setIsLoading(false);
      }
    };

    fetchJobDetails();
  }, [job]);

  // Show skeleton loader while fetching data
  if (isLoading) {
    return (
      <div className="bg-white rounded-xl border border-gray-200 p-5 h-full">
        <div className="animate-pulse">
          <div className="flex items-start justify-between mb-4">
            <div className="flex gap-4 flex-1">
              <div className="w-14 h-14 bg-gray-200 rounded-xl"></div>
              <div className="flex-1">
                <div className="h-5 bg-gray-200 rounded w-3/4 mb-2"></div>
                <div className="h-4 bg-gray-200 rounded w-1/2"></div>
              </div>
            </div>
          </div>
          <div className="space-y-3">
            <div className="flex gap-2">
              <div className="h-7 bg-gray-200 rounded w-24"></div>
              <div className="h-7 bg-gray-200 rounded w-32"></div>
            </div>
            <div className="flex gap-2">
              <div className="h-6 bg-gray-200 rounded-full w-16"></div>
              <div className="h-6 bg-gray-200 rounded-full w-20"></div>
              <div className="h-6 bg-gray-200 rounded-full w-16"></div>
            </div>
            <div className="h-10 bg-gray-200 rounded"></div>
          </div>
          <div className="mt-4 pt-4 border-t border-gray-100">
            <div className="h-10 bg-gray-200 rounded-lg"></div>
          </div>
        </div>
      </div>
    );
  }


  return (
    <div className="group bg-white rounded-xl border border-gray-200 p-5 hover:shadow-xl transition-all duration-300 hover:-translate-y-1 flex flex-col h-full relative">
      {/* Header */}
      <div className="flex items-start justify-between mb-4">
        <div className="flex gap-4">
          <div className="w-14 h-14 rounded-xl border border-gray-100 bg-white p-2 shadow-sm flex items-center justify-center shrink-0 group-hover:border-blue-100 transition-colors">
            {companyLogo ? (
              <img src={companyLogo} alt={companyName} className="w-full h-full object-contain" />
            ) : (
              <Building2 className="text-gray-300" size={28} />
            )}
          </div>
          <div>
            <h3 className="font-bold text-gray-900 text-lg leading-tight line-clamp-2 group-hover:text-blue-600 transition-colors" title={job.title}>
              {job.title}
            </h3>
            <p className="text-sm text-gray-500 font-medium mt-1 line-clamp-1" title={companyName}>
              {companyName}
            </p>
          </div>
        </div>
        <div className="shrink-0">
          <SaveButton />
        </div>
      </div>

      {/* Tags / Meta */}
      <div className="space-y-3 mb-4 flex-1">
        <div className="flex flex-wrap gap-2 text-sm text-gray-600">
          <span className="flex items-center gap-1.5 bg-gray-50 px-2.5 py-1 rounded-md border border-gray-100">
            <Briefcase size={14} className="text-blue-500" />
            {job.jobType}
          </span>
          <span className="flex items-center gap-1.5 bg-gray-50 px-2.5 py-1 rounded-md border border-gray-100">
            <DollarSign size={14} className="text-green-500" />
            {job.salaryMin && job.salaryMax
              ? `${job.salaryMin.toLocaleString()} - ${job.salaryMax.toLocaleString()} $`
              : "Thỏa thuận"}
          </span>
        </div>

        <div className="flex flex-wrap gap-2 mt-3">
          {skillNames.slice(0, 3).map((name, idx) => (
            <span
              key={idx}
              className="bg-blue-50 text-blue-700 px-2.5 py-1 rounded-full text-xs font-medium border border-blue-100"
            >
              {name}
            </span>
          ))}
          {skillNames.length > 3 && (
            <span className="bg-gray-50 text-gray-500 px-2 py-1 rounded-full text-xs font-medium border border-gray-100">
              +{skillNames.length - 3}
            </span>
          )}
        </div>

        <p className="text-gray-500 text-sm line-clamp-2 mt-2">
          {job.description}
        </p>
      </div>

      {/* Footer */}
      <div className="pt-4 border-t border-gray-100 mt-auto">
        <Link
          to={`/job-details/${job.id}`}
          className="block w-full text-center bg-gradient-to-r from-emerald-500 to-teal-600 hover:from-emerald-600 hover:to-teal-700 text-white py-2.5 rounded-lg text-sm font-semibold shadow-sm hover:shadow-md transition-all active:scale-[0.98]"
        >
          Xem chi tiết
        </Link>
      </div>
    </div>
  );
};

export default JobCard;
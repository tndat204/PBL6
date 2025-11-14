import FormLayout from "../layouts/FormLayout";
import { useState, useEffect } from "react";
import { categoryService, skillService, jobService } from "../services";

function JobPost() {
  const [category, setCategory] = useState([]);
  const [selectedCategory, setSelectedCategory] = useState("");
  const [availableSkills, setAvailableSkills] = useState([]);
  const [skills, setSkills] = useState([]);

  // Lấy category
  useEffect(() => {
    async function fetchCategories() {
      try {
        const data = await categoryService.getAllCategories();
        setCategory(data.result || data);
      } catch (err) {
        console.error("Lỗi khi lấy danh sách category:", err);
        setCategory([]);
      }
    }
    fetchCategories();
  }, []);

  // Lấy skill theo category
  useEffect(() => {
    async function fetchSkills() {
      if (selectedCategory) {
        try {
          const skillsData = await skillService.getSkillsByCategory(
            selectedCategory
          );
          setAvailableSkills(skillsData || []);
        } catch (err) {
          console.error("Lỗi khi lấy danh sách skills:", err);
          setAvailableSkills([]);
        }
      } else {
        setAvailableSkills([]);
      }
      setSkills([]);
    }
    fetchSkills();
  }, [selectedCategory]);

  const handleCategoryChange = (e) => {
    setSelectedCategory(e.target.value);
  };

  const handleAddSkill = (e) => {
    const value = e.target.value;
    if (!value) return;

    if (!skills.some((skill) => String(skill.id) === value)) {
      const selectedSkillObj = availableSkills.find(
        (skill) => String(skill.id) === value
      );
      if (selectedSkillObj) {
        setSkills((prev) => [...prev, selectedSkillObj]);
      }
    }

    e.target.value = "";
  };

  const handleRemoveSkill = (skillId) => {
    setSkills((prev) => prev.filter((s) => s.id !== skillId));
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    const formData = new FormData(e.target);

    const jobData = {
      companyId: "9185c582-c922-4010-aae1-4fc1d549dc05",
      title: formData.get("title") || "",
      description: formData.get("description") || "",
      status: "ACTIVE",
      categoryIds: [selectedCategory],
      jobType: formData.get("jobType") || "",
      salaryMin: Number(formData.get("salaryMin") || 0),
      salaryMax: Number(formData.get("salaryMax") || 0),
      skillIds: skills.map((s) => s.id),
      experience: formData.get("experience") || "",
      location: formData.get("location") || "",
      expiryDate: formData.get("expiryDate") || null,
    };

    // ===== VALIDATE =====
    if (!jobData.title.trim())
      return alert("Tiêu đề công việc không được để trống");
    if (!jobData.description.trim())
      return alert("Mô tả công việc không được để trống");
    if (!jobData.categoryIds)
      return alert("Bạn phải chọn ngành nghề");
    if (!jobData.jobType)
      return alert("Bạn phải chọn loại hình công việc");

    if (jobData.salaryMin <= 0 || jobData.salaryMax <= 0)
      return alert("Lương phải lớn hơn 0");

    if (jobData.salaryMin > jobData.salaryMax)
      return alert("Lương tối đa phải lớn hơn lương tối thiểu");

    if (jobData.skillIds.length === 0)
      return alert("Bạn phải chọn ít nhất 1 kỹ năng");
    if (jobData.skillIds.length === 0) {
      console.log(jobData.skillIds);
    }
    if (!jobData.experience.trim())
      return alert("Kinh nghiệm không được để trống");

    if (!jobData.location.trim())
      return alert("Địa điểm làm việc không được để trống");
    if (!jobData.expiryDate)
      return alert("Hạn nộp hồ sơ không được để trống");

    const today = new Date().toISOString().split("T")[0];

    if (jobData.expiryDate && jobData.expiryDate < today) {
      return alert("Hạn nộp hồ sơ phải lớn hơn hoặc bằng ngày hôm nay");
    }

    // ======================

    try {
      console.log("Gửi đi:", jobData);
      await jobService.createJob(jobData);
      alert("Đăng tin tuyển dụng thành công!");
      e.target.reset();
      setSelectedCategory("");
      setSkills([]);
      setAvailableSkills([]);
    } catch (err) {
      console.error(err);
      alert("Đăng tin tuyển dụng thất bại!");
    }
  };

  return (
    <FormLayout>
      <h1 className="text-2xl font-bold mb-6 text-center text-gray-700">
        Chi tiết công việc
      </h1>
      <form className="space-y-4" onSubmit={handleSubmit}>
        {/* Job Title */}
        <div>
          <label className="block text-md font-medium mb-1 text-gray-700">
            Tiêu đề công việc:
          </label>
          <input
            type="text"
            name="title"
            placeholder="Tiêu đề công việc (VD: UI/UX Designer)"
            className="w-full border border-gray-300 rounded px-3 py-2"
          />
        </div>

        {/* Job Description */}
        <div>
          <label className="block text-md font-medium mb-1 text-gray-700">
            Mô tả công việc:
          </label>
          <textarea
            name="description"
            placeholder="Mô tả chi tiết công việc"
            rows={3}
            className="w-full border border-gray-300 rounded px-3 py-2"
          ></textarea>
        </div>

        {/* Category + job type */}
        <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
          <div>
            <label className="block text-md font-medium mb-1 text-gray-700">
              Ngành nghề:
            </label>
            <select
              value={selectedCategory}
              onChange={handleCategoryChange}
              className="w-full border border-gray-300 rounded px-3 py-2"
            >
              <option value="">Chọn ngành nghề</option>
              {category.map((categoryItem) => (
                <option key={categoryItem.id} value={categoryItem.id}>
                  {categoryItem.name}
                </option>
              ))}
            </select>
          </div>

          <div>
            <label className="block text-md font-medium mb-1 text-gray-700">
              Loại hình công việc:
            </label>
            <select
              name="jobType"
              className="w-full border border-gray-300 rounded px-3 py-2"
            >
              <option value="FULLTIME">Toàn thời gian</option>
              <option value="PART_TIME">Bán thời gian</option>
              <option value="FREELANCE">Freelance</option>
            </select>
          </div>
        </div>

        {/* Salary */}
        <div>
          <label className="block text-md font-medium mb-1 text-gray-700">
            Mức lương
          </label>
          <div className="grid grid-cols-2 gap-3">
            <input
              type="number"
              name="salaryMin"
              placeholder="Lương tối thiểu"
              className="border border-gray-300 rounded px-3 py-2"
            />
            <input
              type="number"
              name="salaryMax"
              placeholder="Lương tối đa"
              className="border border-gray-300 rounded px-3 py-2"
            />
          </div>
        </div>

        {/* Skill selector */}
        <div>
          <label className="block text-md font-medium mb-1 text-gray-700">
            Kỹ năng:
          </label>
          <select
            onChange={handleAddSkill}
            defaultValue=""
            disabled={!selectedCategory || availableSkills.length === 0}
            className="w-full border border-gray-300 rounded px-3 py-2"
          >
            <option value="" disabled>
              {!selectedCategory
                ? "Vui lòng chọn ngành nghề trước"
                : availableSkills.length === 0
                ? "Không có kỹ năng nào"
                : "Chọn kỹ năng"}
            </option>

            {availableSkills.map((skill) => (
              <option key={skill.id} value={skill.id}>
                {skill.name}
              </option>
            ))}
          </select>

          {/* Skill tags */}
          <div className="flex flex-wrap gap-2 mt-2">
            {skills.map((skill) => (
              <div
                key={skill.id}
                className="px-3 py-1 bg-gray-200 rounded-full flex items-center gap-2"
              >
                <span>{skill.name}</span>
                <button
                  type="button"
                  onClick={() => handleRemoveSkill(skill.id)}
                  className="text-red-500"
                >
                  ✕
                </button>
              </div>
            ))}
          </div>
        </div>

        {/* Experience */}
        <div>
          <label className="block text-md font-medium mb-1 text-gray-700">
            Kinh nghiệm:
          </label>
          <input
            type="text"
            name="experience"
            placeholder="Yêu cầu kinh nghiệm"
            className="w-full border border-gray-300 rounded px-3 py-2"
          />
        </div>

        {/* Location */}
        <div>
          <label className="block text-md font-medium mb-1 text-gray-700">
            Địa điểm làm việc:
          </label>
          <input
            type="text"
            name="location"
            placeholder="Địa điểm (VD: Hà Nội, TP.HCM)"
            className="w-full border border-gray-300 rounded px-3 py-2"
          />
        </div>

        {/* Expiry Date */}
        <div>
          <label className="block text-md font-medium mb-1 text-gray-700">
            Hạn nộp hồ sơ:
          </label>
          <input
            type="date"
            name="expiryDate"
            className="w-full border border-gray-300 rounded px-3 py-2"
          />
        </div>

        {/* Submit */}
        <div>
          <button
            type="submit"
            className="bg-sea-400 text-white px-6 py-2 rounded hover:bg-sea-300 w-full md:w-auto"
          >
            Đăng tin
          </button>
        </div>
      </form>
    </FormLayout>
  );
}

export default JobPost;

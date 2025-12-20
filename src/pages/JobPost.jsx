// import FormLayout from "../layouts/FormLayout";
// import { useState, useEffect } from "react";
// import { categoryService, skillService, jobService } from "../services";

// function JobPost() {
//   const [category, setCategory] = useState([]);
//   const [selectedCategory, setSelectedCategory] = useState("");
//   const [availableSkills, setAvailableSkills] = useState([]);
//   const [skills, setSkills] = useState([]);

//   // Lấy category
//   useEffect(() => {
//     async function fetchCategories() {
//       try {
//         const data = await categoryService.getAllCategories();
//         setCategory(data.result || data);
//       } catch (err) {
//         console.error("Lỗi khi lấy danh sách category:", err);
//         setCategory([]);
//       }
//     }
//     fetchCategories();
//   }, []);

//   // Lấy skill theo category
//   useEffect(() => {
//     async function fetchSkills() {
//       if (selectedCategory) {
//         try {
//           const skillsData = await skillService.getSkillsByCategory(
//             selectedCategory
//           );
//           setAvailableSkills(skillsData || []);
//         } catch (err) {
//           console.error("Lỗi khi lấy danh sách skills:", err);
//           setAvailableSkills([]);
//         }
//       } else {
//         setAvailableSkills([]);
//       }
//       setSkills([]);
//     }
//     fetchSkills();
//   }, [selectedCategory]);

//   const handleCategoryChange = (e) => {
//     setSelectedCategory(e.target.value);
//   };

//   const handleAddSkill = (e) => {
//     const value = e.target.value;
//     if (!value) return;

//     if (!skills.some((skill) => String(skill.id) === value)) {
//       const selectedSkillObj = availableSkills.find(
//         (skill) => String(skill.id) === value
//       );
//       if (selectedSkillObj) {
//         setSkills((prev) => [...prev, selectedSkillObj]);
//       }
//     }

//     e.target.value = "";
//   };

//   const handleRemoveSkill = (skillId) => {
//     setSkills((prev) => prev.filter((s) => s.id !== skillId));
//   };

//   const handleSubmit = async (e) => {
//     e.preventDefault();
//     const formData = new FormData(e.target);

//     const jobData = {
//       companyId: "9185c582-c922-4010-aae1-4fc1d549dc05",
//       title: formData.get("title") || "",
//       description: formData.get("description") || "",
//       status: "ACTIVE",
//       categoryIds: [selectedCategory],
//       jobType: formData.get("jobType") || "",
//       salaryMin: Number(formData.get("salaryMin") || 0),
//       salaryMax: Number(formData.get("salaryMax") || 0),
//       skillIds: skills.map((s) => s.id),
//       experience: formData.get("experience") || "",
//       location: formData.get("location") || "",
//       expiryDate: formData.get("expiryDate") || null,
//     };

//     // ===== VALIDATE =====
//     if (!jobData.title.trim())
//       return alert("Tiêu đề công việc không được để trống");
//     if (!jobData.description.trim())
//       return alert("Mô tả công việc không được để trống");
//     if (!jobData.categoryIds)
//       return alert("Bạn phải chọn ngành nghề");
//     if (!jobData.jobType)
//       return alert("Bạn phải chọn loại hình công việc");

//     if (jobData.salaryMin <= 0 || jobData.salaryMax <= 0)
//       return alert("Lương phải lớn hơn 0");

//     if (jobData.salaryMin > jobData.salaryMax)
//       return alert("Lương tối đa phải lớn hơn lương tối thiểu");

//     if (jobData.skillIds.length === 0)
//       return alert("Bạn phải chọn ít nhất 1 kỹ năng");
//     if (jobData.skillIds.length === 0) {
//       console.log(jobData.skillIds);
//     }
//     if (!jobData.experience.trim())
//       return alert("Kinh nghiệm không được để trống");

//     if (!jobData.location.trim())
//       return alert("Địa điểm làm việc không được để trống");
//     if (!jobData.expiryDate)
//       return alert("Hạn nộp hồ sơ không được để trống");

//     const today = new Date().toISOString().split("T")[0];

//     if (jobData.expiryDate && jobData.expiryDate < today) {
//       return alert("Hạn nộp hồ sơ phải lớn hơn hoặc bằng ngày hôm nay");
//     }

//     // ======================

//     try {
//       console.log("Gửi đi:", jobData);
//       await jobService.createJob(jobData);
//       alert("Đăng tin tuyển dụng thành công!");
//       e.target.reset();
//       setSelectedCategory("");
//       setSkills([]);
//       setAvailableSkills([]);
//     } catch (err) {
//       console.error(err);
//       alert("Đăng tin tuyển dụng thất bại!");
//     }
//   };

//   return (
//     <FormLayout>
//       <h1 className="text-2xl font-bold mb-6 text-center text-gray-700">
//         Chi tiết công việc
//       </h1>
//       <form className="space-y-4" onSubmit={handleSubmit}>
//         {/* Job Title */}
//         <div>
//           <label className="block text-md font-medium mb-1 text-gray-700">
//             Tiêu đề công việc:
//           </label>
//           <input
//             type="text"
//             name="title"
//             placeholder="Tiêu đề công việc (VD: UI/UX Designer)"
//             className="w-full border border-gray-300 rounded px-3 py-2"
//           />
//         </div>

//         {/* Job Description */}
//         <div>
//           <label className="block text-md font-medium mb-1 text-gray-700">
//             Mô tả công việc:
//           </label>
//           <textarea
//             name="description"
//             placeholder="Mô tả chi tiết công việc"
//             rows={3}
//             className="w-full border border-gray-300 rounded px-3 py-2"
//           ></textarea>
//         </div>

//         {/* Category + job type */}
//         <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
//           <div>
//             <label className="block text-md font-medium mb-1 text-gray-700">
//               Ngành nghề:
//             </label>
//             <select
//               value={selectedCategory}
//               onChange={handleCategoryChange}
//               className="w-full border border-gray-300 rounded px-3 py-2"
//             >
//               <option value="">Chọn ngành nghề</option>
//               {category.map((categoryItem) => (
//                 <option key={categoryItem.id} value={categoryItem.id}>
//                   {categoryItem.name}
//                 </option>
//               ))}
//             </select>
//           </div>

//           <div>
//             <label className="block text-md font-medium mb-1 text-gray-700">
//               Loại hình công việc:
//             </label>
//             <select
//               name="jobType"
//               className="w-full border border-gray-300 rounded px-3 py-2"
//             >
//               <option value="FULLTIME">Toàn thời gian</option>
//               <option value="PART_TIME">Bán thời gian</option>
//               <option value="FREELANCE">Freelance</option>
//             </select>
//           </div>
//         </div>

//         {/* Salary */}
//         <div>
//           <label className="block text-md font-medium mb-1 text-gray-700">
//             Mức lương
//           </label>
//           <div className="grid grid-cols-2 gap-3">
//             <input
//               type="number"
//               name="salaryMin"
//               placeholder="Lương tối thiểu"
//               className="border border-gray-300 rounded px-3 py-2"
//             />
//             <input
//               type="number"
//               name="salaryMax"
//               placeholder="Lương tối đa"
//               className="border border-gray-300 rounded px-3 py-2"
//             />
//           </div>
//         </div>

//         {/* Skill selector */}
//         <div>
//           <label className="block text-md font-medium mb-1 text-gray-700">
//             Kỹ năng:
//           </label>
//           <select
//             onChange={handleAddSkill}
//             defaultValue=""
//             disabled={!selectedCategory || availableSkills.length === 0}
//             className="w-full border border-gray-300 rounded px-3 py-2"
//           >
//             <option value="" disabled>
//               {!selectedCategory
//                 ? "Vui lòng chọn ngành nghề trước"
//                 : availableSkills.length === 0
//                 ? "Không có kỹ năng nào"
//                 : "Chọn kỹ năng"}
//             </option>

//             {availableSkills.map((skill) => (
//               <option key={skill.id} value={skill.id}>
//                 {skill.name}
//               </option>
//             ))}
//           </select>

//           {/* Skill tags */}
//           <div className="flex flex-wrap gap-2 mt-2">
//             {skills.map((skill) => (
//               <div
//                 key={skill.id}
//                 className="px-3 py-1 bg-gray-200 rounded-full flex items-center gap-2"
//               >
//                 <span>{skill.name}</span>
//                 <button
//                   type="button"
//                   onClick={() => handleRemoveSkill(skill.id)}
//                   className="text-red-500"
//                 >
//                   ✕
//                 </button>
//               </div>
//             ))}
//           </div>
//         </div>

//         {/* Experience */}
//         <div>
//           <label className="block text-md font-medium mb-1 text-gray-700">
//             Kinh nghiệm:
//           </label>
//           <input
//             type="text"
//             name="experience"
//             placeholder="Yêu cầu kinh nghiệm"
//             className="w-full border border-gray-300 rounded px-3 py-2"
//           />
//         </div>

//         {/* Location */}
//         <div>
//           <label className="block text-md font-medium mb-1 text-gray-700">
//             Địa điểm làm việc:
//           </label>
//           <input
//             type="text"
//             name="location"
//             placeholder="Địa điểm (VD: Hà Nội, TP.HCM)"
//             className="w-full border border-gray-300 rounded px-3 py-2"
//           />
//         </div>

//         {/* Expiry Date */}
//         <div>
//           <label className="block text-md font-medium mb-1 text-gray-700">
//             Hạn nộp hồ sơ:
//           </label>
//           <input
//             type="date"
//             name="expiryDate"
//             className="w-full border border-gray-300 rounded px-3 py-2"
//           />
//         </div>

//         {/* Submit */}
//         <div>
//           <button
//             type="submit"
//             className="bg-sea-400 text-white px-6 py-2 rounded hover:bg-sea-300 w-full md:w-auto"
//           >
//             Đăng tin
//           </button>
//         </div>
//       </form>
//     </FormLayout>
//   );
// }

// export default JobPost;


import FormLayout from "../layouts/FormLayout";
import { useState, useEffect } from "react";
import { categoryService, skillService, jobService } from "../services";

import { useAuth } from "../hooks/useAuth";

function JobPost() {
  const { company } = useAuth();
  const [category, setCategory] = useState([]);
  const [selectedCategories, setSelectedCategories] = useState([]); // Array
  const [availableSkills, setAvailableSkills] = useState([]); // All skills
  const [skills, setSkills] = useState([]); // Selected skills

  // Location State
  const [locationParts, setLocationParts] = useState({
    province: "",
    ward: "",
    detail: ""
  });
  const [provinces, setProvinces] = useState([]);
  const [wards, setWards] = useState([]);

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

  // Lấy tất cả skill
  useEffect(() => {
    async function fetchAllSkills() {
        try {
          const skillsData = await skillService.getAllSkills();
          setAvailableSkills(skillsData || []);
        } catch (err) {
          console.error("Lỗi khi lấy danh sách skills:", err);
          setAvailableSkills([]);
        }
    }
    fetchAllSkills();
  }, []);

  // Fetch Provinces for location
  useEffect(() => {
    const fetchProvinces = async () => {
      try {
        const response = await fetch("https://vietnamlabs.com/api/vietnamprovince");
        const data = await response.json();
        if (data.success && data.data) {
          setProvinces(data.data);
        }
      } catch (error) {
        console.error("Lỗi lấy danh sách tỉnh thành:", error);
      }
    };
    fetchProvinces();
  }, []);

  // Handle Province Change for location
  const handleLocationProvinceChange = async (e) => {
    const provinceName = e.target.value;
    
    setLocationParts(prev => ({
        ...prev,
        province: provinceName,
        ward: ""
    }));
    setWards([]);

    if (provinceName) {
        try {
            const response = await fetch(`https://vietnamlabs.com/api/vietnamprovince?province=${encodeURIComponent(provinceName)}`);
            const data = await response.json();
            if (data.success && data.data && data.data.wards) {
                setWards(data.data.wards);
            }
        } catch (error) {
            console.error("Lỗi lấy danh sách phường xã:", error);
        }
    }
  };

  const handleLocationWardChange = (e) => {
      const wardName = e.target.value;
      setLocationParts(prev => ({ ...prev, ward: wardName }));
  };

  const handleLocationDetailChange = (e) => {
      setLocationParts(prev => ({ ...prev, detail: e.target.value }));
  };

  const handleCategoryChange = async (categoryId, isChecked) => {
    if (isChecked) {
      // Add category
      setSelectedCategories((prev) => [...prev, categoryId]);

      // Auto-fetch and add skills for this category
      try {
        const categorySkills = await skillService.getSkillsByCategory(categoryId);
        if (categorySkills && categorySkills.length > 0) {
            setSkills((prev) => {
                // Merge and unique
                const existingIds = new Set(prev.map(s => s.id));
                const newSkills = categorySkills.filter(s => !existingIds.has(s.id));
                return [...prev, ...newSkills];
            });
        }
      } catch (error) {
          console.error("Lỗi khi lấy skill theo category:", error);
      }

    } else {
      // Remove category
      setSelectedCategories((prev) => prev.filter((id) => id !== categoryId));
      
      // Remove skills belonging to this category
      try {
        const categorySkills = await skillService.getSkillsByCategory(categoryId);
        if (categorySkills && categorySkills.length > 0) {
            const idsToRemove = new Set(categorySkills.map(s => s.id));
            setSkills((prev) => prev.filter(s => !idsToRemove.has(s.id)));
        }
      } catch (error) {
          console.error("Lỗi khi lấy skill để xóa:", error);
      }
    }
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
    const form = e.target;
    const formData = new FormData(form);

    const jdFile = formData.get("jdFile");

    // Construct full location from parts
    const fullLocation = locationParts.province && locationParts.ward && locationParts.detail
      ? `${locationParts.detail}, ${locationParts.ward}, ${locationParts.province}`
      : "";

    const jobData = {
      companyId: company?.id || "",
      title: formData.get("title") || "",
      description: formData.get("description") || "",
      status: "ACTIVE",
      categoryIds: selectedCategories, // Send array
      jobType: formData.get("jobType") || "",
      salaryMin: Number(formData.get("salaryMin") || 0),
      salaryMax: Number(formData.get("salaryMax") || 0),
      skillIds: skills.map((s) => s.id),
      requiredYearsOfExpMin: Number(
        formData.get("requiredYearsOfExpMin") || 0
      ),
      requiredYearsOfExpMax: Number(
        formData.get("requiredYearsOfExpMax") || 0
      ),
      experienceLevel: formData.get("experienceLevel") || "",
      location: fullLocation,
      expiryDate: formData.get("expiryDate") || null, // YYYY-MM-DD
    };

    // ===== VALIDATE =====
    if (!jobData.companyId) {
        return alert("Không tìm thấy thông tin công ty. Vui lòng đăng nhập lại!");
    }
    if (!jobData.title.trim())
      return alert("Tiêu đề công việc không được để trống");

    if (!jobData.description.trim())
      return alert("Mô tả công việc không được để trống");

    if (!jobData.categoryIds || jobData.categoryIds.length === 0)
      return alert("Bạn phải chọn ít nhất 1 ngành nghề");

    if (!jobData.jobType)
      return alert("Bạn phải chọn loại hình công việc");

    if (jobData.salaryMin <= 0 || jobData.salaryMax <= 0)
      return alert("Lương phải lớn hơn 0");

    if (jobData.salaryMin > jobData.salaryMax)
      return alert("Lương tối đa phải lớn hơn lương tối thiểu");

    if (jobData.skillIds.length === 0)
      return alert("Bạn phải chọn ít nhất 1 kỹ năng");

    if (
      jobData.requiredYearsOfExpMin < 0 ||
      jobData.requiredYearsOfExpMax < 0
    )
      return alert("Số năm kinh nghiệm không được âm");

    if (jobData.requiredYearsOfExpMin > jobData.requiredYearsOfExpMax)
      return alert("Kinh nghiệm tối đa phải lớn hơn hoặc bằng kinh nghiệm tối thiểu");

    if (!jobData.experienceLevel)
      return alert("Bạn phải chọn cấp độ kinh nghiệm");

    // Validate location
    if (!locationParts.province || !locationParts.ward || !locationParts.detail)
      return alert("Vui lòng điền đầy đủ thông tin địa điểm làm việc!");

    if (!jobData.expiryDate)
      return alert("Hạn nộp hồ sơ không được để trống");

    const today = new Date().toISOString().split("T")[0];
    if (jobData.expiryDate && jobData.expiryDate < today) {
      return alert("Hạn nộp hồ sơ phải lớn hơn hoặc bằng ngày hôm nay");
    }

    // Nếu jdFile là bắt buộc thì bật kiểm tra này
    // if (!jdFile || jdFile.size === 0) {
    //   return alert("Bạn phải tải lên JD file");
    // }

    // ======================

    // ======================

    try {
      // Create jobData object to pass to service
      // Note: service handles FormData construction now
      
      // Ensure file is in jobData if selected
      if (jdFile && jdFile.size > 0) {
        jobData.jdFile = jdFile;
      }

      console.log("Gửi đi (jobData):", jobData);
      await jobService.createJob(jobData);

      alert("Đăng tin tuyển dụng thành công!");
      form.reset();
      setSelectedCategories([]);
      setSkills([]);
      // setAvailableSkills([]); // Don't clear available skills
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
        <div className="grid grid-cols-1 gap-4">
          <div>
            <label className="block text-md font-medium mb-1 text-gray-700">
              Ngành nghề (Có thể chọn nhiều):
            </label>
            <div className="border border-gray-300 rounded p-3 max-h-40 overflow-y-auto grid grid-cols-2 md:grid-cols-3 gap-2">
                {category.map((cat) => (
                    <label key={cat.id} className="flex items-center space-x-2 cursor-pointer">
                        <input 
                            type="checkbox" 
                            value={cat.id}
                            checked={selectedCategories.includes(cat.id)}
                            onChange={(e) => handleCategoryChange(cat.id, e.target.checked)}
                            className="w-4 h-4 text-sea-600 rounded"
                        />
                        <span className="text-sm text-gray-700">{cat.name}</span>
                    </label>
                ))}
            </div>
          </div>

          <div>
            <label className="block text-md font-medium mb-1 text-gray-700">
              Loại hình công việc:
            </label>
            <select
              name="jobType"
              className="w-full border border-gray-300 rounded px-3 py-2"
              defaultValue=""
            >
              <option value="" disabled>
                Chọn loại hình công việc
              </option>
              <option value="FULL_TIME">FULL_TIME</option>
              <option value="PART_TIME">PART_TIME</option>
              <option value="CONTRACT">CONTRACT</option>
              <option value="REMOTE">REMOTE</option>
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

        {/* Required years of experience */}
        <div>
          <label className="block text-md font-medium mb-1 text-gray-700">
            Số năm kinh nghiệm:
          </label>
          <div className="grid grid-cols-2 gap-3">
            <input
              type="number"
              name="requiredYearsOfExpMin"
              placeholder="Tối thiểu (năm)"
              className="border border-gray-300 rounded px-3 py-2"
            />
            <input
              type="number"
              name="requiredYearsOfExpMax"
              placeholder="Tối đa (năm)"
              className="border border-gray-300 rounded px-3 py-2"
            />
          </div>
        </div>

        {/* Experience level */}
        <div>
          <label className="block text-md font-medium mb-1 text-gray-700">
            Cấp độ kinh nghiệm:
          </label>
          <select
            name="experienceLevel"
            className="w-full border border-gray-300 rounded px-3 py-2"
            defaultValue=""
          >
            <option value="" disabled>
              Chọn cấp độ kinh nghiệm
            </option>
            <option value="INTERN">Intern</option>
            <option value="FRESHER">Fresher</option>
            <option value="JUNIOR">Junior</option>
            <option value="SENIOR">Senior</option>
            <option value="PRINCIPAL">Principal</option>
            <option value="MANAGER">Manager</option>
            <option value="ANY">Any</option>
          </select>
        </div>

        {/* Skill selector */}
        <div>
          <label className="block text-md font-medium mb-1 text-gray-700">
            Kỹ năng:
          </label>
          <select
            onChange={handleAddSkill}
            defaultValue=""
            className="w-full border border-gray-300 rounded px-3 py-2"
          >
            <option value="" disabled>
              Chọn kỹ năng
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

        {/* Location */}
        <div>
          <label className="block text-md font-medium mb-1 text-gray-700">
            Địa điểm làm việc:
          </label>
          <div className="space-y-3">
            <div className="flex gap-2">
                {/* Province */}
                <select 
                    className="w-1/2 border rounded-lg px-2 py-2 focus:ring-2 focus:ring-emerald-500 outline-none text-sm"
                    value={locationParts.province}
                    onChange={handleLocationProvinceChange}
                >
                    <option value="">Tỉnh/Thành</option>
                    {provinces.map((p, index) => (
                        <option key={index} value={p.province}>{p.province}</option>
                    ))}
                </select>

                {/* Ward */}
                <select 
                    className="w-1/2 border rounded-lg px-2 py-2 focus:ring-2 focus:ring-emerald-500 outline-none text-sm"
                    value={locationParts.ward}
                    onChange={handleLocationWardChange}
                    disabled={!locationParts.province}
                >
                    <option value="">Phường/Xã</option>
                    {wards.map((ward, index) => (
                        <option key={index} value={ward.name}>{ward.name}</option>
                    ))}
                </select>
            </div>
            
            {/* Detail Address Input */}
            <div className="relative">
                <input
                    type="text"
                    placeholder="Số nhà, đường"
                    value={locationParts.detail}
                    onChange={handleLocationDetailChange}
                    className="w-full pl-3 pr-2 py-2 border rounded-lg focus:ring-2 focus:ring-emerald-500 focus:outline-none text-sm"
                />
            </div>
          </div>
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

        {/* JD File */}
        <div>
          <label className="block text-md font-medium mb-1 text-gray-700">
            JD File (PDF/DOC):
          </label>
          <input
            type="file"
            name="jdFile"
            accept=".pdf,.doc,.docx"
            className="w-full border border-gray-300 rounded px-3 py-2"
          />
          <p className="text-xs text-gray-500 mt-1">
            Tải lên file mô tả chi tiết công việc (JD).
          </p>
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

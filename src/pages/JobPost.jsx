import FormLayout from "../layouts/FormLayout";
import { useState } from "react";

function JobPost() {
  const allSkills = ["HTML", "CSS", "JavaScript", "React", "Figma", "Node.js", "Python", "Ruby", "Java", "PHP", "C#", "C++", "ReactJS", "Tailwind CSS"]; // danh sách tất cả các skill có thể chọn
  const [selectedSkill, setSelectedSkill] = useState(""); // giá trị đang chọn trong select
  const [skills, setSkills] = useState([]); // danh sách các skill đã chọn

  const handleAddSkill = (e) => {
    const value = e.target.value;
    setSelectedSkill(value);
    if (value && !skills.includes(value)) {
      setSkills([...skills, value]);
    }
    // reset về option mặc định sau khi chọn
    e.target.value = "";
  };

  const handleRemoveSkill = (skill) => {
    setSkills(skills.filter((s) => s !== skill));
  };
  return (
    <FormLayout>
      <h1 className="text-2xl font-bold mb-6 text-center text-gray-700">Job details</h1>
      <form className="space-y-4">
        {/* Job Title */}
        <div>
          <label className="block text-md font-medium mb-1 text-gray-700">Job title:</label>
          <input
            type="text"
            placeholder="UI/UX Designer"
            className="w-full border border-gray-300 rounded px-3 py-2 text-gray-600 focus:outline-none focus:ring-1 focus:ring-sea-200"
          />
        </div>

        {/* Job Descriptions */}
        <div>
          <label className="block text-md font-medium mb-1 text-gray-700">Job descriptions:</label>
          <textarea
            placeholder="Job description"
            rows={3}
            className="w-full border border-gray-300 rounded px-3 py-2 text-gray-600 focus:outline-none focus:ring-1 focus:ring-sea-200"
          ></textarea>
        </div>

        {/* Categories & Job Types */}
        <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
          <div>
            <label className="block text-md font-medium mb-1 text-gray-700">Categories:</label>
            <select className="w-full border border-gray-300 rounded px-3 py-2 text-gray-600 focus:outline-none focus:ring-1 focus:ring-sea-200">
              <option>Web Designer</option>
              <option>Developer</option>
              <option>Marketing</option>
            </select>
          </div>

          <div>
            <label className="block text-md font-medium mb-1 text-gray-700">Job types:</label>
            <select className="w-full border border-gray-300 rounded px-3 py-2 text-gray-600 focus:outline-none focus:ring-1 focus:ring-sea-200">
              <option>Fulltime</option>
              <option>Part-time</option>
              <option>Freelance</option>
            </select>
          </div>
        </div>

        {/* Salary */}
        <div>
          <label className="block text-md font-medium mb-1 text-gray-700">Salary</label>
          <div className="grid grid-cols-3 gap-3">
            <select className="border border-gray-300 rounded px-3 py-2 text-gray-600 focus:outline-none focus:ring-1 focus:ring-sea-200">
              <option>Hourly</option>
              <option>Monthly</option>
              <option>Yearly</option>
            </select>
            <input
              type="number"
              placeholder="$"
              className="border border-gray-300 rounded px-3 py-2 text-gray-600 focus:outline-none focus:ring-1 focus:ring-sea-200"
            />
            <input
              type="number"
              placeholder="$"
              className="border border-gray-300 rounded px-3 py-2 text-gray-600 focus:outline-none focus:ring-1 focus:ring-sea-200"
            />
          </div>
        </div>

        {/* Skills & Experience */}
        <div>
          

          {/* Skills dropdown */}
          <div className="mb-2">
            <label className="block text-md font-medium mb-1 text-gray-700">Skills:</label>
            <select
              onChange={handleAddSkill}
              defaultValue=""
              className="w-full border border-gray-300 rounded px-3 py-2 text-gray-600 focus:outline-none focus:ring-1 focus:ring-sea-200"
            >
              <option value="" disabled>
                Select skill
              </option>
              {allSkills.map((skill) => (
                <option key={skill} value={skill}>
                  {skill}
                </option>
              ))}
            </select>
          </div>

          {/* Tags hiển thị skill đã chọn */}
          <div className="flex flex-wrap gap-2 mb-3">
            {skills.map((skill) => (
              <div
                key={skill}
                className="flex items-center gap-1 bg-gray-100 text-gray-700 px-2 py-1 rounded-full text-sm "
              >
                <span>{skill}</span>
                <button
                  type="button"
                  onClick={() => handleRemoveSkill(skill)}
                  className="ml-1 text-gray-500 hover:text-red-500 focus:outline-none"
                >
                  ✕
                </button>
              </div>
            ))}
          </div>

          {/* Experience input */}
          <div>
            <label className="block text-md font-medium mb-1 text-gray-700">Experience:</label>
            <input
              type="text"
              placeholder="Experience"
              className="w-full border border-gray-300 rounded px-3 py-2 text-gray-600 focus:outline-none focus:ring-1 focus:ring-sea-200"
            />
          </div>
        </div>

        {/* Address */}
        <div>
          <label className="block text-md font-medium mb-1 text-gray-700">Address:</label>
          <input
            type="text"
            placeholder="Location"
            className="w-full border border-gray-300 rounded px-3 py-2 text-gray-600 focus:outline-none focus:ring-1 focus:ring-sea-200"
          />
        </div>

        {/* Button */}
        <div>
          <button
            type="submit"
            className="bg-sea-400 text-white px-6 py-2 rounded hover:bg-sea-300 transition-colors w-full md:w-auto"
          >
            Post Now
          </button>
        </div>
      </form>
    </FormLayout>
  );
}

export default JobPost;

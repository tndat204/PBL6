// import MainLayout from "../layouts/MainLayout";
// import { FaEnvelope, FaBirthdayCake, FaMapMarkerAlt, FaPhone } from "react-icons/fa";
// import { AiFillTwitterCircle, AiFillInstagram, AiFillFacebook } from "react-icons/ai";

// function Profile() {
  
//   const skills = [
//     { name: "WordPress", percent: 84 },
//     { name: "HTML", percent: 95 },
//     { name: "Photoshop", percent: 77 },
//     { name: "JavaScript", percent: 79 },
//     { name: "Figma", percent: 85 },
//     { name: "Illustration", percent: 65 },
//   ];

//   const experiences = [
//     {
//       img: "/images/cmc.png",
//       title: "Full Stack Developer",
//       company: "Shreethemes - India",
//       jobtype: "Full-time",
//       period: "2019 - 22",
//       description:
//         "It seems that only fragments of the original text remain in the Lorem Ipsum texts used today. One may speculate that over the course of time certain letters were added or deleted at various positions within the text.",
//     },
//     {
//       img: "/images/cmc.png",
//       title: "Back-end Developer",
//       company: "CircleCI - U.S.A.",
//       jobtype: "Part-time",
//       period: "2017 - 22",
//       description:
//         "It seems that only fragments of the original text remain in the Lorem Ipsum texts used today. One may speculate that over the course of time certain letters were added or deleted at various positions within the text.",
//     },
//   ];
//   const education = [
//     {
//       img: "/images/bk.png",
//       degree: "Bachelor of Information Technology",
//       school: "Da Nang University of Science and Technology",
//       gpa: "GPA: 3.6 / 4.0",
//       period: "2017 - 2021",
//       description:
//         "Focused on software engineering, algorithms, and web development. Participated in multiple research and development projects.",
//     },
//     {
//       img: "/images/bk.png",
//       degree: "Master of Computer Science",
//       school: "University of London",
//       gpa: "GPA: 3.9 / 4.0",
//       period: "2022 - 2024",
//       description:
//         "Specialized in AI and Machine Learning. Thesis on deep learning models for face recognition.",
//     },
//   ];

//   return (
//     <MainLayout showBanner={true}>
//       <div className="flex flex-col lg:flex-row gap-8 z-20">
//         {/* Main content */}
//         <div className="flex-1">
//           <div className="flex items-center gap-4 mb-6 mt-[-120px] relative z-30">
//             <img
//               src="/images/avatar.jpg"
//               alt="Profile"
//               className="w-30 h-30 rounded-full border-2 border-gray-300 object-cover"
//             />
//             <div className="translate-y-[70%]">
//               <h2 className="text-xl font-semibold text-gray-800">Thanh Huy Luu</h2>
//               <p className="text-gray-500 text-sm">Frontend developer</p>
//             </div>
//           </div>

//           <div className="mb-6">
//             <h3 className="text-xl font-semibold text-gray-800 mb-4">About Me</h3>
//             <p className="text-medium text-sea-400">
//               Obviously I'M Web Developer. Web Developer with over 3 years of experience. Experienced with all stages of the development cycle for dynamic web projects.
//                The as opposed to using 'Content here, content here', making it look like readable English.
//                 Data Structures and Algorithms are the heart of programming. Initially most of the developers do not realize its importance but when you will start your career in software development, you will find your code is either taking too much time or taking too much space.
//             </p>
//           </div>

//           <div className="mb-6">
//             <h3 className="text-xl font-semibold text-gray-800 mb-4">Skills</h3>
//             <div className="flex flex-wrap gap-2">
//               {skills.map((skill) => (
//                 <span
//                   key={skill.name}
//                   className="px-3 py-1 bg-gray-100 text-gray-800 text-sm rounded-full border border-gray-300 
//                             hover:bg-sea-300 hover:text-white transition-colors duration-200 cursor-pointer"
//                 >
//                   {skill.name}
//                 </span>
//               ))}
//             </div>
//           </div>



//           <div>
//             <h3 className="text-xl font-semibold text-gray-800 mb-4">Experience :</h3>
//             <div className="grid gap-6">
//               {experiences.map((exp, index) => (
//                 <div key={index} className="grid grid-cols-[80px_1fr] gap-4 items-center">
//                   {/* Logo + Period */}
//                   <div className="flex flex-col items-center">
//                     <div className="w-14 h-14 bg-gray-100 flex items-center justify-center overflow-hidden border border-gray-300">
//                       <img
//                         src={exp.img}
//                         alt={`${exp.company} logo`}
//                         className="w-full h-full object-cover"
//                       />
//                     </div>
//                     <span className="text-sm text-gray-500 mt-2">{exp.period}</span>
//                   </div>

//                   {/* Content */}
//                   <div>
//                     <h4 className="text-base font-medium text-gray-700">{exp.title}</h4>
//                     <p className="text-sm text-gray-600">{exp.company}  •  {exp.jobtype}</p>
//                     <p className="text-sm text-gray-500 leading-relaxed">
//                       {exp.description}
//                     </p>
//                   </div>
//                 </div>
//               ))}
//             </div>
//           </div>
//           <div className="mt-8">
//             <h3 className="text-xl font-semibold text-gray-800 mb-4">Education :</h3>
//             <div className="grid gap-6">
//               {education.map((edu, index) => (
//                 <div key={index} className="grid grid-cols-[80px_1fr] gap-4 items-center">
//                   {/* Logo + Period */}
//                   <div className="flex flex-col items-center">
//                     <div className="w-14 h-14 bg-gray-100 flex items-center justify-center overflow-hidden border border-gray-300">
//                       <img
//                         src={edu.img}
//                         alt={`${edu.school} logo`}
//                         className="w-full h-full object-cover"
//                       />
//                     </div>
//                     <span className="text-sm text-gray-500 mt-2">{edu.period}</span>
//                   </div>

//                   {/* Content */}
//                   <div>
//                     <h4 className="text-base font-medium text-gray-700">{edu.degree}</h4>
//                     <p className="text-sm text-gray-600">{edu.school}</p>
//                     <p className="text-sm text-gray-500 mb-1">{edu.gpa}</p>
//                     <p className="text-sm text-gray-500 leading-relaxed">{edu.description}</p>
//                   </div>
//                 </div>
//               ))}
//             </div>
//           </div>

//         </div>

//         {/* Sidebar */}
//         <div className="w-full lg:w-1/3 bg-gray-50 p-5 rounded-xl shadow-sm lg:sticky lg:top-20 h-fit self-start">
//           <h3 className="text-lg font-semibold text-gray-800 mb-4">Personal Detail</h3>
//           <ul className="space-y-3 text-sm">
//             <li className="flex justify-between items-center border-b border-gray-200 pb-2">
//               <div className="flex items-center gap-2 text-gray-600">
//                 <FaEnvelope />
//                 <span>Email</span>
//               </div>
//               <span className="font-semibold text-gray-800">thomas@mail.com</span>
//             </li>

//             <li className="flex justify-between items-center border-b border-gray-200 pb-2">
//               <div className="flex items-center gap-2 text-gray-600">
//                 <FaBirthdayCake />
//                 <span>D.O.B.</span>
//               </div>
//               <span className="font-semibold text-gray-800">31st Dec, 1996</span>
//             </li>

//             <li className="flex justify-between items-center border-b border-gray-200 pb-2">
//               <div className="flex items-center gap-2 text-gray-600">
//                 <FaMapMarkerAlt />
//                 <span>Address</span>
//               </div>
//               <span className="font-semibold text-gray-800">15 Razy street</span>
//             </li>

//             <li className="flex justify-between items-center border-b border-gray-200 pb-2">
//               <div className="flex items-center gap-2 text-gray-600">
//                 <FaMapMarkerAlt />
//                 <span>City</span>
//               </div>
//               <span className="font-semibold text-gray-800">London</span>
//             </li>

//             <li className="flex justify-between items-center border-b border-gray-200 pb-2">
//               <div className="flex items-center gap-2 text-gray-600">
//                 <FaMapMarkerAlt />
//                 <span>Country</span>
//               </div>
//               <span className="font-semibold text-gray-800">UK</span>
//             </li>

//             <li className="flex justify-between items-center">
//               <div className="flex items-center gap-2 text-gray-600">
//                 <FaPhone />
//                 <span>Mobile</span>
//               </div>
//               <span className="font-semibold text-gray-800">0128937459</span>
//             </li>
//           </ul>

//           {/* Social */}
//          <div className="mt-5 flex items-center justify-between">
//             <h4 className="text-gray-600 font-semibold text-sm">Social</h4>
//             <div className="flex gap-3 text-xl text-gray-500">
//               <a
//                 href="https://twitter.com/"
//                 target="_blank"
//                 rel="noopener noreferrer"
//                 className="hover:text-sea-300 transition-colors"
//               >
//                 <AiFillTwitterCircle size={24} />
//               </a>

//               <a
//                 href="https://instagram.com/"
//                 target="_blank"
//                 rel="noopener noreferrer"
//                 className="hover:text-sea-300 transition-colors"
//               >
//                 <AiFillInstagram size={24} />
//               </a>

//               <a
//                 href="https://facebook.com/"
//                 target="_blank"
//                 rel="noopener noreferrer"
//                 className="hover:text-sea-300 transition-colors"
//               >
//                 <AiFillFacebook size={24} />
//               </a>
//             </div>
//           </div>


//           {/* CV Download */}
//           <div className="mt-6 bg-white p-3 rounded-lg border border-gray-200 flex items-center justify-between">
//             <div className="flex items-center gap-2 text-sm text-gray-700 truncate">
//               <img src="/images/document.png" alt="File Icon" className="w-5 h-5" />
//               <span className="truncate max-w-[120px]">calvin-carlo-resume.pdf</span>
//             </div>
//           </div>

//           <button className="mt-3 w-full bg-sea-400 text-white py-2 rounded-lg hover:bg-sea-300 transition-colors">
//             Download CV
//           </button>
//         </div>

//       </div>
//     </MainLayout>
//   );
// }

// export default Profile;
  

import React, { useState } from "react";
import MainLayout from "../layouts/MainLayout";
import { FaEnvelope, FaBirthdayCake, FaMapMarkerAlt, FaPhone, FaLink, FaDollarSign, FaTrash, FaPlus } from "react-icons/fa";
import { AiFillTwitterCircle, AiFillInstagram, AiFillFacebook } from "react-icons/ai";

function Profile() {
  // State quản lý danh sách kỹ năng
  const [skills, setSkills] = useState([
    { name: "ReactJS", years: 2, level: "Intermediate", isPrimary: true },
  ]);

  // Hàm thêm dòng kỹ năng mới
  const handleAddSkill = () => {
    setSkills([...skills, { name: "", years: 0, level: "Beginner", isPrimary: false }]);
  };

  // Hàm xóa kỹ năng
  const handleRemoveSkill = (index) => {
    const newSkills = skills.filter((_, i) => i !== index);
    setSkills(newSkills);
  };

  // Hàm cập nhật giá trị input của kỹ năng
  const handleSkillChange = (index, field, value) => {
    const newSkills = [...skills];
    newSkills[index][field] = value;
    setSkills(newSkills);
  };

  return (
    <MainLayout showBanner={true}>
      <div className="flex flex-col lg:flex-row gap-8 z-20">
        
        {/* --- MAIN CONTENT (LEFT) --- */}
        <div className="flex-1">
          {/* Header Profile Info (Giữ nguyên phần avatar) */}
          <div className="flex items-center gap-4 mb-6 mt-[-120px] relative z-30">
            <img
              src="/images/avatar.jpg"
              alt="Profile"
              className="w-32 h-32 rounded-full border-4 border-white shadow-lg object-cover"
            />
            <div className="translate-y-[70%]">
              <h2 className="text-2xl font-bold text-gray-800">Thanh Huy Luu</h2>
              <p className="text-gray-500 font-medium">Frontend Developer</p>
            </div>
          </div>

          <div className="mb-8">
            <h3 className="text-xl font-semibold text-gray-800 mb-4">About Me</h3>
            <p className="text-gray-600 leading-relaxed">
              Obviously I'M Web Developer. Web Developer with over 3 years of experience. Experienced with all stages of the development cycle for dynamic web projects.
            </p>
          </div>

          {/* --- SKILLS SECTION (MỚI) --- */}
          <div className="bg-white rounded-xl shadow-sm border border-gray-200 p-6 mb-6">
            <div className="flex justify-between items-center mb-6">
              <h3 className="text-xl font-semibold text-gray-800">Skills Information</h3>
              <button 
                onClick={handleAddSkill}
                className="flex items-center gap-2 bg-sea-400 text-white px-4 py-2 rounded-lg hover:bg-sea-500 transition-colors text-sm"
              >
                <FaPlus /> Add Skill
              </button>
            </div>

            {/* Header của bảng skill */}
            <div className="grid grid-cols-12 gap-4 mb-2 text-sm font-semibold text-gray-500 uppercase px-2">
              <div className="col-span-4">Skill Name</div>
              <div className="col-span-2 text-center">Exp (Years)</div>
              <div className="col-span-3">Level</div>
              <div className="col-span-2 text-center">Primary?</div>
              <div className="col-span-1"></div>
            </div>

            <div className="space-y-3">
              {skills.map((skill, index) => (
                <div key={index} className="grid grid-cols-12 gap-4 items-center bg-gray-50 p-3 rounded-lg border border-gray-100">
                  
                  {/* Tên kỹ năng */}
                  <div className="col-span-4">
                    <input
                      type="text"
                      placeholder="e.g. ReactJS"
                      className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-sea-300"
                      value={skill.name}
                      onChange={(e) => handleSkillChange(index, "name", e.target.value)}
                    />
                  </div>

                  {/* Số năm kinh nghiệm */}
                  <div className="col-span-2">
                    <input
                      type="number"
                      min="0"
                      className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-sea-300 text-center"
                      value={skill.years}
                      onChange={(e) => handleSkillChange(index, "years", e.target.value)}
                    />
                  </div>

                  {/* Level */}
                  <div className="col-span-3">
                    <select
                      className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-sea-300 bg-white"
                      value={skill.level}
                      onChange={(e) => handleSkillChange(index, "level", e.target.value)}
                    >
                      <option value="Beginner">Beginner</option>
                      <option value="Intermediate">Intermediate</option>
                      <option value="Advanced">Advanced</option>
                      <option value="Expert">Expert</option>
                    </select>
                  </div>

                  {/* Kỹ năng chính (Checkbox) */}
                  <div className="col-span-2 flex justify-center">
                    <input
                      type="checkbox"
                      className="w-5 h-5 text-sea-500 rounded focus:ring-sea-400 cursor-pointer"
                      checked={skill.isPrimary}
                      onChange={(e) => handleSkillChange(index, "isPrimary", e.target.checked)}
                    />
                  </div>

                  {/* Nút xóa */}
                  <div className="col-span-1 flex justify-center">
                    <button 
                      onClick={() => handleRemoveSkill(index)}
                      className="text-red-400 hover:text-red-600 p-2 rounded-full hover:bg-red-50 transition-colors"
                    >
                      <FaTrash />
                    </button>
                  </div>
                </div>
              ))}
            </div>
            
            {skills.length === 0 && (
              <p className="text-center text-gray-400 py-4 italic">No skills added yet.</p>
            )}
          </div>
        </div>

        {/* --- SIDEBAR (RIGHT) --- */}
        <div className="w-full lg:w-1/3 space-y-6 lg:sticky lg:top-20 h-fit self-start">
          
          {/* Form nhập thông tin cá nhân bổ sung */}
          <div className="bg-gray-50 p-5 rounded-xl shadow-sm border border-gray-200">
            <h3 className="text-lg font-semibold text-gray-800 mb-4">Personal Detail</h3>
            <ul className="space-y-4">
              
              {/* Email (Giữ lại dạng text hoặc chuyển thành input nếu muốn) */}
              <li className="flex flex-col gap-1 border-b border-gray-200 pb-3">
                <div className="flex items-center gap-2 text-gray-600 text-sm">
                  <FaEnvelope /> <span>Email</span>
                </div>
                <span className="font-semibold text-gray-800 pl-6">thomas@mail.com</span>
              </li>

              {/* MỨC LƯƠNG MONG MUỐN (MỚI) */}
              <li className="flex flex-col gap-2 border-b border-gray-200 pb-3">
                <div className="flex items-center gap-2 text-gray-600 text-sm">
                  <FaDollarSign /> <span>Expected Salary ($)</span>
                </div>
                <input 
                  type="number" 
                  placeholder="e.g. 1500" 
                  className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-sea-300 text-sm"
                />
              </li>

              {/* LINKEDIN (MỚI) */}
              <li className="flex flex-col gap-2 border-b border-gray-200 pb-3">
                <div className="flex items-center gap-2 text-gray-600 text-sm">
                  <FaLink /> <span>LinkedIn URL</span>
                </div>
                <input 
                  type="url" 
                  placeholder="https://linkedin.com/in/..." 
                  className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-sea-300 text-sm"
                />
              </li>

              {/* PORTFOLIO (MỚI) */}
              <li className="flex flex-col gap-2 border-b border-gray-200 pb-3">
                <div className="flex items-center gap-2 text-gray-600 text-sm">
                  <FaLink /> <span>Portfolio URL</span>
                </div>
                <input 
                  type="url" 
                  placeholder="https://myportfolio.com" 
                  className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-sea-300 text-sm"
                />
              </li>

              {/* Các thông tin tĩnh khác */}
              <li className="flex justify-between items-center pt-2">
                <div className="flex items-center gap-2 text-gray-600">
                  <FaPhone />
                  <span className="text-sm">Mobile</span>
                </div>
                <span className="font-semibold text-gray-800 text-sm">0128937459</span>
              </li>
            </ul>
          </div>

          {/* Social Icons (Giữ nguyên hoặc thay bằng chức năng update) */}
          <div className="bg-white p-5 rounded-xl shadow-sm border border-gray-200">
             <h4 className="text-gray-600 font-semibold text-sm mb-3">Connected Accounts</h4>
             <div className="flex gap-4 text-2xl text-gray-400 justify-center">
                <AiFillTwitterCircle className="hover:text-blue-400 cursor-pointer" />
                <AiFillInstagram className="hover:text-pink-500 cursor-pointer" />
                <AiFillFacebook className="hover:text-blue-600 cursor-pointer" />
             </div>
          </div>
          
          <button className="w-full bg-sea-400 text-white py-3 rounded-xl font-semibold hover:bg-sea-300 transition-colors shadow-md">
            Save Changes
          </button>

        </div>
      </div>
    </MainLayout>
  );
}

export default Profile;
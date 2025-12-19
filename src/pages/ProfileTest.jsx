

// import React, { useState, useRef, useEffect } from "react";
// import MainLayout from "../layouts/MainLayout";
// import { 
//   FaUser, FaBirthdayCake, FaMapMarkerAlt, FaPhone, 
//   FaBriefcase, FaGlobe, FaDollarSign, FaPen, FaTrash, FaTimes, FaSave, FaCloudUploadAlt, FaPlus, FaCog, FaLock, FaUserEdit 
// } from "react-icons/fa";

// function Profile() {
//   // --- STATE QUẢN LÝ CÁC MODAL ---
//   const [isEditProfileOpen, setIsEditProfileOpen] = useState(false); // Modal Career/Skills
//   const [isEditPersonalOpen, setIsEditPersonalOpen] = useState(false); // Modal Personal Info
//   const [isChangePassOpen, setIsChangePassOpen] = useState(false); // Modal Password
//   const [showMenu, setShowMenu] = useState(false); // Dropdown Menu

//   const fileInputRef = useRef(null);
//   const menuRef = useRef(null);

//   // --- DỮ LIỆU PROFILE (STATE CHUNG) ---
//   const [profileData, setProfileData] = useState({
//     fullName: "Thanh Huy Luu",
//     phone: "0128937459",
//     address: "15 Razy street, London, UK",
//     dob: "31st Dec, 1996",
//     headline: "Frontend Developer",
//     about: "Obviously I'M Web Developer. Web Developer with over 3 years of experience. Experienced with all stages of the development cycle for dynamic web projects.",
//     salary: 2000,
//     linkedin: "https://linkedin.com/in/thanhhuy",
//     portfolio: "https://thanhhuy.dev",
//     skills: [
//       { name: "ReactJS", years: 2, level: "Intermediate", isPrimary: true },
//       { name: "Tailwind CSS", years: 1, level: "Advanced", isPrimary: false },
//     ]
//   });

//   // --- CLICK OUTSIDE HANDLER ---
//   useEffect(() => {
//     function handleClickOutside(event) {
//       if (menuRef.current && !menuRef.current.contains(event.target)) {
//         setShowMenu(false);
//       }
//     }
//     document.addEventListener("mousedown", handleClickOutside);
//     return () => document.removeEventListener("mousedown", handleClickOutside);
//   }, [menuRef]);

//   // --- HANDLERS ---
//   const handleChange = (e) => {
//     const { name, value } = e.target;
//     setProfileData({ ...profileData, [name]: value });
//   };

//   const handleAddSkill = () => {
//     setProfileData({
//       ...profileData,
//       skills: [...profileData.skills, { name: "", years: 0, level: "Beginner", isPrimary: false }]
//     });
//   };

//   const handleRemoveSkill = (index) => {
//     const newSkills = profileData.skills.filter((_, i) => i !== index);
//     setProfileData({ ...profileData, skills: newSkills });
//   };

//   const handleSkillChange = (index, field, value) => {
//     const newSkills = [...profileData.skills];
//     newSkills[index][field] = value;
//     setProfileData({ ...profileData, skills: newSkills });
//   };

//   const handleSaveProfessional = () => {
//     setIsEditProfileOpen(false);
//     alert("Cập nhật thông tin nghề nghiệp thành công!");
//   };

//   const handleSavePersonal = () => {
//     setIsEditPersonalOpen(false);
//     alert("Cập nhật thông tin cá nhân thành công!");
//   };

//   const handleChangePassword = () => {
//     setIsChangePassOpen(false);
//     alert("Đổi mật khẩu thành công!");
//   };

//   const handleUploadClick = () => {
//     fileInputRef.current.click();
//   };

//   const handleFileChange = (event) => {
//     const file = event.target.files[0];
//     if (file) {
//       alert(`Đã chọn file: ${file.name}`);
//     }
//   };

//   // Điều hướng menu
//   const handleMenuClick = (action) => {
//     setShowMenu(false);
//     if (action === 'editProfile') setIsEditProfileOpen(true);
//     else if (action === 'editPersonal') setIsEditPersonalOpen(true);
//     else if (action === 'changePassword') setIsChangePassOpen(true);
//   };

//   return (
//     <MainLayout showBanner={true}>
//       <div className="flex flex-col lg:flex-row gap-8 z-20">
        
//         {/* --- MAIN CONTENT (LEFT) --- */}
//         <div className="flex-1">
//           {/* Header Info */}
//           <div className="flex justify-between items-start mb-6 mt-[-120px] relative z-30">
//             <div className="flex items-center gap-4">
//               <img
//                 src="/images/avatar.jpg"
//                 alt="Profile"
//                 className="w-32 h-32 rounded-full border-4 border-white shadow-lg object-cover"
//               />
//               <div className="translate-y-[70%]">
//                 <h2 className="text-2xl font-bold text-gray-800">{profileData.fullName}</h2>
//                 <p className="text-gray-500 font-medium">{profileData.headline}</p>
//               </div>
//             </div>
            
//             {/* SETTINGS MENU */}
//             <div className="translate-y-[200%] relative" ref={menuRef}>
//               <button 
//                 onClick={() => setShowMenu(!showMenu)}
//                 className="text-sea-500 hover:text-sea-600 bg-white p-2 rounded-full shadow-md border border-gray-200 hover:bg-gray-50 transition-all focus:outline-none"
//               >
//                 <FaCog size={22} className={showMenu ? "animate-spin-slow" : ""} />
//               </button>

//               {showMenu && (
//                 <div className="absolute right-0 mt-2 w-72 bg-white rounded-xl shadow-xl border border-gray-100 overflow-hidden z-50 animate-fade-in-up">
//                   <ul className="py-1 text-gray-700">
//                     <li>
//                       <button onClick={() => handleMenuClick('editProfile')} className="w-full text-left px-4 py-3 hover:bg-gray-50 hover:text-sea-500 flex items-center gap-3 border-b border-gray-50">
//                         <FaBriefcase /> Chỉnh sửa Profile (Nghề nghiệp)
//                       </button>
//                     </li>
//                     <li>
//                       <button onClick={() => handleMenuClick('editPersonal')} className="w-full text-left px-4 py-3 hover:bg-gray-50 hover:text-sea-500 flex items-center gap-3 border-b border-gray-50">
//                         <FaUserEdit /> Chỉnh sửa thông tin cá nhân
//                       </button>
//                     </li>
//                     <li>
//                       <button onClick={() => handleMenuClick('changePassword')} className="w-full text-left px-4 py-3 hover:bg-red-50 hover:text-red-500 flex items-center gap-3">
//                         <FaLock /> Đổi mật khẩu
//                       </button>
//                     </li>
//                   </ul>
//                 </div>
//               )}
//             </div>
//           </div>

//           {/* About Me */}
//           <div className="mb-8 mt-12">
//             <h3 className="text-xl font-semibold text-gray-800 mb-3">About Me</h3>
//             <p className="text-gray-600 leading-relaxed bg-white p-5 rounded-xl border border-gray-100 shadow-sm">
//               {profileData.about}
//             </p>
//           </div>

//           {/* Career Info */}
//           <div className="mb-8">
//             <h3 className="text-xl font-semibold text-gray-800 mb-3">Career Overview</h3>
//             <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
//               <div className="bg-white p-4 rounded-xl border border-gray-200 shadow-sm flex flex-col items-center justify-center gap-2">
//                 <div className="w-10 h-10 bg-green-50 rounded-full flex items-center justify-center text-green-600"><FaDollarSign size={20} /></div>
//                 <span className="text-gray-500 text-xs uppercase tracking-wide">Expected Salary</span>
//                 <span className="text-lg font-bold text-gray-800">${profileData.salary}</span>
//               </div>
//               <a href={profileData.linkedin} target="_blank" rel="noopener noreferrer" className="bg-white p-4 rounded-xl border border-gray-200 shadow-sm flex flex-col items-center justify-center gap-2 hover:border-blue-400 transition-colors group">
//                 <div className="w-10 h-10 bg-blue-50 rounded-full flex items-center justify-center text-blue-600 group-hover:bg-blue-600 group-hover:text-white transition-colors"><FaBriefcase size={20} /></div>
//                 <span className="text-gray-500 text-xs uppercase tracking-wide">LinkedIn</span>
//                 <span className="text-sm font-semibold text-blue-600 truncate max-w-[150px]">View Profile</span>
//               </a>
//               <a href={profileData.portfolio} target="_blank" rel="noopener noreferrer" className="bg-white p-4 rounded-xl border border-gray-200 shadow-sm flex flex-col items-center justify-center gap-2 hover:border-purple-400 transition-colors group">
//                 <div className="w-10 h-10 bg-purple-50 rounded-full flex items-center justify-center text-purple-600 group-hover:bg-purple-600 group-hover:text-white transition-colors"><FaGlobe size={20} /></div>
//                 <span className="text-gray-500 text-xs uppercase tracking-wide">Portfolio</span>
//                 <span className="text-sm font-semibold text-purple-600 truncate max-w-[150px]">Visit Website</span>
//               </a>
//             </div>
//           </div>

//           {/* Skills Table */}
//           <div className="mb-8">
//             <h3 className="text-xl font-semibold text-gray-800 mb-3">Skills</h3>
//             <div className="bg-white rounded-xl shadow-sm border border-gray-200 overflow-hidden">
//               <table className="w-full text-left border-collapse">
//                 <thead>
//                   <tr className="bg-gray-50 text-gray-500 text-xs uppercase tracking-wider">
//                     <th className="px-6 py-3 font-semibold">Skill Name</th>
//                     <th className="px-6 py-3 font-semibold text-center">Exp (Yrs)</th>
//                     <th className="px-6 py-3 font-semibold text-center">Level</th>
//                     <th className="px-6 py-3 font-semibold text-center">Primary</th>
//                   </tr>
//                 </thead>
//                 <tbody className="divide-y divide-gray-100 text-gray-700 text-sm">
//                   {profileData.skills.map((skill, index) => (
//                     <tr key={index} className="hover:bg-gray-50 transition-colors">
//                       <td className="px-6 py-4 font-medium">{skill.name}</td>
//                       <td className="px-6 py-4 text-center">{skill.years}</td>
//                       <td className="px-6 py-4 text-center">
//                         <span className={`px-3 py-1 rounded-full text-xs font-semibold ${skill.level === 'Expert' ? 'bg-purple-100 text-purple-600' : skill.level === 'Advanced' ? 'bg-green-100 text-green-600' : skill.level === 'Intermediate' ? 'bg-blue-100 text-blue-600' : 'bg-gray-100 text-gray-600'}`}>
//                           {skill.level}
//                         </span>
//                       </td>
//                       <td className="px-6 py-4 text-center">
//                         {skill.isPrimary && <span className="text-sea-500 bg-sea-50 px-2 py-1 rounded border border-sea-200 text-xs font-medium">Main Skill</span>}
//                       </td>
//                     </tr>
//                   ))}
//                 </tbody>
//               </table>
//             </div>
//           </div>
//         </div>

//         {/* --- SIDEBAR (RIGHT) --- */}
//         <div className="w-full lg:w-1/3 bg-gray-50 p-5 rounded-xl shadow-sm lg:sticky lg:top-20 h-fit self-start border border-gray-100">
//            <h3 className="text-lg font-semibold text-gray-800 mb-4">Personal Detail</h3>
//            <ul className="space-y-4 text-sm">
//             <li className="flex justify-between items-start border-b border-gray-200 pb-3">
//               <div className="flex items-center gap-2 text-gray-600 mt-0.5"><FaUser /> <span>Full Name</span></div>
//               <span className="font-semibold text-gray-800 text-right max-w-[60%]">{profileData.fullName}</span>
//             </li>
//             <li className="flex justify-between items-center border-b border-gray-200 pb-3">
//               <div className="flex items-center gap-2 text-gray-600"><FaPhone /> <span>Mobile</span></div>
//               <span className="font-semibold text-gray-800">{profileData.phone}</span>
//             </li>
//             <li className="flex justify-between items-start border-b border-gray-200 pb-3">
//               <div className="flex items-center gap-2 text-gray-600 mt-0.5"><FaMapMarkerAlt /> <span>Address</span></div>
//               <span className="font-semibold text-gray-800 text-right max-w-[60%]">{profileData.address}</span>
//             </li>
//             <li className="flex justify-between items-center">
//               <div className="flex items-center gap-2 text-gray-600"><FaBirthdayCake /> <span>Date of Birth</span></div>
//               <span className="font-semibold text-gray-800">{profileData.dob}</span>
//             </li>
//           </ul>

//           <div className="mt-8">
//             <div className="bg-white p-3 rounded-lg border border-gray-200 flex items-center justify-between mb-3">
//               <div className="flex items-center gap-2 text-sm text-gray-700 truncate">
//                 <img src="/images/document.png" alt="File" className="w-5 h-5" />
//                 <span className="truncate max-w-[180px]">my-cv-final.pdf</span>
//               </div>
//             </div>
//             <input type="file" ref={fileInputRef} onChange={handleFileChange} className="hidden" accept=".pdf,.doc,.docx" />
//             <button onClick={handleUploadClick} className="w-full bg-sea-400 text-white py-2.5 rounded-lg hover:bg-sea-500 transition-colors flex items-center justify-center gap-2 shadow-sm font-medium">
//               <FaCloudUploadAlt size={18} /> Upload CV
//             </button>
//           </div>
//         </div>
//       </div>

//       {/* ================= MODAL 1: CHỈNH SỬA PROFILE (PROFESSIONAL) ================= */}
//       {isEditProfileOpen && (
//         <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/50 backdrop-blur-sm p-4 animate-fade-in">
//           <div className="bg-white w-full max-w-3xl rounded-xl shadow-2xl flex flex-col max-h-[90vh]">
//             <div className="flex justify-between items-center p-5 border-b border-gray-200">
//               <h3 className="text-xl font-bold text-gray-800 flex items-center gap-2"><FaBriefcase className="text-sea-500" /> Chỉnh sửa Profile</h3>
//               <button onClick={() => setIsEditProfileOpen(false)} className="text-gray-400 hover:text-gray-600 p-1"><FaTimes size={20} /></button>
//             </div>
            
//             <div className="p-6 overflow-y-auto space-y-6">
//                 <div>
//                   <label className="block text-sm font-semibold text-gray-600 mb-1">Professional Headline</label>
//                   <input type="text" name="headline" value={profileData.headline} onChange={handleChange} className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-sea-300 outline-none" />
//                 </div>
//                 <div>
//                   <label className="block text-sm font-semibold text-gray-600 mb-1">About Me</label>
//                   <textarea name="about" value={profileData.about} onChange={handleChange} rows="4" className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-sea-300 outline-none resize-none" />
//                 </div>
//                 <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
//                     <div>
//                       <label className="block text-sm font-semibold text-gray-600 mb-1">Expected Salary ($)</label>
//                       <input type="number" name="salary" value={profileData.salary} onChange={handleChange} className="w-full px-3 py-2 border rounded-md outline-none focus:border-sea-400" />
//                     </div>
//                     <div className="md:col-span-2">
//                       <label className="block text-sm font-semibold text-gray-600 mb-1">LinkedIn URL</label>
//                       <input type="url" name="linkedin" value={profileData.linkedin} onChange={handleChange} className="w-full px-3 py-2 border rounded-md outline-none focus:border-sea-400" />
//                     </div>
//                     <div className="md:col-span-3">
//                       <label className="block text-sm font-semibold text-gray-600 mb-1">Portfolio URL</label>
//                       <input type="url" name="portfolio" value={profileData.portfolio} onChange={handleChange} className="w-full px-3 py-2 border rounded-md outline-none focus:border-sea-400" />
//                     </div>
//                 </div>

//                 {/* SKILLS SECTION INSIDE MODAL */}
//                 <div className="bg-gray-50 p-4 rounded-lg border border-gray-200">
//                   <div className="flex justify-between items-center mb-3">
//                     <h4 className="text-sm font-bold text-gray-700">Skills Management</h4>
//                     <button onClick={handleAddSkill} className="flex items-center gap-1 text-xs bg-white text-sea-600 px-3 py-1.5 rounded-md hover:bg-gray-100 font-medium border border-gray-300 shadow-sm"><FaPlus /> Add</button>
//                   </div>
//                   <div className="space-y-3">
//                       {profileData.skills.map((skill, index) => (
//                         <div key={index} className="grid grid-cols-12 gap-3 items-center bg-white p-2 border border-gray-200 rounded-md">
//                           <div className="col-span-4"><input value={skill.name} onChange={(e) => handleSkillChange(index, 'name', e.target.value)} className="w-full text-sm border-b focus:border-sea-400 outline-none" placeholder="Name" /></div>
//                           <div className="col-span-2"><input type="number" value={skill.years} onChange={(e) => handleSkillChange(index, 'years', e.target.value)} className="w-full text-sm border-b text-center focus:border-sea-400 outline-none" placeholder="Yrs" /></div>
//                           <div className="col-span-3">
//                             <select value={skill.level} onChange={(e) => handleSkillChange(index, 'level', e.target.value)} className="w-full text-xs bg-transparent border-none outline-none">
//                               <option value="Beginner">Beginner</option>
//                               <option value="Intermediate">Intermediate</option>
//                               <option value="Advanced">Advanced</option>
//                               <option value="Expert">Expert</option>
//                             </select>
//                           </div>
//                           <div className="col-span-2 flex items-center justify-center gap-1"><input type="checkbox" checked={skill.isPrimary} onChange={(e) => handleSkillChange(index, 'isPrimary', e.target.checked)} /> <span className="text-xs">Main?</span></div>
//                           <div className="col-span-1 text-center"><button onClick={() => handleRemoveSkill(index)} className="text-red-400 hover:text-red-600"><FaTrash size={12}/></button></div>
//                         </div>
//                       ))}
//                   </div>
//                 </div>
//             </div>
            
//             <div className="p-5 border-t border-gray-200 bg-gray-50 flex justify-end gap-3 rounded-b-xl">
//               <button onClick={() => setIsEditProfileOpen(false)} className="px-5 py-2.5 rounded-lg text-gray-700 font-medium hover:bg-gray-200 transition-colors">Cancel</button>
//               <button onClick={handleSaveProfessional} className="flex items-center gap-2 px-6 py-2.5 bg-sea-500 text-white rounded-lg font-medium hover:bg-sea-600 transition-colors shadow-md"><FaSave /> Save Changes</button>
//             </div>
//           </div>
//         </div>
//       )}

//       {/* ================= MODAL 2: CHỈNH SỬA THÔNG TIN CÁ NHÂN (PERSONAL) ================= */}
//       {isEditPersonalOpen && (
//         <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/50 backdrop-blur-sm p-4 animate-fade-in">
//           <div className="bg-white w-full max-w-lg rounded-xl shadow-2xl flex flex-col">
//             <div className="flex justify-between items-center p-5 border-b border-gray-200">
//               <h3 className="text-xl font-bold text-gray-800 flex items-center gap-2"><FaUserEdit className="text-sea-500" /> Chỉnh sửa thông tin cá nhân</h3>
//               <button onClick={() => setIsEditPersonalOpen(false)} className="text-gray-400 hover:text-gray-600 p-1"><FaTimes size={20} /></button>
//             </div>

//             <div className="p-6 space-y-4">
//                 <div>
//                   <label className="block text-sm font-semibold text-gray-600 mb-1">Full Name</label>
//                   <div className="relative">
//                     <FaUser className="absolute left-3 top-3 text-gray-400" />
//                     <input type="text" name="fullName" value={profileData.fullName} onChange={handleChange} className="w-full pl-10 pr-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-sea-300 outline-none" />
//                   </div>
//                 </div>
//                 <div>
//                   <label className="block text-sm font-semibold text-gray-600 mb-1">Date of Birth</label>
//                   <div className="relative">
//                     <FaBirthdayCake className="absolute left-3 top-3 text-gray-400" />
//                     <input type="text" name="dob" value={profileData.dob} onChange={handleChange} className="w-full pl-10 pr-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-sea-300 outline-none" />
//                   </div>
//                 </div>
//                 <div>
//                   <label className="block text-sm font-semibold text-gray-600 mb-1">Mobile Phone</label>
//                   <div className="relative">
//                     <FaPhone className="absolute left-3 top-3 text-gray-400" />
//                     <input type="text" name="phone" value={profileData.phone} onChange={handleChange} className="w-full pl-10 pr-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-sea-300 outline-none" />
//                   </div>
//                 </div>
//                 <div>
//                   <label className="block text-sm font-semibold text-gray-600 mb-1">Address</label>
//                   <div className="relative">
//                     <FaMapMarkerAlt className="absolute left-3 top-3 text-gray-400" />
//                     <input type="text" name="address" value={profileData.address} onChange={handleChange} className="w-full pl-10 pr-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-sea-300 outline-none" />
//                   </div>
//                 </div>
//             </div>

//             <div className="p-5 border-t border-gray-200 bg-gray-50 flex justify-end gap-3 rounded-b-xl">
//               <button onClick={() => setIsEditPersonalOpen(false)} className="px-5 py-2.5 rounded-lg text-gray-700 font-medium hover:bg-gray-200 transition-colors">Cancel</button>
//               <button onClick={handleSavePersonal} className="flex items-center gap-2 px-6 py-2.5 bg-sea-500 text-white rounded-lg font-medium hover:bg-sea-600 transition-colors shadow-md"><FaSave /> Save Changes</button>
//             </div>
//           </div>
//         </div>
//       )}

//       {/* ================= MODAL 3: ĐỔI MẬT KHẨU (PASSWORD) ================= */}
//       {isChangePassOpen && (
//         <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/50 backdrop-blur-sm p-4 animate-fade-in">
//           <div className="bg-white w-full max-w-md rounded-xl shadow-2xl overflow-hidden">
//             <div className="p-5 border-b border-gray-100 flex justify-between items-center">
//                <h3 className="text-lg font-bold text-gray-800 flex items-center gap-2"><FaLock className="text-sea-500"/> Đổi mật khẩu</h3>
//                <button onClick={() => setIsChangePassOpen(false)} className="text-gray-400 hover:text-gray-600"><FaTimes /></button>
//             </div>
//             <div className="p-6 space-y-4">
//                <div>
//                   <label className="block text-sm font-medium text-gray-700 mb-1">Mật khẩu hiện tại</label>
//                   <input type="password" className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-sea-300 outline-none" />
//                </div>
//                <div>
//                   <label className="block text-sm font-medium text-gray-700 mb-1">Mật khẩu mới</label>
//                   <input type="password" className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-sea-300 outline-none" />
//                </div>
//                <div>
//                   <label className="block text-sm font-medium text-gray-700 mb-1">Xác nhận mật khẩu mới</label>
//                   <input type="password" className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-sea-300 outline-none" />
//                </div>
//             </div>
//             <div className="p-5 bg-gray-50 flex justify-end gap-3 border-t border-gray-100">
//                <button onClick={() => setIsChangePassOpen(false)} className="px-4 py-2 text-gray-600 hover:bg-gray-200 rounded-lg">Hủy</button>
//                <button onClick={handleChangePassword} className="px-6 py-2 bg-sea-500 text-white rounded-lg hover:bg-sea-600 shadow-sm">Lưu mật khẩu</button>
//             </div>
//           </div>
//         </div>
//       )}
//     </MainLayout>
//   );
// }

// export default Profile;

import React, { useState, useRef, useEffect } from "react";
import MainLayout from "../layouts/MainLayout";
import { 
  FaUser, FaBirthdayCake, FaMapMarkerAlt, FaPhone, 
  FaBriefcase, FaGlobe, FaDollarSign, FaPen, FaTrash, FaTimes, FaSave, FaCloudUploadAlt, FaPlus, FaCog, FaLock, FaUserEdit 
} from "react-icons/fa";

function ProfileTest() {
  // --- STATE QUẢN LÝ CÁC MODAL ---
  const [isEditProfileOpen, setIsEditProfileOpen] = useState(false); // Modal Career/Skills
  const [isEditPersonalOpen, setIsEditPersonalOpen] = useState(false); // Modal Personal Info
  const [isChangePassOpen, setIsChangePassOpen] = useState(false); // Modal Password
  const [showMenu, setShowMenu] = useState(false); // Dropdown Menu

  const fileInputRef = useRef(null);
  const menuRef = useRef(null);

  // --- DỮ LIỆU PROFILE (STATE CHUNG) ---
  const [profileData, setProfileData] = useState({
    fullName: "Thanh Huy Luu",
    phone: "0128937459",
    address: "15 Razy street, London, UK",
    dob: "31/12/1996", // Đổi định dạng ngày cho phù hợp VN
    headline: "Frontend Developer",
    about: "Tôi là một Lập trình viên Web với hơn 3 năm kinh nghiệm. Có kinh nghiệm trong tất cả các giai đoạn của quy trình phát triển các dự án web động.",
    salary: 2000,
    linkedin: "https://linkedin.com/in/thanhhuy",
    portfolio: "https://thanhhuy.dev",
    skills: [
      { name: "ReactJS", years: 2, level: "Intermediate", isPrimary: true },
      { name: "Tailwind CSS", years: 1, level: "Advanced", isPrimary: false },
    ]
  });

  // Helper để hiển thị level tiếng Việt
  const getLevelLabel = (level) => {
    switch (level) {
        case "Beginner": return "Mới bắt đầu";
        case "Intermediate": return "Trung bình";
        case "Advanced": return "Nâng cao";
        case "Expert": return "Chuyên gia";
        default: return level;
    }
  };

  // --- CLICK OUTSIDE HANDLER ---
  useEffect(() => {
    function handleClickOutside(event) {
      if (menuRef.current && !menuRef.current.contains(event.target)) {
        setShowMenu(false);
      }
    }
    document.addEventListener("mousedown", handleClickOutside);
    return () => document.removeEventListener("mousedown", handleClickOutside);
  }, [menuRef]);

  // --- HANDLERS ---
  const handleChange = (e) => {
    const { name, value } = e.target;
    setProfileData({ ...profileData, [name]: value });
  };

  const handleAddSkill = () => {
    setProfileData({
      ...profileData,
      skills: [...profileData.skills, { name: "", years: 0, level: "Beginner", isPrimary: false }]
    });
  };

  const handleRemoveSkill = (index) => {
    const newSkills = profileData.skills.filter((_, i) => i !== index);
    setProfileData({ ...profileData, skills: newSkills });
  };

  const handleSkillChange = (index, field, value) => {
    const newSkills = [...profileData.skills];
    newSkills[index][field] = value;
    setProfileData({ ...profileData, skills: newSkills });
  };

  const handleSaveProfessional = () => {
    setIsEditProfileOpen(false);
    alert("Cập nhật thông tin nghề nghiệp thành công!");
  };

  const handleSavePersonal = () => {
    setIsEditPersonalOpen(false);
    alert("Cập nhật thông tin cá nhân thành công!");
  };

  const handleChangePassword = () => {
    setIsChangePassOpen(false);
    alert("Đổi mật khẩu thành công!");
  };

  const handleUploadClick = () => {
    fileInputRef.current.click();
  };

  const handleFileChange = (event) => {
    const file = event.target.files[0];
    if (file) {
      alert(`Đã chọn file: ${file.name}`);
    }
  };

  // Điều hướng menu
  const handleMenuClick = (action) => {
    setShowMenu(false);
    if (action === 'editProfile') setIsEditProfileOpen(true);
    else if (action === 'editPersonal') setIsEditPersonalOpen(true);
    else if (action === 'changePassword') setIsChangePassOpen(true);
  };

  return (
    <MainLayout showBanner={true}>
      <div className="flex flex-col lg:flex-row gap-8 z-20">
        
        {/* --- MAIN CONTENT (LEFT) --- */}
        <div className="flex-1">
          {/* Header Info */}
          <div className="flex justify-between items-start mb-6 mt-[-120px] relative z-30">
            <div className="flex items-center gap-4">
              <img
                src="/images/avt.jpg"
                alt="Profile"
                className="w-32 h-32 rounded-full border-4 border-white shadow-lg object-cover"
              />
              <div className="translate-y-[70%]">
                <h2 className="text-2xl font-bold text-gray-800">{profileData.fullName}</h2>
                <p className="text-gray-500 font-medium">{profileData.headline}</p>
              </div>
            </div>
            
            
            {/* SETTINGS MENU */}
            <div className="translate-y-[200%] relative" ref={menuRef}>
              <button 
                onClick={() => setShowMenu(!showMenu)}
                className="text-sea-500 hover:text-sea-600 bg-white p-2 rounded-full shadow-md border border-gray-200 hover:bg-gray-50 transition-all focus:outline-none"
              >
                <FaCog size={22} className={showMenu ? "animate-spin-slow" : ""} />
              </button>

              {showMenu && (
                <div className="absolute right-0 mt-2 w-72 bg-white rounded-xl shadow-xl border border-gray-100 overflow-hidden z-50 animate-fade-in-up">
                  <ul className="py-1 text-gray-700">
                    <li>
                      <button onClick={() => handleMenuClick('editProfile')} className="w-full text-left px-4 py-3 hover:bg-gray-50 hover:text-sea-500 flex items-center gap-3 border-b border-gray-50">
                        <FaBriefcase /> Chỉnh sửa hồ sơ (Nghề nghiệp)
                      </button>
                    </li>
                    <li>
                      <button onClick={() => handleMenuClick('editPersonal')} className="w-full text-left px-4 py-3 hover:bg-gray-50 hover:text-sea-500 flex items-center gap-3 border-b border-gray-50">
                        <FaUserEdit /> Chỉnh sửa thông tin cá nhân
                      </button>
                    </li>
                    <li>
                      <button onClick={() => handleMenuClick('changePassword')} className="w-full text-left px-4 py-3 hover:bg-red-50 hover:text-red-500 flex items-center gap-3">
                        <FaLock /> Đổi mật khẩu
                      </button>
                    </li>
                  </ul>
                </div>
              )}
            </div>
          </div>

          {/* About Me */}
          <div className="mb-8 mt-12">
            <h3 className="text-xl font-semibold text-gray-800 mb-3">Giới thiệu bản thân</h3>
            <p className="text-gray-600 leading-relaxed bg-white p-5 rounded-xl border border-gray-100 shadow-sm">
              {profileData.about}
            </p>
          </div>

          {/* Career Info */}
          <div className="mb-8">
            <h3 className="text-xl font-semibold text-gray-800 mb-3">Tổng quan nghề nghiệp</h3>
            <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
              <div className="bg-white p-4 rounded-xl border border-gray-200 shadow-sm flex flex-col items-center justify-center gap-2">
                <div className="w-10 h-10 bg-green-50 rounded-full flex items-center justify-center text-green-600"><FaDollarSign size={20} /></div>
                <span className="text-gray-500 text-xs uppercase tracking-wide">Mức lương mong muốn</span>
                <span className="text-lg font-bold text-gray-800">${profileData.salary}</span>
              </div>
              <a href={profileData.linkedin} target="_blank" rel="noopener noreferrer" className="bg-white p-4 rounded-xl border border-gray-200 shadow-sm flex flex-col items-center justify-center gap-2 hover:border-blue-400 transition-colors group">
                <div className="w-10 h-10 bg-blue-50 rounded-full flex items-center justify-center text-blue-600 group-hover:bg-blue-600 group-hover:text-white transition-colors"><FaBriefcase size={20} /></div>
                <span className="text-gray-500 text-xs uppercase tracking-wide">LinkedIn</span>
                <span className="text-sm font-semibold text-blue-600 truncate max-w-[150px]">Xem hồ sơ</span>
              </a>
              <a href={profileData.portfolio} target="_blank" rel="noopener noreferrer" className="bg-white p-4 rounded-xl border border-gray-200 shadow-sm flex flex-col items-center justify-center gap-2 hover:border-purple-400 transition-colors group">
                <div className="w-10 h-10 bg-purple-50 rounded-full flex items-center justify-center text-purple-600 group-hover:bg-purple-600 group-hover:text-white transition-colors"><FaGlobe size={20} /></div>
                <span className="text-gray-500 text-xs uppercase tracking-wide">Portfolio</span>
                <span className="text-sm font-semibold text-purple-600 truncate max-w-[150px]">Truy cập Website</span>
              </a>
            </div>
          </div>

          {/* Skills Table */}
          <div className="mb-8">
            <h3 className="text-xl font-semibold text-gray-800 mb-3">Kỹ năng</h3>
            <div className="bg-white rounded-xl shadow-sm border border-gray-200 overflow-hidden">
              <table className="w-full text-left border-collapse">
                <thead>
                  <tr className="bg-gray-50 text-gray-500 text-xs uppercase tracking-wider">
                    <th className="px-6 py-3 font-semibold">Tên kỹ năng</th>
                    <th className="px-6 py-3 font-semibold text-center">Kinh nghiệm (Năm)</th>
                    <th className="px-6 py-3 font-semibold text-center">Trình độ</th>
                    <th className="px-6 py-3 font-semibold text-center">Chính</th>
                  </tr>
                </thead>
                <tbody className="divide-y divide-gray-100 text-gray-700 text-sm">
                  {profileData.skills.map((skill, index) => (
                    <tr key={index} className="hover:bg-gray-50 transition-colors">
                      <td className="px-6 py-4 font-medium">{skill.name}</td>
                      <td className="px-6 py-4 text-center">{skill.years}</td>
                      <td className="px-6 py-4 text-center">
                        <span className={`px-3 py-1 rounded-full text-xs font-semibold ${skill.level === 'Expert' ? 'bg-purple-100 text-purple-600' : skill.level === 'Advanced' ? 'bg-green-100 text-green-600' : skill.level === 'Intermediate' ? 'bg-blue-100 text-blue-600' : 'bg-gray-100 text-gray-600'}`}>
                          {getLevelLabel(skill.level)}
                        </span>
                      </td>
                      <td className="px-6 py-4 text-center">
                        {skill.isPrimary && <span className="text-sea-500 bg-sea-50 px-2 py-1 rounded border border-sea-200 text-xs font-medium">Kỹ năng chính</span>}
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          </div>
        </div>

        {/* --- SIDEBAR (RIGHT) --- */}
        <div className="w-full lg:w-1/3 bg-gray-50 p-5 rounded-xl shadow-sm lg:sticky lg:top-20 h-fit self-start border border-gray-100">
           <h3 className="text-lg font-semibold text-gray-800 mb-4">Thông tin cá nhân</h3>
           <ul className="space-y-4 text-sm">
            <li className="flex justify-between items-start border-b border-gray-200 pb-3">
              <div className="flex items-center gap-2 text-gray-600 mt-0.5"><FaUser /> <span>Họ và tên</span></div>
              <span className="font-semibold text-gray-800 text-right max-w-[60%]">{profileData.fullName}</span>
            </li>
            <li className="flex justify-between items-center border-b border-gray-200 pb-3">
              <div className="flex items-center gap-2 text-gray-600"><FaPhone /> <span>Số điện thoại</span></div>
              <span className="font-semibold text-gray-800">{profileData.phone}</span>
            </li>
            <li className="flex justify-between items-start border-b border-gray-200 pb-3">
              <div className="flex items-center gap-2 text-gray-600 mt-0.5"><FaMapMarkerAlt /> <span>Địa chỉ</span></div>
              <span className="font-semibold text-gray-800 text-right max-w-[60%]">{profileData.address}</span>
            </li>
            <li className="flex justify-between items-center">
              <div className="flex items-center gap-2 text-gray-600"><FaBirthdayCake /> <span>Ngày sinh</span></div>
              <span className="font-semibold text-gray-800">{profileData.dob}</span>
            </li>
          </ul>

          <div className="mt-8">
            <div className="bg-white p-3 rounded-lg border border-gray-200 flex items-center justify-between mb-3">
              <div className="flex items-center gap-2 text-sm text-gray-700 truncate">
                <img src="/images/document.png" alt="File" className="w-5 h-5" />
                <span className="truncate max-w-[180px]">my-cv-final.pdf</span>
              </div>
            </div>
            <input type="file" ref={fileInputRef} onChange={handleFileChange} className="hidden" accept=".pdf,.doc,.docx" />
            <button onClick={handleUploadClick} className="w-full bg-sea-400 text-white py-2.5 rounded-lg hover:bg-sea-500 transition-colors flex items-center justify-center gap-2 shadow-sm font-medium">
              <FaCloudUploadAlt size={18} /> Tải lên CV
            </button>
          </div>
        </div>
      </div>

      {/* ================= MODAL 1: CHỈNH SỬA PROFILE (PROFESSIONAL) ================= */}
      {isEditProfileOpen && (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/50 backdrop-blur-sm p-4 animate-fade-in">
          <div className="bg-white w-full max-w-3xl rounded-xl shadow-2xl flex flex-col max-h-[90vh]">
            <div className="flex justify-between items-center p-5 border-b border-gray-200">
              <h3 className="text-xl font-bold text-gray-800 flex items-center gap-2"><FaBriefcase className="text-sea-500" /> Chỉnh sửa hồ sơ</h3>
              <button onClick={() => setIsEditProfileOpen(false)} className="text-gray-400 hover:text-gray-600 p-1"><FaTimes size={20} /></button>
            </div>
            
            <div className="p-6 overflow-y-auto space-y-6">
                <div>
                  <label className="block text-sm font-semibold text-gray-600 mb-1">Chức danh / Tiêu đề hồ sơ</label>
                  <input type="text" name="headline" value={profileData.headline} onChange={handleChange} className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-sea-300 outline-none" />
                </div>
                <div>
                  <label className="block text-sm font-semibold text-gray-600 mb-1">Giới thiệu bản thân</label>
                  <textarea name="about" value={profileData.about} onChange={handleChange} rows="4" className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-sea-300 outline-none resize-none" />
                </div>
                <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
                    <div>
                      <label className="block text-sm font-semibold text-gray-600 mb-1">Mức lương mong muốn ($)</label>
                      <input type="number" name="salary" value={profileData.salary} onChange={handleChange} className="w-full px-3 py-2 border rounded-md outline-none focus:border-sea-400" />
                    </div>
                    <div className="md:col-span-2">
                      <label className="block text-sm font-semibold text-gray-600 mb-1">Liên kết LinkedIn</label>
                      <input type="url" name="linkedin" value={profileData.linkedin} onChange={handleChange} className="w-full px-3 py-2 border rounded-md outline-none focus:border-sea-400" />
                    </div>
                    <div className="md:col-span-3">
                      <label className="block text-sm font-semibold text-gray-600 mb-1">Liên kết Portfolio</label>
                      <input type="url" name="portfolio" value={profileData.portfolio} onChange={handleChange} className="w-full px-3 py-2 border rounded-md outline-none focus:border-sea-400" />
                    </div>
                </div>

                {/* SKILLS SECTION INSIDE MODAL */}
                <div className="bg-gray-50 p-4 rounded-lg border border-gray-200">
                  <div className="flex justify-between items-center mb-3">
                    <h4 className="text-sm font-bold text-gray-700">Quản lý kỹ năng</h4>
                    <button onClick={handleAddSkill} className="flex items-center gap-1 text-xs bg-white text-sea-600 px-3 py-1.5 rounded-md hover:bg-gray-100 font-medium border border-gray-300 shadow-sm"><FaPlus /> Thêm</button>
                  </div>
                  <div className="space-y-3">
                      {profileData.skills.map((skill, index) => (
                        <div key={index} className="grid grid-cols-12 gap-3 items-center bg-white p-2 border border-gray-200 rounded-md">
                          <div className="col-span-4"><input value={skill.name} onChange={(e) => handleSkillChange(index, 'name', e.target.value)} className="w-full text-sm border-b focus:border-sea-400 outline-none" placeholder="Tên kỹ năng" /></div>
                          <div className="col-span-2"><input type="number" value={skill.years} onChange={(e) => handleSkillChange(index, 'years', e.target.value)} className="w-full text-sm border-b text-center focus:border-sea-400 outline-none" placeholder="Năm" /></div>
                          <div className="col-span-3">
                            <select value={skill.level} onChange={(e) => handleSkillChange(index, 'level', e.target.value)} className="w-full text-xs bg-transparent border-none outline-none">
                              <option value="Beginner">Mới bắt đầu</option>
                              <option value="Intermediate">Trung bình</option>
                              <option value="Advanced">Nâng cao</option>
                              <option value="Expert">Chuyên gia</option>
                            </select>
                          </div>
                          <div className="col-span-2 flex items-center justify-center gap-1"><input type="checkbox" checked={skill.isPrimary} onChange={(e) => handleSkillChange(index, 'isPrimary', e.target.checked)} /> <span className="text-xs">Chính?</span></div>
                          <div className="col-span-1 text-center"><button onClick={() => handleRemoveSkill(index)} className="text-red-400 hover:text-red-600"><FaTrash size={12}/></button></div>
                        </div>
                      ))}
                  </div>
                </div>
            </div>
            
            <div className="p-5 border-t border-gray-200 bg-gray-50 flex justify-end gap-3 rounded-b-xl">
              <button onClick={() => setIsEditProfileOpen(false)} className="px-5 py-2.5 rounded-lg text-gray-700 font-medium hover:bg-gray-200 transition-colors border border-gray-300 ">Hủy</button>
              <button onClick={handleSaveProfessional} className="flex items-center gap-2 px-6 py-2.5 bg-sea-500 text-white rounded-lg font-medium hover:bg-sea-600 transition-colors shadow-md from-sea-400 to-sea-300 bg-gradient-to-l"><FaSave /> Lưu thay đổi</button>
            </div>
          </div>
        </div>
      )}

      {/* ================= MODAL 2: CHỈNH SỬA THÔNG TIN CÁ NHÂN (PERSONAL) ================= */}
      {isEditPersonalOpen && (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/50 backdrop-blur-sm p-4 animate-fade-in">
          <div className="bg-white w-full max-w-lg rounded-xl shadow-2xl flex flex-col">
            <div className="flex justify-between items-center p-5 border-b border-gray-200">
              <h3 className="text-xl font-bold text-gray-800 flex items-center gap-2"><FaUserEdit className="text-sea-500" /> Chỉnh sửa thông tin cá nhân</h3>
              <button onClick={() => setIsEditPersonalOpen(false)} className="text-gray-400 hover:text-gray-600 p-1"><FaTimes size={20} /></button>
            </div>

            <div className="p-6 space-y-4">
                <div>
                  <label className="block text-sm font-semibold text-gray-600 mb-1">Họ và tên</label>
                  <div className="relative">
                    <FaUser className="absolute left-3 top-3 text-gray-400" />
                    <input type="text" name="fullName" value={profileData.fullName} onChange={handleChange} className="w-full pl-10 pr-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-sea-300 outline-none" />
                  </div>
                </div>
                <div>
                  <label className="block text-sm font-semibold text-gray-600 mb-1">Ngày sinh</label>
                  <div className="relative">
                    <FaBirthdayCake className="absolute left-3 top-3 text-gray-400" />
                    <input type="text" name="dob" value={profileData.dob} onChange={handleChange} className="w-full pl-10 pr-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-sea-300 outline-none" />
                  </div>
                </div>
                <div>
                  <label className="block text-sm font-semibold text-gray-600 mb-1">Số điện thoại</label>
                  <div className="relative">
                    <FaPhone className="absolute left-3 top-3 text-gray-400" />
                    <input type="text" name="phone" value={profileData.phone} onChange={handleChange} className="w-full pl-10 pr-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-sea-300 outline-none" />
                  </div>
                </div>
                <div>
                  <label className="block text-sm font-semibold text-gray-600 mb-1">Địa chỉ</label>
                  <div className="relative">
                    <FaMapMarkerAlt className="absolute left-3 top-3 text-gray-400" />
                    <input type="text" name="address" value={profileData.address} onChange={handleChange} className="w-full pl-10 pr-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-sea-300 outline-none" />
                  </div>
                </div>
            </div>

            <div className="p-5 border-t border-gray-200 bg-gray-50 flex justify-end gap-3 rounded-b-xl">
              <button onClick={() => setIsEditPersonalOpen(false)} className="px-5 py-2.5 rounded-lg text-gray-700 font-medium hover:bg-gray-200 transition-colors border border-gray-300">Hủy</button>
              <button onClick={handleSavePersonal} className="flex items-center gap-2 px-6 py-2.5 bg-sea-500 text-white rounded-lg font-medium hover:bg-sea-600 transition-colors shadow-md from-sea-400 to-sea-300 bg-gradient-to-l"><FaSave /> Lưu thay đổi</button>
            </div>
          </div>
        </div>
      )}

      {/* ================= MODAL 3: ĐỔI MẬT KHẨU (PASSWORD) ================= */}
      {isChangePassOpen && (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/50 backdrop-blur-sm p-4 animate-fade-in">
          <div className="bg-white w-full max-w-md rounded-xl shadow-2xl overflow-hidden">
            <div className="p-5 border-b border-gray-100 flex justify-between items-center">
               <h3 className="text-lg font-bold text-gray-800 flex items-center gap-2"><FaLock className="text-sea-500"/> Đổi mật khẩu</h3>
               <button onClick={() => setIsChangePassOpen(false)} className="text-gray-400 hover:text-gray-600"><FaTimes /></button>
            </div>
            <div className="p-6 space-y-4">
               <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">Mật khẩu hiện tại</label>
                  <input type="password" className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-sea-300 outline-none" />
               </div>
               <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">Mật khẩu mới</label>
                  <input type="password" className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-sea-300 outline-none" />
               </div>
               <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">Xác nhận mật khẩu mới</label>
                  <input type="password" className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-sea-300 outline-none" />
               </div>
            </div>
            <div className="p-5 bg-gray-50 flex justify-end gap-3 border-t border-gray-100">
               <button onClick={() => setIsChangePassOpen(false)} className="px-4 py-2 text-gray-600 hover:bg-gray-200 rounded-lg border border-gray-300">Hủy</button>
               <button onClick={handleChangePassword} className="px-6 py-2 bg-sea-500 text-white rounded-lg hover:bg-sea-600 shadow-sm from-sea-400 to-sea-300 bg-gradient-to-l">Lưu mật khẩu</button>
            </div>
          </div>
        </div>
      )}
    </MainLayout>
  );
}

export default ProfileTest;
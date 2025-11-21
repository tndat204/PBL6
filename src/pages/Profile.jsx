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

import React from 'react';
import { 
  MapPin, 
  Mail, 
  Phone, 
  Linkedin, 
  Globe, 
  FileText, 
  Download, 
  Briefcase, 
  GraduationCap, 
  Calendar, 
  DollarSign,
  CheckCircle,
  Edit3,
  Star
} from 'lucide-react';

// Giả sử bạn đã có MainLayout (nếu chưa có thì thay bằng div bình thường)
// import MainLayout from "../layouts/MainLayout"; 

const UserProfile = () => {
  
  // --- MOCK DATA (Kết hợp dữ liệu User + Profile JSON) ---
  const profileData = {
    // Thông tin User cơ bản
    fullName: "Lưu Thanh Huy",
    email: "huy.luu@example.com",
    phone: "0909 123 456",
    dob: "15/08/1998",
    address: "Đà Nẵng, Việt Nam",
    avatarUrl: "https://i.pravatar.cc/300?u=huy",
    coverUrl: "https://images.unsplash.com/photo-1579546929518-9e396f3cc809?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80",

    // Thông tin từ Profile JSON
    headline: "Senior Frontend Developer (ReactJS)",
    summary: "Lập trình viên Frontend với hơn 4 năm kinh nghiệm, chuyên sâu về ReactJS và Tailwind CSS. Đam mê tối ưu trải nghiệm người dùng và hiệu năng ứng dụng. Đã từng tham gia phát triển các dự án Ecommerce và SaaS quy mô lớn.",
    desiredSalary: 2000, // USD
    isActive: true, // Open to work
    cvFileName: "thanhhuy_cv_2025.pdf",
    linkedinUrl: "https://linkedin.com/in/huyluu",
    portfolioUrl: "https://huyluu.dev",

    // Mảng kỹ năng (Từ JSON)
    skills: [
      { name: "ReactJS", level: "EXPERT", experienceYears: 4, isPrimary: true },
      { name: "Next.js", level: "ADVANCED", experienceYears: 2, isPrimary: true },
      { name: "Tailwind CSS", level: "ADVANCED", experienceYears: 3, isPrimary: false },
      { name: "TypeScript", level: "INTERMEDIATE", experienceYears: 2, isPrimary: false },
      { name: "NodeJS", level: "BEGINNER", experienceYears: 1, isPrimary: false },
      { name: "Figma", level: "INTERMEDIATE", experienceYears: 2, isPrimary: false },
    ],

    // Kinh nghiệm làm việc (Mock thêm để giống mẫu của bạn)
    experiences: [
      {
        company: "FPT Software",
        role: "Senior Frontend Developer",
        period: "2022 - Hiện tại",
        type: "Full-time",
        logo: "https://upload.wikimedia.org/wikipedia/commons/thumb/1/11/FPT_logo_2010.svg/1200px-FPT_logo_2010.svg.png",
        description: "Chịu trách nhiệm chính phát triển module Admin Dashboard. Mentor cho 2 Junior Developers. Tối ưu hóa performance giảm 40% thời gian load trang."
      },
      {
        company: "SmartDev",
        role: "Web Developer",
        period: "2019 - 2022",
        type: "Full-time",
        logo: "https://smartdev.com/wp-content/uploads/2021/03/SmartDev-Logo.png",
        description: "Tham gia dự án Outsourcing cho khách hàng Fintech Châu Âu. Xây dựng UI Components sử dụng React và Ant Design."
      }
    ],

    // Học vấn
    education: [
        {
            school: "Đại học Bách Khoa Đà Nẵng",
            degree: "Kỹ sư Công nghệ thông tin",
            period: "2016 - 2021",
            gpa: "GPA: 3.2/4.0",
            logo: "https://upload.wikimedia.org/wikipedia/commons/a/a1/Logo_Đại_học_Bách_Khoa_Đà_Nẵng.png",
            description: "Chuyên ngành Công nghệ phần mềm. Đồ án tốt nghiệp loại Giỏi."
        }
    ]
  };

  // Helper function để chọn màu cho level skill
  const getSkillColor = (level) => {
    switch(level) {
        case 'EXPERT': return 'bg-purple-50 text-purple-700 border-purple-200';
        case 'ADVANCED': return 'bg-blue-50 text-blue-700 border-blue-200';
        default: return 'bg-gray-50 text-gray-700 border-gray-200';
    }
  };

  return (
    <div className="bg-gray-50 min-h-screen pb-20 font-sans">
      
      {/* --- BANNER SECTION --- */}
      <div className="relative h-60 w-full">
        <img 
            src={profileData.coverUrl} 
            alt="Cover" 
            className="w-full h-full object-cover"
        />
        <div className="absolute inset-0 bg-black/20"></div>
      </div>

      <div className="container mx-auto px-4 lg:px-20">
        <div className="flex flex-col lg:flex-row gap-8">
          
          {/* --- MAIN CONTENT (LEFT) --- */}
          <div className="flex-1">
            
            {/* 1. HEADER INFO (Avatar đè lên Banner) */}
            <div className="flex flex-col sm:flex-row items-start sm:items-end gap-6 mb-8 -mt-16 relative z-10">
              <div className="relative">
                  <img
                    src={profileData.avatarUrl}
                    alt="Profile"
                    className="w-36 h-36 rounded-full border-4 border-white shadow-lg object-cover bg-white"
                  />
                  {profileData.isActive && (
                    <div className="absolute bottom-2 right-2 bg-green-500 border-2 border-white w-6 h-6 rounded-full flex items-center justify-center" title="Open to Work">
                        <CheckCircle size={14} className="text-white" />
                    </div>
                  )}
              </div>
              
              <div className="mb-2 flex-1">
                <h2 className="text-2xl font-bold text-gray-800 flex items-center gap-2">
                    {profileData.fullName}
                    <button className="text-gray-400 hover:text-blue-600 transition-colors">
                        <Edit3 size={18} />
                    </button>
                </h2>
                <p className="text-blue-600 font-medium text-lg">{profileData.headline}</p>
                <div className="flex gap-4 mt-2 text-sm text-gray-500">
                    <span className="flex items-center gap-1"><MapPin size={14}/> {profileData.address}</span>
                    <span className="flex items-center gap-1 text-green-600 font-medium"><DollarSign size={14}/> Mong muốn: ${profileData.desiredSalary}</span>
                </div>
              </div>

              <div className="hidden sm:block mb-4">
                  <button className="bg-blue-600 text-white px-6 py-2 rounded-lg font-medium hover:bg-blue-700 transition-all shadow-sm">
                      Cập nhật hồ sơ
                  </button>
              </div>
            </div>

            {/* 2. ABOUT ME */}
            <div className="mb-8">
              <h3 className="text-xl font-bold text-gray-800 mb-4 flex items-center gap-2">
                Giới thiệu
              </h3>
              <p className="text-gray-600 leading-relaxed bg-white p-6 rounded-xl border border-gray-200 shadow-sm">
                {profileData.summary}
              </p>
            </div>

            {/* 3. SKILLS (Mapping from JSON) */}
            <div className="mb-8">
              <h3 className="text-xl font-bold text-gray-800 mb-4">Kỹ năng chuyên môn</h3>
              <div className="bg-white p-6 rounded-xl border border-gray-200 shadow-sm">
                  <div className="flex flex-wrap gap-3">
                    {profileData.skills.map((skill, index) => (
                      <div
                        key={index}
                        className={`px-4 py-2 rounded-lg border text-sm font-medium flex items-center gap-2 transition-all cursor-default ${getSkillColor(skill.level)}`}
                      >
                        {skill.isPrimary && <Star size={14} className="fill-current" />}
                        {skill.name}
                        <span className="text-xs opacity-70 font-normal border-l border-current pl-2 ml-1">
                            {skill.experienceYears} năm
                        </span>
                      </div>
                    ))}
                  </div>
              </div>
            </div>

            {/* 4. EXPERIENCE */}
            <div className="mb-8">
              <h3 className="text-xl font-bold text-gray-800 mb-4">Kinh nghiệm làm việc</h3>
              <div className="space-y-6">
                {profileData.experiences.map((exp, index) => (
                  <div key={index} className="flex gap-4 bg-white p-6 rounded-xl border border-gray-200 shadow-sm hover:shadow-md transition-shadow">
                    <div className="w-14 h-14 flex-shrink-0 bg-gray-50 rounded-lg p-2 border border-gray-100 flex items-center justify-center">
                      <img src={exp.logo} alt={exp.company} className="w-full h-full object-contain" />
                    </div>
                    <div className="flex-1">
                      <div className="flex justify-between items-start">
                          <div>
                              <h4 className="text-lg font-bold text-gray-800">{exp.role}</h4>
                              <p className="text-blue-600 font-medium text-sm">{exp.company}</p>
                          </div>
                          <span className="text-xs bg-gray-100 text-gray-600 px-2 py-1 rounded font-medium">{exp.type}</span>
                      </div>
                      <p className="text-sm text-gray-400 mt-1 flex items-center gap-1">
                          <Calendar size={14}/> {exp.period}
                      </p>
                      <p className="text-gray-600 mt-3 text-sm leading-relaxed border-t border-gray-100 pt-3">
                        {exp.description}
                      </p>
                    </div>
                  </div>
                ))}
              </div>
            </div>

            {/* 5. EDUCATION */}
            <div className="mb-8">
              <h3 className="text-xl font-bold text-gray-800 mb-4">Học vấn</h3>
              <div className="space-y-4">
                {profileData.education.map((edu, index) => (
                   <div key={index} className="flex gap-4 bg-white p-6 rounded-xl border border-gray-200 shadow-sm">
                    <div className="w-12 h-12 flex-shrink-0 bg-white rounded-full border border-gray-200 p-1 flex items-center justify-center overflow-hidden">
                        <img src={edu.logo} alt={edu.school} className="w-full h-full object-contain" />
                    </div>
                    <div>
                        <h4 className="text-base font-bold text-gray-800">{edu.school}</h4>
                        <p className="text-gray-600 text-sm">{edu.degree}</p>
                        <div className="flex gap-4 mt-1 text-sm text-gray-500">
                            <span>{edu.period}</span>
                            <span className="text-blue-600 font-medium">{edu.gpa}</span>
                        </div>
                        <p className="text-gray-500 text-sm mt-2 italic">{edu.description}</p>
                    </div>
                   </div> 
                ))}
              </div>
            </div>

          </div>

          {/* --- SIDEBAR (RIGHT) --- */}
          <div className="w-full lg:w-1/3">
            <div className="bg-white p-6 rounded-xl shadow-sm border border-gray-200 sticky top-24">
              <h3 className="text-lg font-bold text-gray-800 mb-6 pb-2 border-b border-gray-100">
                  Thông tin cá nhân
              </h3>
              
              <ul className="space-y-5 text-sm">
                <li className="flex justify-between items-start">
                  <div className="flex items-center gap-3 text-gray-500">
                    <div className="p-2 bg-gray-100 rounded-lg"><Mail size={16} /></div>
                    <span>Email</span>
                  </div>
                  <span className="font-medium text-gray-800 max-w-[150px] truncate" title={profileData.email}>{profileData.email}</span>
                </li>

                <li className="flex justify-between items-start">
                  <div className="flex items-center gap-3 text-gray-500">
                    <div className="p-2 bg-gray-100 rounded-lg"><Calendar size={16} /></div>
                    <span>Ngày sinh</span>
                  </div>
                  <span className="font-medium text-gray-800">{profileData.dob}</span>
                </li>

                <li className="flex justify-between items-start">
                  <div className="flex items-center gap-3 text-gray-500">
                    <div className="p-2 bg-gray-100 rounded-lg"><MapPin size={16} /></div>
                    <span>Địa chỉ</span>
                  </div>
                  <span className="font-medium text-gray-800 text-right">{profileData.address}</span>
                </li>

                <li className="flex justify-between items-start">
                  <div className="flex items-center gap-3 text-gray-500">
                    <div className="p-2 bg-gray-100 rounded-lg"><Phone size={16} /></div>
                    <span>Điện thoại</span>
                  </div>
                  <span className="font-medium text-gray-800">{profileData.phone}</span>
                </li>
              </ul>

              {/* Social Links */}
              <div className="mt-8">
                <h4 className="text-gray-500 font-semibold text-sm mb-4">Mạng xã hội</h4>
                <div className="flex gap-3">
                    <a href={profileData.linkedinUrl} className="p-3 bg-blue-50 text-blue-600 rounded-lg hover:bg-blue-600 hover:text-white transition-all">
                        <Linkedin size={20} />
                    </a>
                    <a href={profileData.portfolioUrl} className="p-3 bg-orange-50 text-orange-600 rounded-lg hover:bg-orange-600 hover:text-white transition-all">
                        <Globe size={20} />
                    </a>
                </div>
              </div>

              {/* CV Download */}
              <div className="mt-8 pt-6 border-t border-gray-100">
                <h4 className="text-gray-500 font-semibold text-sm mb-3">CV đính kèm</h4>
                <div className="flex items-center justify-between bg-gray-50 p-3 rounded-lg border border-gray-200 mb-4">
                    <div className="flex items-center gap-2 text-sm text-gray-700 overflow-hidden">
                        <FileText size={18} className="text-red-500 flex-shrink-0" />
                        <span className="truncate">{profileData.cvFileName}</span>
                    </div>
                </div>
                <button className="w-full flex items-center justify-center gap-2 bg-[#2A437C] text-white py-2.5 rounded-lg font-medium hover:bg-blue-800 transition-colors shadow-md shadow-blue-900/10">
                    <Download size={18} />
                    <span>Tải xuống CV</span>
                </button>
              </div>

            </div>
          </div>

        </div>
      </div>
    </div>
  );
};

export default UserProfile;
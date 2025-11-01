import MainLayout from "../layouts/MainLayout";
import { FaEnvelope, FaBirthdayCake, FaMapMarkerAlt, FaPhone } from "react-icons/fa";
import { AiFillTwitterCircle, AiFillInstagram, AiFillFacebook } from "react-icons/ai";

function Profile() {
  
  const skills = [
    { name: "WordPress", percent: 84 },
    { name: "HTML", percent: 95 },
    { name: "Photoshop", percent: 77 },
    { name: "JavaScript", percent: 79 },
    { name: "Figma", percent: 85 },
    { name: "Illustration", percent: 65 },
  ];

  const experiences = [
    {
      img: "/images/cmc.png",
      title: "Full Stack Developer",
      company: "Shreethemes - India",
      jobtype: "Full-time",
      period: "2019 - 22",
      description:
        "It seems that only fragments of the original text remain in the Lorem Ipsum texts used today. One may speculate that over the course of time certain letters were added or deleted at various positions within the text.",
    },
    {
      img: "/images/cmc.png",
      title: "Back-end Developer",
      company: "CircleCI - U.S.A.",
      jobtype: "Part-time",
      period: "2017 - 22",
      description:
        "It seems that only fragments of the original text remain in the Lorem Ipsum texts used today. One may speculate that over the course of time certain letters were added or deleted at various positions within the text.",
    },
  ];
  const education = [
    {
      img: "/images/bk.png",
      degree: "Bachelor of Information Technology",
      school: "Da Nang University of Science and Technology",
      gpa: "GPA: 3.6 / 4.0",
      period: "2017 - 2021",
      description:
        "Focused on software engineering, algorithms, and web development. Participated in multiple research and development projects.",
    },
    {
      img: "/images/bk.png",
      degree: "Master of Computer Science",
      school: "University of London",
      gpa: "GPA: 3.9 / 4.0",
      period: "2022 - 2024",
      description:
        "Specialized in AI and Machine Learning. Thesis on deep learning models for face recognition.",
    },
  ];

  return (
    <MainLayout showBanner={true}>
      <div className="flex flex-col lg:flex-row gap-8 z-20">
        {/* Main content */}
        <div className="flex-1">
          <div className="flex items-center gap-4 mb-6 mt-[-120px] relative z-30">
            <img
              src="/images/avatar.jpg"
              alt="Profile"
              className="w-30 h-30 rounded-full border-2 border-gray-300 object-cover"
            />
            <div className="translate-y-[70%]">
              <h2 className="text-xl font-semibold text-gray-800">Thanh Huy Luu</h2>
              <p className="text-gray-500 text-sm">Frontend developer</p>
            </div>
          </div>

          <div className="mb-6">
            <h3 className="text-xl font-semibold text-gray-800 mb-4">About Me</h3>
            <p className="text-medium text-sea-400">
              Obviously I'M Web Developer. Web Developer with over 3 years of experience. Experienced with all stages of the development cycle for dynamic web projects.
               The as opposed to using 'Content here, content here', making it look like readable English.
                Data Structures and Algorithms are the heart of programming. Initially most of the developers do not realize its importance but when you will start your career in software development, you will find your code is either taking too much time or taking too much space.
            </p>
          </div>

          <div className="mb-6">
            <h3 className="text-xl font-semibold text-gray-800 mb-4">Skills</h3>
            <div className="flex flex-wrap gap-2">
              {skills.map((skill) => (
                <span
                  key={skill.name}
                  className="px-3 py-1 bg-gray-100 text-gray-800 text-sm rounded-full border border-gray-300 
                            hover:bg-sea-300 hover:text-white transition-colors duration-200 cursor-pointer"
                >
                  {skill.name}
                </span>
              ))}
            </div>
          </div>



          <div>
            <h3 className="text-xl font-semibold text-gray-800 mb-4">Experience :</h3>
            <div className="grid gap-6">
              {experiences.map((exp, index) => (
                <div key={index} className="grid grid-cols-[80px_1fr] gap-4 items-center">
                  {/* Logo + Period */}
                  <div className="flex flex-col items-center">
                    <div className="w-14 h-14 bg-gray-100 flex items-center justify-center overflow-hidden border border-gray-300">
                      <img
                        src={exp.img}
                        alt={`${exp.company} logo`}
                        className="w-full h-full object-cover"
                      />
                    </div>
                    <span className="text-sm text-gray-500 mt-2">{exp.period}</span>
                  </div>

                  {/* Content */}
                  <div>
                    <h4 className="text-base font-medium text-gray-700">{exp.title}</h4>
                    <p className="text-sm text-gray-600">{exp.company}  •  {exp.jobtype}</p>
                    <p className="text-sm text-gray-500 leading-relaxed">
                      {exp.description}
                    </p>
                  </div>
                </div>
              ))}
            </div>
          </div>
          <div className="mt-8">
            <h3 className="text-xl font-semibold text-gray-800 mb-4">Education :</h3>
            <div className="grid gap-6">
              {education.map((edu, index) => (
                <div key={index} className="grid grid-cols-[80px_1fr] gap-4 items-center">
                  {/* Logo + Period */}
                  <div className="flex flex-col items-center">
                    <div className="w-14 h-14 bg-gray-100 flex items-center justify-center overflow-hidden border border-gray-300">
                      <img
                        src={edu.img}
                        alt={`${edu.school} logo`}
                        className="w-full h-full object-cover"
                      />
                    </div>
                    <span className="text-sm text-gray-500 mt-2">{edu.period}</span>
                  </div>

                  {/* Content */}
                  <div>
                    <h4 className="text-base font-medium text-gray-700">{edu.degree}</h4>
                    <p className="text-sm text-gray-600">{edu.school}</p>
                    <p className="text-sm text-gray-500 mb-1">{edu.gpa}</p>
                    <p className="text-sm text-gray-500 leading-relaxed">{edu.description}</p>
                  </div>
                </div>
              ))}
            </div>
          </div>

        </div>

        {/* Sidebar */}
        <div className="w-full lg:w-1/3 bg-gray-50 p-5 rounded-xl shadow-sm lg:sticky lg:top-20 h-fit self-start">
          <h3 className="text-lg font-semibold text-gray-800 mb-4">Personal Detail</h3>
          <ul className="space-y-3 text-sm">
            <li className="flex justify-between items-center border-b border-gray-200 pb-2">
              <div className="flex items-center gap-2 text-gray-600">
                <FaEnvelope />
                <span>Email</span>
              </div>
              <span className="font-semibold text-gray-800">thomas@mail.com</span>
            </li>

            <li className="flex justify-between items-center border-b border-gray-200 pb-2">
              <div className="flex items-center gap-2 text-gray-600">
                <FaBirthdayCake />
                <span>D.O.B.</span>
              </div>
              <span className="font-semibold text-gray-800">31st Dec, 1996</span>
            </li>

            <li className="flex justify-between items-center border-b border-gray-200 pb-2">
              <div className="flex items-center gap-2 text-gray-600">
                <FaMapMarkerAlt />
                <span>Address</span>
              </div>
              <span className="font-semibold text-gray-800">15 Razy street</span>
            </li>

            <li className="flex justify-between items-center border-b border-gray-200 pb-2">
              <div className="flex items-center gap-2 text-gray-600">
                <FaMapMarkerAlt />
                <span>City</span>
              </div>
              <span className="font-semibold text-gray-800">London</span>
            </li>

            <li className="flex justify-between items-center border-b border-gray-200 pb-2">
              <div className="flex items-center gap-2 text-gray-600">
                <FaMapMarkerAlt />
                <span>Country</span>
              </div>
              <span className="font-semibold text-gray-800">UK</span>
            </li>

            <li className="flex justify-between items-center">
              <div className="flex items-center gap-2 text-gray-600">
                <FaPhone />
                <span>Mobile</span>
              </div>
              <span className="font-semibold text-gray-800">0128937459</span>
            </li>
          </ul>

          {/* Social */}
         <div className="mt-5 flex items-center justify-between">
            <h4 className="text-gray-600 font-semibold text-sm">Social</h4>
            <div className="flex gap-3 text-xl text-gray-500">
              <a
                href="https://twitter.com/"
                target="_blank"
                rel="noopener noreferrer"
                className="hover:text-sea-300 transition-colors"
              >
                <AiFillTwitterCircle size={24} />
              </a>

              <a
                href="https://instagram.com/"
                target="_blank"
                rel="noopener noreferrer"
                className="hover:text-sea-300 transition-colors"
              >
                <AiFillInstagram size={24} />
              </a>

              <a
                href="https://facebook.com/"
                target="_blank"
                rel="noopener noreferrer"
                className="hover:text-sea-300 transition-colors"
              >
                <AiFillFacebook size={24} />
              </a>
            </div>
          </div>


          {/* CV Download */}
          <div className="mt-6 bg-white p-3 rounded-lg border border-gray-200 flex items-center justify-between">
            <div className="flex items-center gap-2 text-sm text-gray-700 truncate">
              <img src="/images/document.png" alt="File Icon" className="w-5 h-5" />
              <span className="truncate max-w-[120px]">calvin-carlo-resume.pdf</span>
            </div>
          </div>

          <button className="mt-3 w-full bg-sea-400 text-white py-2 rounded-lg hover:bg-sea-300 transition-colors">
            Download CV
          </button>
        </div>

      </div>
    </MainLayout>
  );
}

export default Profile;
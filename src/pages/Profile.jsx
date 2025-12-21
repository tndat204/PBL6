
import React, { useState, useRef, useEffect } from "react";
import MainLayout from "../layouts/MainLayout";
import { 
  FaUser, FaBirthdayCake, FaMapMarkerAlt, FaPhone, 
  FaBriefcase, FaGlobe, FaDollarSign, FaPen, FaTrash, FaTimes, FaSave, FaCloudUploadAlt, FaPlus, FaCog, FaLock, FaUserEdit, FaDownload, FaCamera, FaEye, FaEyeSlash 
} from "react-icons/fa";
import { profileService, userService, skillService } from "../services";
import { useAuth } from "../hooks/useAuth";
import { formatCurrency } from "../utils/formatUtils";

function Profile() {
  const { user, updateUser } = useAuth(); // Get user and updateUser from auth context
  
  // --- STATE QUẢN LÝ CÁC MODAL ---
  const [isEditProfileOpen, setIsEditProfileOpen] = useState(false); // Modal Career/Skills
  const [isEditPersonalOpen, setIsEditPersonalOpen] = useState(false); // Modal Personal Info
  const [isChangePassOpen, setIsChangePassOpen] = useState(false); // Modal Password
  const [showMenu, setShowMenu] = useState(false); // Dropdown Menu
  const [loading, setLoading] = useState(true); // Loading state
  const [allSkills, setAllSkills] = useState([]); // All available skills for dropdown

  const fileInputRef = useRef(null);
  const avatarInputRef = useRef(null);
  const menuRef = useRef(null);

  // --- DỮ LIỆU PROFILE (STATE CHUNG) ---
  const [profileData, setProfileData] = useState(null);
  const [formattedSalary, setFormattedSalary] = useState(''); // Formatted salary for display
  const [selectedCvFile, setSelectedCvFile] = useState(null); // File selected but not yet uploaded
  
  // Address split fields
  const [addressParts, setAddressParts] = useState({
    province: "",
    ward: "",
    detail: ""
  });
  const [provinces, setProvinces] = useState([]);
  const [wards, setWards] = useState([]);
  
  // Password change fields
  const [passwordData, setPasswordData] = useState({
    oldPassword: '',
    newPassword: '',
    confirmPassword: ''
  });
  const [showPassword, setShowPassword] = useState({
    old: false,
    new: false,
    confirm: false
  });




  // Helper: Format number with thousand separators
  const formatNumber = (value) => {
    if (!value) return '';
    return value.toString().replace(/\B(?=(\d{3})+(?!\d))/g, '.');
  };


  // Fetch profile data on mount
  useEffect(() => {
    const fetchData = async () => {
      if (!user) {
        setLoading(false);
        return;
      }

      try {
        const profile = await profileService.getMyProfile();
        
        setProfileData({
          // From user object (useAuth)
          fullName: user.fullName || '',
          phone: user.phone || '',
          address: user.address || '',
          avatarUrl: user.avatarUrl || '/images/avt.jpg',
          
          // From profile object
          headline: profile.headline || '',
          summary: profile.summary || 'Chưa có dữ liệu',
          linkedin: profile.linkedinUrl || '',
          portfolio: profile.portfolioUrl || '',
          skills: profile.skills?.map(s => ({
            id: s.skill?.id || '',
            name: s.skill?.name || '',
            years: s.experienceYears || 0,
            level: s.level || 'BEGINNER',
            isPrimary: s.isPrimary || false
          })) || [],
          
          // Placeholder (not in backend)
          desiredSalary: profile.desiredSalary,
          cvFile: profile.cvFile 
        });
        
        // Fetch all skills for dropdown
        const skills = await skillService.getAllSkills();
        setAllSkills(skills || []);
        
        // Set formatted salary for display
        setFormattedSalary(formatNumber(profile.desiredSalary || 0));
      } catch (error) {
        console.error('Error fetching profile:', error);
        alert('Lỗi tải thông tin profile');
      } finally {
        setLoading(false);
      }
    };

    fetchData();
  }, [user]);

  // Fetch provinces on mount
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

  // Parse existing address when profileData loads
  useEffect(() => {
    const parseAddress = async () => {
      console.log('🔍 Parsing address - profileData:', profileData);
      console.log('🔍 Parsing address - profileData.address:', profileData?.address);
      
      if (profileData && profileData.address) {
        // Split address: "detail, ward, province"
        const parts = profileData.address.split(', ');
        console.log('🔍 Address parts:', parts);
        
        if (parts.length >= 3) {
          const province = parts[parts.length - 1] || '';
          const ward = parts[parts.length - 2] || '';
          const detail = parts.slice(0, -2).join(', ') || '';
          
          console.log('🔍 Parsed address:', { province, ward, detail });
          
          setAddressParts({
            province,
            ward,
            detail
          });
          
          // Fetch wards for the province
          if (province) {
            try {
              const response = await fetch(`https://vietnamlabs.com/api/vietnamprovince?province=${encodeURIComponent(province)}`);
              const data = await response.json();
              if (data.success && data.data && data.data.wards) {
                setWards(data.data.wards);
                console.log('🔍 Fetched wards for province:', province, data.data.wards.length);
              }
            } catch (error) {
              console.error("Lỗi lấy danh sách phường xã:", error);
            }
          }
        } else {
          // Fallback if format is different
          console.log('🔍 Address format different, using fallback');
          setAddressParts({
            province: '',
            ward: '',
            detail: profileData.address
          });
        }
      }
    };
    
    parseAddress();
  }, [profileData]);

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
      skills: [...profileData.skills, { id: "", name: "", years: 0, level: "BEGINNER", isPrimary: false }]
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

  const handleSaveProfessional = async () => {
    try {
      // Validate skills - check if any skill has empty ID
      const emptySkills = profileData.skills.filter(s => !s.id || s.id.trim() === '');
      if (emptySkills.length > 0) {
        alert("Vui lòng chọn kỹ năng hoặc xóa các kỹ năng chưa chọn trước khi lưu");
        return;
      }
      
      const updateData = {
        headline: profileData.headline,
        summary: profileData.summary,
        cvFile: profileData.cvFile,
        linkedinUrl: profileData.linkedin,
        portfolioUrl: profileData.portfolio,
        desiredSalary: profileData.desiredSalary,
        skills: profileData.skills.map(s => ({
          skillId: s.id,
          experienceYears: s.years,
          level: s.level,
          isPrimary: s.isPrimary
        }))
      };
      
      console.log('Updating profile with data:', updateData);
      console.log('🔍 DEBUG - Data types:', {
        skills: typeof updateData.skills,
        skillsIsArray: Array.isArray(updateData.skills),
        skillsLength: updateData.skills?.length,
        salary: typeof updateData.desiredSalary,
        salaryValue: updateData.desiredSalary,
        skillsContent: JSON.stringify(updateData.skills, null, 2)
      });
      console.log('🔍 DEBUG - Full payload:', JSON.stringify(updateData, null, 2));
      
      await profileService.updateMyProfile(updateData);
      
      setIsEditProfileOpen(false);
      alert("Đã cập nhật thông tin nghề nghiệp thành công!");
    } catch (error) {
      console.error('Error:', error);
      alert("Lỗi: " + error.message);
    }
  };

  // Handle Province Change
  const handleProvinceChange = async (e) => {
    const provinceName = e.target.value;
    
    setAddressParts(prev => ({
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

  // Handle Ward Change  
  const handleWardChange = (e) => {
    const wardName = e.target.value;
    setAddressParts(prev => ({ ...prev, ward: wardName }));
  };

  // Handle Detail Address Change
  const handleDetailAddressChange = (e) => {
    setAddressParts(prev => ({ ...prev, detail: e.target.value }));
  };

  const handleSavePersonal = async () => {
    try {
      // Concatenate address from parts
      const fullAddress = `${addressParts.detail}, ${addressParts.ward}, ${addressParts.province}`.replace(/^, |, $/g, '');
      
      await userService.updateMe({
        fullName: profileData.fullName,
        phone: profileData.phone,
        address: fullAddress
      });
      
      // Update profileData state to reflect changes immediately
      setProfileData(prev => ({
        ...prev,
        address: fullAddress
      }));
      
      // Update user in AuthContext and localStorage
      updateUser({
        fullName: profileData.fullName,
        phone: profileData.phone,
        address: fullAddress
      });
      
      setIsEditPersonalOpen(false);
      alert("Đã cập nhật thông tin cá nhân thành công!");
    } catch (error) {
      console.error('Error:', error);
      alert("Lỗi: " + error.message);
    }
  };



  const handleUploadClick = () => {
    fileInputRef.current.click();
  };

  const handleFileChange = (event) => {
    const file = event.target.files[0];
    if (!file) return;
    
    // Validate file type - Only PDF
    if (file.type !== 'application/pdf') {
      alert("Chỉ chấp nhận file PDF");
      event.target.value = ''; // Reset input
      return;
    }
    
    // Save file to state, don't upload yet
    setSelectedCvFile(file);
  };

  const handleUploadCv = async () => {
    if (!selectedCvFile) {
      alert("Vui lòng chọn file CV trước");
      return;
    }
    
    try {
      setLoading(true);
      await profileService.uploadMyCv(selectedCvFile);
      alert("Tải CV thành công!");
      
      // Re-fetch profile to get updated CV URL
      const profile = await profileService.getMyProfile();
      setProfileData({ ...profileData, cvFile: profile.cvFile || '' });
      setSelectedCvFile(null); // Clear selected file
    } catch (error) {
      console.error('Error:', error);
      alert("Lỗi tải CV: " + error.message);
    } finally {
      setLoading(false);
    }
  };

  const handleChangePassword = async () => {
    // Validation
    if (!passwordData.oldPassword || !passwordData.newPassword || !passwordData.confirmPassword) {
      alert("Vui lòng điền đầy đủ thông tin");
      return;
    }
    
    if (passwordData.newPassword !== passwordData.confirmPassword) {
      alert("Mật khẩu mới và xác nhận không khớp");
      return;
    }
    
    if (passwordData.newPassword.length < 6) {
      alert("Mật khẩu mới phải có ít nhất 6 ký tự");
      return;
    }
    
    try {
      await userService.changePassword(passwordData.oldPassword, passwordData.newPassword);
      
      // Reset form and close modal
      setPasswordData({
        oldPassword: '',
        newPassword: '',
        confirmPassword: ''
      });
      setIsChangePassOpen(false);
      alert("Đổi mật khẩu thành công!");
    } catch (error) {
      console.error('Error:', error);
      alert("Lỗi đổi mật khẩu: " + error.message);
    }
  };

  const handleAvatarChange = async (event) => {
    const file = event.target.files[0];
    if (!file) return;
    
    // Validate file type - Only images
    if (!file.type.startsWith('image/')) {
      alert("Đây không phải là file ảnh");
      return;
    }
    
    try {
      setLoading(true);
      const result = await userService.uploadAvatar(file);
      console.log('Avatar upload result:', result);
      
      // Backend returns URL string directly
      const avatarUrl = typeof result === 'string' ? result : (result.avatarUrl || result.avatar);
      
      // Update localStorage user object with new avatar
      const storedUser = localStorage.getItem('user');
      if (storedUser) {
        const userObj = JSON.parse(storedUser);
        userObj.avatarUrl = avatarUrl;
        localStorage.setItem('user', JSON.stringify(userObj));
        
        // Update profileData state immediately
        setProfileData({ ...profileData, avatarUrl: avatarUrl });
      }
    } catch (error) {
      console.error('Error:', error);
      alert("Lỗi tải avatar: " + error.message);
    } finally {
      setLoading(false);
    }
  };

  // Điều hướng menu
  const handleMenuClick = (action) => {
    setShowMenu(false);
    if (action === 'editProfile') setIsEditProfileOpen(true);
    else if (action === 'editPersonal') setIsEditPersonalOpen(true);
    else if (action === 'changePassword') setIsChangePassOpen(true);
  };

  // Loading state
  if (loading) {
    return (
      <MainLayout showBanner={true}>
        <div className="flex items-center justify-center min-h-screen">
          <div className="text-center">
            <div className="animate-spin rounded-full h-12 w-12 border-4 border-sea-500 border-t-transparent mx-auto mb-4"></div>
            <p className="text-gray-600">Đang tải thông tin...</p>
          </div>
        </div>
      </MainLayout>
    );
  }

  // No profile data
  if (!profileData) {
    return (
      <MainLayout showBanner={true}>
        <div className="max-w-7xl mx-auto py-10 text-center">
          <p className="text-gray-600">Không thể tải thông tin profile</p>
        </div>
      </MainLayout>
    );
  }

  return (
    <MainLayout showBanner={true}>
      <div className="flex flex-col lg:flex-row gap-8 z-20">
        
        {/* --- MAIN CONTENT (LEFT) --- */}
        <div className="flex-1">
          {/* Header Info */}
          <div className="flex justify-between items-start mb-6 mt-[-120px] relative z-30">
            <div className="flex items-center gap-4">
              <div className="relative">
                <img
                  src={profileData.avatarUrl || "/images/avt.jpg"}
                  alt="Profile"
                  className="w-32 h-32 rounded-full border-4 border-white shadow-lg object-cover"
                />
                <button
                  onClick={() => avatarInputRef.current.click()}
                  className="absolute bottom-0 right-0 bg-gray-800 hover:bg-gray-900 text-white p-2 rounded-full shadow-lg transition-colors"
                  title="Thay đổi avatar"
                >
                  <FaCamera size={16} />
                </button>
                <input
                  type="file"
                  ref={avatarInputRef}
                  onChange={handleAvatarChange}
                  className="hidden"
                  accept="image/*"
                />
              </div>
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

          {/* Summary */}
          <div className="mb-8 mt-12">
            <h3 className="text-xl font-semibold text-gray-800 mb-3">Giới thiệu bản thân</h3>
            <p className="text-gray-600 leading-relaxed bg-white p-5 rounded-xl border border-gray-100 shadow-sm">
              {profileData.summary}
            </p>
          </div>

          {/* Career Info */}
          <div className="mb-8">
            <h3 className="text-xl font-semibold text-gray-800 mb-3">Tổng quan nghề nghiệp</h3>
            <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
              <div className="bg-white p-4 rounded-xl border border-gray-200 shadow-sm flex flex-col items-center justify-center gap-2">
                <div className="w-10 h-10 bg-green-50 rounded-full flex items-center justify-center text-green-600"><FaDollarSign size={20} /></div>
                <span className="text-gray-500 text-xs uppercase tracking-wide">Mức lương mong muốn</span>
                <span className="text-lg font-bold text-gray-800">{formatCurrency(profileData.desiredSalary)} VND</span>
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
                          {skill.level}
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
          </ul>

          <div className="mt-8">
            <div 
              onClick={handleUploadClick}
              className="bg-white p-3 rounded-lg border border-gray-200 flex items-center justify-between mb-3 cursor-pointer hover:border-sea-400 transition-colors"
            >
              <div className="flex items-center gap-2 text-sm text-gray-700 truncate">
                <img src="/images/document.png" alt="File" className="w-5 h-5" />
                <span className="truncate max-w-[180px]">
                  {selectedCvFile ? selectedCvFile.name : (profileData.cvFile || "Chưa có CV")}
                </span>
              </div>
            </div>
            <input type="file" ref={fileInputRef} onChange={handleFileChange} className="hidden" accept=".pdf" />
            <button 
              onClick={handleUploadCv} 
              disabled={!selectedCvFile}
              className="w-full bg-sea-400 text-white py-2.5 rounded-lg hover:bg-sea-500 transition-colors flex items-center justify-center gap-2 shadow-sm font-medium disabled:bg-gray-300 disabled:cursor-not-allowed"
            >
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
                  <textarea name="summary" value={profileData.summary} onChange={handleChange} rows="4" className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-sea-300 outline-none resize-none" />
                </div>
                <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
                    <div>
                      <label className="block text-sm font-semibold text-gray-600 mb-1">Mức lương mong muốn (VND)</label>
                      <input 
                        type="text" 
                        name="desiredSalary" 
                        value={formattedSalary} 
                        onChange={(e) => {
                          const value = e.target.value.replace(/\./g, ''); // Remove dots
                          if (/^\d*$/.test(value)) { // Only allow digits
                            setFormattedSalary(formatNumber(value));
                            setProfileData({ ...profileData, desiredSalary: parseInt(value) || 0 });
                          }
                        }} 
                        className="w-full px-3 py-2 border rounded-md outline-none focus:border-sea-400" 
                        placeholder="Ví dụ: 20.000.000"
                      />
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
                          <div className="col-span-4">
                            <select 
                              value={skill.id} 
                              onChange={(e) => {
                                const selectedSkill = allSkills.find(s => s.id === e.target.value);
                                if (selectedSkill) {
                                  handleSkillChange(index, 'id', selectedSkill.id);
                                  handleSkillChange(index, 'name', selectedSkill.name);
                                }
                              }} 
                              className="w-full text-sm border-b focus:border-sea-400 outline-none bg-white"
                            >
                              <option value="">-- Chọn kỹ năng --</option>
                              {allSkills.map(s => (
                                <option key={s.id} value={s.id}>{s.name}</option>
                              ))}
                            </select>
                          </div>
                          <div className="col-span-2"><input type="number" min="0" value={skill.years} onChange={(e) => handleSkillChange(index, 'years', Math.max(0, e.target.value))} className="w-full text-sm border-b text-center focus:border-sea-400 outline-none" placeholder="Năm" /></div>
                          <div className="col-span-3">
                            <select value={skill.level} onChange={(e) => handleSkillChange(index, 'level', e.target.value)} className="w-full text-xs bg-transparent border-none outline-none">
                              <option value="BEGINNER">Beginner</option>
                              <option value="INTERMEDIATE">Intermediate</option>
                              <option value="ADVANCED">Advanced</option>
                              <option value="EXPERT">Expert</option>
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
                    <input 
                      type="text" 
                      name="fullName" 
                      value={profileData.fullName} 
                      onChange={handleChange} 
                      className="w-full pl-10 pr-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-sea-300 outline-none" 
                    />
                  </div>
                </div>
    
                <div>
                  <label className="block text-sm font-semibold text-gray-600 mb-1">Số điện thoại</label>
                  <div className="relative">
                    <FaPhone className="absolute left-3 top-3 text-gray-400" />
                    <input 
                      type="tel" 
                      name="phone" 
                      value={profileData.phone} 
                      onChange={(e) => {
                        const value = e.target.value.replace(/\D/g, '');
                        handleChange({ target: { name: 'phone', value } });
                      }} 
                      className="w-full pl-10 pr-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-sea-300 outline-none" 
                      placeholder="0123456789"
                    />
                  </div>
                </div>
                <div>
                  <label className="block text-sm font-semibold text-gray-600 mb-1">Địa chỉ</label>
                  
                  {/* Province and Ward Dropdowns */}
                  <div className="flex gap-2 mb-2">
                    <select 
                      className="w-1/2 px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-sea-300 outline-none text-sm"
                      value={addressParts.province}
                      onChange={handleProvinceChange}
                    >
                      <option value="">Tỉnh/Thành</option>
                      {provinces.map((p, index) => (
                        <option key={index} value={p.province}>{p.province}</option>
                      ))}
                    </select>

                    <select 
                      className="w-1/2 px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-sea-300 outline-none text-sm"
                      value={addressParts.ward}
                      onChange={handleWardChange}
                      disabled={!addressParts.province}
                    >
                      <option value="">Phường/Xã</option>
                      {wards.map((ward, index) => (
                        <option key={index} value={ward.name}>{ward.name}</option>
                      ))}
                    </select>
                  </div>
                  
                  {/* Detail Address Input */}
                  <div className="relative">
                    <FaMapMarkerAlt className="absolute left-3 top-3 text-gray-400" />
                    <input 
                      type="text" 
                      value={addressParts.detail} 
                      onChange={handleDetailAddressChange} 
                      className="w-full pl-10 pr-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-sea-300 outline-none" 
                      placeholder="Số nhà, tên đường..."
                    />
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
                  <div className="relative">
                    <input 
                      type={showPassword.old ? "text" : "password"} 
                      value={passwordData.oldPassword}
                      onChange={(e) => setPasswordData({...passwordData, oldPassword: e.target.value})}
                      className="w-full px-4 py-2 pr-10 border border-gray-300 rounded-lg focus:ring-2 focus:ring-sea-300 outline-none" 
                    />
                    <button
                      type="button"
                      onClick={() => setShowPassword({...showPassword, old: !showPassword.old})}
                      className="absolute right-3 top-1/2 -translate-y-1/2 text-gray-500 hover:text-gray-700"
                    >
                      {showPassword.old ? <FaEyeSlash /> : <FaEye />}
                    </button>
                  </div>
               </div>
               <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">Mật khẩu mới</label>
                  <div className="relative">
                    <input 
                      type={showPassword.new ? "text" : "password"} 
                      value={passwordData.newPassword}
                      onChange={(e) => setPasswordData({...passwordData, newPassword: e.target.value})}
                      className="w-full px-4 py-2 pr-10 border border-gray-300 rounded-lg focus:ring-2 focus:ring-sea-300 outline-none" 
                    />
                    <button
                      type="button"
                      onClick={() => setShowPassword({...showPassword, new: !showPassword.new})}
                      className="absolute right-3 top-1/2 -translate-y-1/2 text-gray-500 hover:text-gray-700"
                    >
                      {showPassword.new ? <FaEyeSlash /> : <FaEye />}
                    </button>
                  </div>
               </div>
               <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">Xác nhận mật khẩu mới</label>
                  <div className="relative">
                    <input 
                      type={showPassword.confirm ? "text" : "password"} 
                      value={passwordData.confirmPassword}
                      onChange={(e) => setPasswordData({...passwordData, confirmPassword: e.target.value})}
                      className="w-full px-4 py-2 pr-10 border border-gray-300 rounded-lg focus:ring-2 focus:ring-sea-300 outline-none" 
                    />
                    <button
                      type="button"
                      onClick={() => setShowPassword({...showPassword, confirm: !showPassword.confirm})}
                      className="absolute right-3 top-1/2 -translate-y-1/2 text-gray-500 hover:text-gray-700"
                    >
                      {showPassword.confirm ? <FaEyeSlash /> : <FaEye />}
                    </button>
                  </div>
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

export default Profile;
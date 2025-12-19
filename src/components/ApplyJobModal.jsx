// import { useEffect, useState } from "react";

// function ApplyJobModal({
//   open,
//   onClose,
//   jobTitle = "",
//   defaultCategory = "",
//   onSubmit,
// }) {
//   // trạng thái để animate đóng (không unmount ngay)
//   const [mounted, setMounted] = useState(open);

//   useEffect(() => {
//     if (open) setMounted(true);
//   }, [open]);

//   // ESC to close
//   useEffect(() => {
//     if (!open) return;
//     const handler = (e) => {
//       if (e.key === "Escape") onClose?.();
//     };
//     window.addEventListener("keydown", handler);
//     return () => window.removeEventListener("keydown", handler);
//   }, [open, onClose]);

//   // khoá scroll body khi mở modal
//   useEffect(() => {
//     if (!open) return;
//     const prev = document.body.style.overflow;
//     document.body.style.overflow = "hidden";
//     return () => {
//       document.body.style.overflow = prev;
//     };
//   }, [open]);

//   // Khi đóng: đợi animation xong mới unmount
//   useEffect(() => {
//     if (open) return;
//     if (!mounted) return;
//     const t = setTimeout(() => setMounted(false), 220);
//     return () => clearTimeout(t);
//   }, [open, mounted]);

//   if (!mounted) return null;

//   const stop = (e) => e.stopPropagation();

//   const handleSubmit = (e) => {
//     e.preventDefault();
//     const formData = new FormData(e.currentTarget);

//     const payload = {
//       categories: formData.get("categories") || "",
//       fullName: formData.get("fullName") || "",
//       email: formData.get("email") || "",
//       phone: formData.get("phone") || "",
//       note: formData.get("note") || "",
//       resumeFile: formData.get("resume") || null,
//     };

//     onSubmit?.(payload);
//   };

//   // class theo trạng thái open/close
//   const backdropClass = open ? "opacity-100" : "opacity-0";
//   const panelClass = open
//     ? "opacity-100 translate-y-0"
//     : "opacity-0 -translate-y-6";

//   return (
//     <div
//       className="fixed inset-0 z-50"
//       role="dialog"
//       aria-modal="true"
//       onClick={onClose}
//     >
//       {/* Backdrop fade */}
//       <div
//         className={`absolute inset-0 bg-black/40 transition-opacity duration-200 ${backdropClass}`}
//       />

//       {/* Center container */}
//       <div className="absolute inset-0 flex items-center justify-center px-4">
//         {/* Panel: from top -> center */}
//         <div
//           onClick={stop}
//           className={`
//             w-full max-w-2xl
//             bg-white rounded-xl shadow-lg
//             transform transition-all duration-200 ease-out
//             ${panelClass}
//           `}
//         >
//           {/* Header */}
//           <div className="flex items-center justify-between p-5 border-b">
//             <div>
//               <h2 className="text-lg font-semibold text-gray-800">
//                 Apply for this Job
//               </h2>
//               {jobTitle && (
//                 <p className="text-sm text-gray-500 mt-1">{jobTitle}</p>
//               )}
//             </div>

//             <button
//               type="button"
//               onClick={onClose}
//               className="w-9 h-9 rounded-full hover:bg-gray-100 flex items-center justify-center text-gray-600"
//               aria-label="Close"
//             >
//               ✕
//             </button>
//           </div>

//           {/* Body */}
//           <div className="p-5">
//             <form className="space-y-4" onSubmit={handleSubmit}>
//               {/* Categories */}
//               <div>
//                 <label className="block text-md font-medium mb-1 text-gray-700">
//                   Categories:
//                 </label>
//                 <input
//                   name="categories"
//                   type="text"
//                   defaultValue={defaultCategory}
//                   placeholder="Web Designer"
//                   className="w-full border border-gray-300 rounded px-3 py-2 text-gray-600 focus:outline-none focus:ring-1 focus:ring-sea-200"
//                 />
//               </div>

//               {/* Name */}
//               <div>
//                 <label className="block text-md font-medium mb-1 text-gray-700">
//                   Your name:
//                 </label>
//                 <input
//                   name="fullName"
//                   type="text"
//                   placeholder="A Nguyen Van"
//                   className="w-full border border-gray-300 rounded px-3 py-2 text-gray-600 focus:outline-none focus:ring-1 focus:ring-sea-200"
//                 />
//               </div>

//               {/* Email */}
//               <div>
//                 <label className="block text-md font-medium mb-1 text-gray-700">
//                   Email:
//                 </label>
//                 <input
//                   name="email"
//                   type="email"
//                   placeholder="nguyenvana@gmail.com"
//                   className="w-full border border-gray-300 rounded px-3 py-2 text-gray-600 focus:outline-none focus:ring-1 focus:ring-sea-200"
//                 />
//               </div>

//               {/* Phone */}
//               <div>
//                 <label className="block text-md font-medium mb-1 text-gray-700">
//                   Phone No.:
//                 </label>
//                 <input
//                   name="phone"
//                   type="tel"
//                   placeholder="Phone number"
//                   className="w-full border border-gray-300 rounded px-3 py-2 text-gray-600 focus:outline-none focus:ring-1 focus:ring-sea-200"
//                 />
//               </div>

//               {/* Note */}
//               <div>
//                 <label className="block text-md font-medium mb-1 text-gray-700">
//                   Note:
//                 </label>
//                 <textarea
//                   name="note"
//                   placeholder="Note..."
//                   rows={3}
//                   className="w-full border border-gray-300 rounded px-3 py-2 text-gray-600 focus:outline-none focus:ring-1 focus:ring-sea-200"
//                 />
//               </div>

//               {/* Upload Resume */}
//               <div>
//                 <label className="block text-md font-medium mb-1 text-gray-700">
//                   Upload Resume:
//                 </label>
//                 <input
//                   name="resume"
//                   type="file"
//                   className="w-full border border-gray-300 rounded py-2 file:mr-4 file:py-2 file:px-4 file:rounded file:border-0 file:text-gray-600 cursor-pointer"
//                 />
//               </div>

//               {/* Actions */}
//               <div className="flex gap-3 pt-2">
//                 <button
//                   type="button"
//                   onClick={onClose}
//                   className="w-1/2 border border-gray-300 text-gray-700 px-6 py-2 rounded hover:bg-gray-50 transition-colors"
//                 >
//                   Cancel
//                 </button>

//                 <button
//                   type="submit"
//                   className="w-1/2 bg-sea-400 text-white px-6 py-2 rounded hover:bg-sea-300 transition-colors"
//                 >
//                   Apply
//                 </button>
//               </div>
//             </form>
//           </div>
//         </div>
//       </div>
//     </div>
//   );
// }

// export default ApplyJobModal;


// import { useEffect, useState, useRef } from "react";
// import { FaCloudUploadAlt, FaFilePdf } from "react-icons/fa"; // Giả sử bạn đang dùng react-icons, nếu không có thể bỏ icon

// function ApplyJobModal({
//   open,
//   onClose,
//   jobTitle = "",
//   jobId, // Thêm jobId nếu cần gửi kèm
//   onSubmit,
// }) {
//   // Trạng thái để animate đóng (không unmount ngay)
//   const [mounted, setMounted] = useState(open);
//   const [fileName, setFileName] = useState("");
//   const fileInputRef = useRef(null);

//   useEffect(() => {
//     if (open) setMounted(true);
//   }, [open]);

//   // ESC to close
//   useEffect(() => {
//     if (!open) return;
//     const handler = (e) => {
//       if (e.key === "Escape") onClose?.();
//     };
//     window.addEventListener("keydown", handler);
//     return () => window.removeEventListener("keydown", handler);
//   }, [open, onClose]);

//   // Khoá scroll body khi mở modal
//   useEffect(() => {
//     if (!open) return;
//     const prev = document.body.style.overflow;
//     document.body.style.overflow = "hidden";
//     return () => {
//       document.body.style.overflow = prev;
//     };
//   }, [open]);

//   // Khi đóng: đợi animation xong mới unmount
//   useEffect(() => {
//     if (open) return;
//     if (!mounted) return;
//     const t = setTimeout(() => setMounted(false), 220);
//     return () => clearTimeout(t);
//   }, [open, mounted]);

//   // Reset file name khi mở lại modal
//   useEffect(() => {
//     if (open) {
//       setFileName("");
//     }
//   }, [open]);

//   if (!mounted) return null;

//   const stop = (e) => e.stopPropagation();

//   // Xử lý khi chọn file
//   const handleFileChange = (e) => {
//     const file = e.target.files[0];
//     if (file) {
//       setFileName(file.name);
//     } else {
//       setFileName("");
//     }
//   };

//   // Trigger input file ẩn
//   const handleBrowseClick = () => {
//     fileInputRef.current?.click();
//   };

//   const handleSubmit = (e) => {
//     e.preventDefault();
//     const formData = new FormData(e.currentTarget);

//     // Payload khớp với yêu cầu API và Mobile UI
//     const payload = {
//       jobId: jobId, // Gửi kèm ID công việc nếu API cần
//       notes: formData.get("note") || "",
//       cv: formData.get("cv") || null, // API yêu cầu field là 'cv'
//     };

//     onSubmit?.(payload);
//   };

//   // Class theo trạng thái open/close
//   const backdropClass = open ? "opacity-100" : "opacity-0";
//   const panelClass = open
//     ? "opacity-100 translate-y-0"
//     : "opacity-0 -translate-y-6";

//   return (
//     <div
//       className="fixed inset-0 z-50 font-sans"
//       role="dialog"
//       aria-modal="true"
//       onClick={onClose}
//     >
//       {/* Backdrop fade */}
//       <div
//         className={`absolute inset-0 bg-black/50 transition-opacity duration-200 ${backdropClass}`}
//       />

//       {/* Center container */}
//       <div className="absolute inset-0 flex items-center justify-center px-4">
//         {/* Panel */}
//         <div
//           onClick={stop}
//           className={`
//             w-full max-w-lg
//             bg-white rounded-2xl shadow-xl overflow-hidden
//             transform transition-all duration-200 ease-out
//             ${panelClass}
//           `}
//         >
//           {/* Header */}
//           <div className="flex items-center justify-between p-5 border-b border-gray-100">
//             <div>
//               <h2 className="text-xl font-bold text-gray-800">
//                 Chi tiết công việc
//               </h2>
//               {jobTitle && (
//                 <p className="text-sm text-gray-500 mt-1">{jobTitle}</p>
//               )}
//             </div>

//             <button
//               type="button"
//               onClick={onClose}
//               className="w-8 h-8 rounded-full hover:bg-gray-100 flex items-center justify-center text-gray-500 transition-colors"
//               aria-label="Close"
//             >
//               ✕
//             </button>
//           </div>

//           {/* Body */}
//           <div className="p-6">
//             <h3 className="text-lg font-bold text-gray-800 mb-4">
//               Gửi ứng tuyển & CV
//             </h3>
            
//             <form className="space-y-6" onSubmit={handleSubmit}>
//               {/* Upload Resume Section - Giống Mobile */}
//               <div>
//                 <label className="block text-sm font-medium mb-2 text-gray-700">
//                   File CV (PDF, tùy chọn):
//                 </label>
                
//                 {/* Khu vực hiển thị tên file */}
//                 <div className="bg-gray-50 border border-gray-200 rounded-lg p-4 text-center mb-3 flex flex-col items-center justify-center min-h-[80px]">
//                    {fileName ? (
//                      <div className="flex items-center gap-2 text-sea-600 font-medium">
//                         <FaFilePdf /> {fileName}
//                      </div>
//                    ) : (
//                      <div className="flex items-center gap-2 text-gray-400">
//                        <FaCloudUploadAlt size={20}/>
//                        <span>Chưa có file nào được chọn</span>
//                      </div>
//                    )}
//                 </div>

//                 {/* Input file ẩn */}
//                 <input
//                   ref={fileInputRef}
//                   name="cv"
//                   type="file"
//                   accept=".pdf,.doc,.docx"
//                   onChange={handleFileChange}
//                   className="hidden"
//                 />

//                 {/* Nút bấm giả lập */}
//                 <button
//                   type="button"
//                   onClick={handleBrowseClick}
//                   className="w-full bg-slate-600 hover:bg-slate-700 text-white font-medium py-2.5 rounded-lg transition-colors flex items-center justify-center gap-2"
//                 >
//                   <FaCloudUploadAlt /> Chọn CV từ thiết bị
//                 </button>
//                 <p className="text-xs text-gray-400 mt-2">Hỗ trợ: PDF (Tối đa 5MB)</p>
//               </div>

//               {/* Note Section */}
//               <div>
//                 <label className="block text-sm font-medium mb-2 text-gray-700">
//                   Ghi chú (tuỳ chọn):
//                 </label>
//                 <textarea
//                   name="note"
//                   placeholder="Ví dụ: Tôi rất quan tâm đến vị trí này..."
//                   rows={4}
//                   className="w-full border border-gray-300 rounded-lg px-4 py-3 text-gray-700 placeholder-gray-400 focus:outline-none focus:ring-2 focus:ring-sea-200 resize-none"
//                 />
//               </div>

//               {/* Actions */}
//               <div className="flex gap-4 pt-2">
//                 <button
//                   type="button"
//                   onClick={onClose}
//                   className="flex-1 text-gray-600 font-medium px-6 py-3 rounded-lg hover:bg-gray-50 transition-colors"
//                 >
//                   Hủy
//                 </button>

//                 <button
//                   type="submit"
//                   className="flex-1 bg-slate-700 text-white font-bold px-6 py-3 rounded-lg hover:bg-slate-800 transition-colors shadow-sm"
//                 >
//                   Gửi ứng tuyển
//                 </button>
//               </div>
//             </form>
//           </div>
//         </div>
//       </div>
//     </div>
//   );
// }

// export default ApplyJobModal;

import { useEffect, useState, useRef } from "react";
import { FaCloudUploadAlt, FaFilePdf, FaTrash } from "react-icons/fa";

function ApplyJobModal({
  open,
  onClose,
  jobTitle = "",
  jobId, // ✅ 1. Nhận jobId từ props
  onSubmit,
}) {
  const [mounted, setMounted] = useState(open);
  const [fileName, setFileName] = useState("");
  const fileInputRef = useRef(null);

  // Debug: Kiểm tra xem jobId có nhận được không khi mở modal
  useEffect(() => {
    if (open) {
      console.log("Modal opened for Job ID:", jobId); 
      setMounted(true);
    }
  }, [open, jobId]);

  useEffect(() => {
    if (!open) return;
    const handler = (e) => {
      if (e.key === "Escape") onClose?.();
    };
    window.addEventListener("keydown", handler);
    return () => window.removeEventListener("keydown", handler);
  }, [open, onClose]);

  useEffect(() => {
    if (!open) return;
    const prev = document.body.style.overflow;
    document.body.style.overflow = "hidden";
    return () => {
      document.body.style.overflow = prev;
    };
  }, [open]);

  useEffect(() => {
    if (open) return;
    if (!mounted) return;
    const t = setTimeout(() => setMounted(false), 220);
    return () => clearTimeout(t);
  }, [open, mounted]);

  useEffect(() => {
    if (open) {
      setFileName(""); // Reset file khi mở lại
      if (fileInputRef.current) fileInputRef.current.value = "";
    }
  }, [open]);

  if (!mounted) return null;

  const stop = (e) => e.stopPropagation();

  const handleFileChange = (e) => {
    const file = e.target.files[0];
    if (file) {
      setFileName(file.name);
    } else {
      setFileName("");
    }
  };

  const handleBrowseClick = () => {
    fileInputRef.current?.click();
  };

  const handleRemoveFile = (e) => {
    e.stopPropagation();
    setFileName("");
    if (fileInputRef.current) fileInputRef.current.value = "";
  };

  const handleSubmit = (e) => {
    e.preventDefault();
    const formData = new FormData(e.currentTarget);

    const payload = {
      jobId: jobId, // ✅ 2. Đưa jobId vào payload
      notes: formData.get("note") || "",
      cv: formData.get("cv") || null,
    };

    onSubmit?.(payload);
  };

  const backdropClass = open ? "opacity-100" : "opacity-0";
  const panelClass = open
    ? "opacity-100 translate-y-0"
    : "opacity-0 -translate-y-6";

  return (
    <div
      className="fixed inset-0 z-50 font-sans flex items-center justify-center p-4"
      role="dialog"
      aria-modal="true"
      onClick={onClose}
    >
      {/* Backdrop */}
      <div
        className={`absolute inset-0 bg-black/60 transition-opacity duration-200 ${backdropClass}`}
      />

      {/* Modal Panel */}
      <div
        onClick={stop}
        className={`
          relative w-full max-w-[400px] 
          bg-white rounded-2xl shadow-2xl overflow-hidden
          transform transition-all duration-200 ease-out
          ${panelClass}
        `}
      >
        {/* Header giống Mobile */}
        <div className="pt-6 px-6 pb-2 text-center">
          <h2 className="text-xl font-bold text-gray-800">
            Gửi ứng tuyển & CV
          </h2>
          {jobTitle && (
            <p className="text-xs text-gray-500 mt-1 line-clamp-1">{jobTitle}</p>
          )}
        </div>

        {/* Body */}
        <div className="p-6">
          <form className="space-y-5" onSubmit={handleSubmit}>
            
            {/* 1. File Upload Section */}
            <div>
              <label className="block text-sm font-medium mb-2 text-gray-700">
                File CV (PDF, tùy chọn):
              </label>
              
              {/* Box hiển thị file (Màu xám nhạt) */}
              <div className="bg-gray-100 border border-gray-200 rounded-xl p-4 mb-3 flex flex-col items-center justify-center min-h-[80px]">
                 {fileName ? (
                   <div className="flex items-center justify-between w-full bg-white px-3 py-2 rounded border border-gray-200 shadow-sm">
                      <div className="flex items-center gap-2 overflow-hidden">
                        <FaFilePdf className="text-red-500 flex-shrink-0" /> 
                        <span className="text-sm text-gray-700 truncate">{fileName}</span>
                      </div>
                      <button type="button" onClick={handleRemoveFile} className="text-gray-400 hover:text-red-500 ml-2">
                        <FaTrash size={12}/>
                      </button>
                   </div>
                 ) : (
                   <div className="flex flex-col items-center gap-1 text-gray-400">
                     <FaCloudUploadAlt size={24}/>
                     <span className="text-xs">Chưa có file nào được chọn</span>
                   </div>
                 )}
              </div>

              {/* Nút Chọn CV (Màu xanh đậm giống ảnh) */}
              <input
                ref={fileInputRef}
                name="cv"
                type="file"
                accept=".pdf,.doc,.docx"
                onChange={handleFileChange}
                className="hidden"
              />
              <button
                type="button"
                onClick={handleBrowseClick}
                className="w-full bg-sea-400 hover:bg-sea-300 hover:cursor-pointer text-white font-semibold py-3 rounded-xl transition-colors flex items-center justify-center gap-2 shadow-sm text-sm"
              >
                <FaCloudUploadAlt size={16} /> Chọn CV từ thiết bị
              </button>
              <p className="text-[10px] text-gray-400 mt-1.5 text-center">Hỗ trợ: PDF (Tối đa 5MB)</p>
            </div>

            {/* 2. Note Section */}
            <div>
              <label className="block text-sm font-medium mb-2 text-gray-700">
                Ghi chú (tuỳ chọn):
              </label>
              <textarea
                name="note"
                placeholder="Ví dụ: Tôi rất quan tâm đến vị trí này..."
                rows={4}
                className="w-full border border-gray-300 rounded-xl px-4 py-3 text-sm text-gray-700 placeholder-gray-400 focus:outline-none focus:ring-2 focus:ring-blue-100 resize-none"
              />
            </div>

            {/* 3. Actions Footer */}
            <div className="flex gap-3 pt-2">
              <button
                type="button"
                onClick={onClose}
                className="flex-1 text-gray-500 font-semibold text-sm px-4 py-3 rounded-xl hover:bg-gray-50 transition-colors hover:cursor-pointer"
              >
                Hủy
              </button>

              <button
                type="submit"
                className="flex-1  text-white font-bold text-sm px-4 py-3 rounded-xl  transition-colors shadow-md bg-sea-400 hover:bg-sea-300 hover:cursor-pointer"
              >
                Gửi ứng tuyển
              </button>
            </div>
          </form>
        </div>
      </div>
    </div>
  );
}

export default ApplyJobModal;
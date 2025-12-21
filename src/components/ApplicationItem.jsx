import React from 'react';
import { formatTimeAgo } from '../utils/timeUtils';

const ApplicationItem = ({ application, onClick }) => {
  const { applicantInfo, jobTitle, status, appliedDate, cvFileUrl } = application;
  
  // Extract from applicantInfo
  const fullName = applicantInfo?.fullName || 'Ứng viên';
  const avatarUrl = applicantInfo?.avatarUrl;
  // Get initial for avatar fallback
  const initial = fullName[0]?.toUpperCase() || 'U';
  
  // Debug log
  console.log('Application cvFileUrl:', cvFileUrl);
  
  // Status mapping - matching backend enum
  const statusMap = {
    SUBMITTED: { label: 'Đã nộp', color: 'bg-blue-100 text-blue-800' },
    REVIEWED: { label: 'Đã xem', color: 'bg-purple-100 text-purple-800' },
    INTERVIEW: { label: 'Phỏng vấn', color: 'bg-yellow-100 text-yellow-800' },
    HIRED: { label: 'Đã tuyển', color: 'bg-green-100 text-green-800' },
    REJECTED: { label: 'Từ chối', color: 'bg-red-100 text-red-800' },
  };
  
  const statusInfo = statusMap[status] || statusMap.SUBMITTED;
  const timeAgo = formatTimeAgo(appliedDate);

  return (
    <div 
      onClick={onClick}
      className="flex items-center justify-between p-3 hover:bg-gray-50 rounded-lg transition cursor-pointer"
    >
      <div className="flex items-center gap-3">
        {/* Avatar - show image if available, otherwise show initial */}
        {avatarUrl ? (
          <img 
            src={avatarUrl} 
            alt={fullName}
            className="w-10 h-10 rounded-full object-cover border-2 border-emerald-100"
            onError={(e) => {
              // Fallback to initial if image fails to load
              e.target.style.display = 'none';
              e.target.nextSibling.style.display = 'flex';
            }}
          />
        ) : null}
        <div 
          className="w-10 h-10 rounded-full bg-emerald-100 flex items-center justify-center text-emerald-600 font-bold text-sm"
          style={{ display: avatarUrl ? 'none' : 'flex' }}
        >
          {initial}
        </div>
        
        <div>
          <p className="text-sm font-medium text-gray-900">{fullName}</p>
          <p className="text-xs text-gray-500">{jobTitle || 'Vị trí'}</p>
        </div>
      </div>
      <div className="text-right">
        <span className={`text-xs px-2 py-1 rounded-full font-medium ${statusInfo.color}`}>
          {statusInfo.label}
        </span>
        <p className="text-xs text-gray-400 mt-1">{timeAgo}</p>
      </div>
    </div>
  );
};

export default ApplicationItem;

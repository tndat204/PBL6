/**
 * Format a date string to relative time in Vietnamese
 * @param {string} dateString - ISO date string (e.g., "2025-01-15T10:30:00")
 * @returns {string} Formatted time (e.g., "10 phút trước", "2 giờ trước", "Hôm qua")
 */
export const formatTimeAgo = (dateString) => {
  if (!dateString) return 'Chưa rõ';
  
  try {
    const date = new Date(dateString);
    const now = new Date();
    const diffMs = now - date;
    
    // Check if date is in the future
    if (diffMs < 0) return 'Vừa xong';
    
    const diffMins = Math.floor(diffMs / 60000);
    const diffHours = Math.floor(diffMs / 3600000);
    const diffDays = Math.floor(diffMs / 86400000);
    
    if (diffMins < 1) {
      return 'Vừa xong';
    } else if (diffMins < 60) {
      return `${diffMins} phút trước`;
    } else if (diffHours < 24) {
      return `${diffHours} giờ trước`;
    } else if (diffDays === 1) {
      return 'Hôm qua';
    } else if (diffDays < 7) {
      return `${diffDays} ngày trước`;
    } else if (diffDays < 30) {
      const weeks = Math.floor(diffDays / 7);
      return `${weeks} tuần trước`;
    } else {
      // Format as date if older than 30 days
      return date.toLocaleDateString('vi-VN', {
        day: '2-digit',
        month: '2-digit',
        year: 'numeric'
      });
    }
  } catch (error) {
    console.error('Error formatting time:', error);
    return 'Chưa rõ';
  }
};

/**
 * Format date to Vietnamese format (DD/MM/YYYY)
 * @param {string} dateString - ISO date string
 * @returns {string} Formatted date (e.g., "15/01/2025")
 */
export const formatDate = (dateString) => {
  if (!dateString) return '';
  
  try {
    const date = new Date(dateString);
    return date.toLocaleDateString('vi-VN', {
      day: '2-digit',
      month: '2-digit',
      year: 'numeric'
    });
  } catch (error) {
    console.error('Error formatting date:', error);
    return '';
  }
};

/**
 * Format date to Vietnamese format with time (DD/MM/YYYY HH:mm)
 * @param {string} dateString - ISO date string
 * @returns {string} Formatted date with time (e.g., "15/01/2025 10:30")
 */
export const formatDateTime = (dateString) => {
  if (!dateString) return '';
  
  try {
    const date = new Date(dateString);
    return date.toLocaleString('vi-VN', {
      day: '2-digit',
      month: '2-digit',
      year: 'numeric',
      hour: '2-digit',
      minute: '2-digit'
    });
  } catch (error) {
    console.error('Error formatting datetime:', error);
    return '';
  }
};

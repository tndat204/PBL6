/**
 * Format number to Vietnamese currency format
 * Example: 1000000 -> "1.000.000"
 * @param {number} value - The number to format
 * @returns {string} Formatted number string
 */
export const formatCurrency = (value) => {
  if (value === null || value === undefined || isNaN(value)) {
    return '0';
  }
  
  return value.toLocaleString('vi-VN');
};

/**
 * Format salary range for display
 * @param {number} min - Minimum salary
 * @param {number} max - Maximum salary
 * @returns {string} Formatted salary range
 */
export const formatSalaryRange = (min, max) => {
  // Check if both are 0 or null/undefined
  if ((min === 0 || !min) && (max === 0 || !max)) {
    return 'Thương lượng';
  }
  
  if (min > 0 && (!max || max === 0)) {
    return `${formatCurrency(min)} VND`;
  }
  
  if ((!min || min === 0) && max > 0) {
    return `${formatCurrency(max)} VND`;
  }
  
  return `${formatCurrency(min)} - ${formatCurrency(max)} VND`;
};

/**
 * Format number to shortened version (K, M, B)
 * Example: 1000000 -> "1M"
 * @param {number} value - The number to format
 * @returns {string} Shortened number string
 */
export const formatShortNumber = (value) => {
  if (value === null || value === undefined || isNaN(value)) {
    return '0';
  }
  
  if (value >= 1000000000) {
    return (value / 1000000000).toFixed(1) + 'B';
  }
  if (value >= 1000000) {
    return (value / 1000000).toFixed(1) + 'M';
  }
  if (value >= 1000) {
    return (value / 1000).toFixed(1) + 'K';
  }
  
  return value.toString();
};

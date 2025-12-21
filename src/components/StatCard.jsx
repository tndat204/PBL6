import React from 'react';

const StatCard = ({ title, value, icon, bgLight, highlight = false }) => (
  <div className={`bg-white rounded-xl shadow-sm hover:shadow-md transition p-6 ${highlight ? 'ring-2 ring-emerald-500' : ''}`}>
    <div className="flex items-center justify-between">
      <div>
        <p className="text-xs text-slate-600 mb-1 uppercase">{title}</p>
        <p className="text-2xl font-bold text-slate-900">{value}</p>
      </div>
      <div className={`${bgLight} p-3 rounded-lg`}>
        {icon}
      </div>
    </div>
  </div>
);

export default StatCard;

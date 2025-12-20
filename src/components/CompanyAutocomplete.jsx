import React, { useState, useEffect, useRef } from 'react';
import { Building2, Plus, Check } from 'lucide-react';

const CompanyAutocomplete = ({ companies, value, taxCode, onChange, onSelect, placeholder }) => {
    const [isOpen, setIsOpen] = useState(false);
    const [filteredCompanies, setFilteredCompanies] = useState([]);
    const wrapperRef = useRef(null);

    // Filter companies based on input
    useEffect(() => {
        if (value && value.length > 0) {
            const filtered = companies.filter(company =>
                company.name.toLowerCase().includes(value.toLowerCase()) ||
                company.taxCode.includes(value)
            );
            setFilteredCompanies(filtered);
        } else {
            setFilteredCompanies(companies);
        }
    }, [value, companies]);

    // Close dropdown when clicking outside
    useEffect(() => {
        const handleClickOutside = (event) => {
            if (wrapperRef.current && !wrapperRef.current.contains(event.target)) {
                setIsOpen(false);
            }
        };
        document.addEventListener('mousedown', handleClickOutside);
        return () => document.removeEventListener('mousedown', handleClickOutside);
    }, []);

    const handleInputChange = (e) => {
        const newValue = e.target.value;
        onChange(newValue);
        setIsOpen(true);
    };

    const handleSelectCompany = (company) => {
        onSelect(company);
        setIsOpen(false);
    };

    const handleCreateNew = () => {
        // Keep current input value, just close dropdown
        setIsOpen(false);
    };

    // Check if current input matches an existing company
    const exactMatch = companies.find(
        c => c.name.toLowerCase() === value?.toLowerCase() && c.taxCode === taxCode
    );

    return (
        <div ref={wrapperRef} className="relative">
            {/* Input Field */}
            <div className="relative">
                <input
                    type="text"
                    value={value || ''}
                    onChange={handleInputChange}
                    onFocus={() => setIsOpen(true)}
                    placeholder={placeholder || "Gõ để tìm hoặc tạo mới..."}
                    className="w-full bg-gray-50 hover:bg-gray-100 focus:bg-white border border-transparent focus:border-blue-500 rounded-lg px-3 py-2 pr-10 text-gray-700 transition-all outline-none"
                />
                <Building2 className="absolute right-3 top-1/2 -translate-y-1/2 text-gray-400" size={18} />
            </div>

            {/* Dropdown */}
            {isOpen && (
                <div className="absolute z-50 w-full mt-1 bg-white border border-gray-200 rounded-lg shadow-lg max-h-60 overflow-y-auto">
                    {filteredCompanies.length > 0 ? (
                        <>
                            {/* Existing Companies */}
                            <div className="py-1">
                                <div className="px-3 py-2 text-xs font-semibold text-gray-500 uppercase tracking-wide">
                                    Công ty có sẵn
                                </div>
                                {filteredCompanies.map((company) => (
                                    <button
                                        key={company.id}
                                        type="button"
                                        onClick={() => handleSelectCompany(company)}
                                        className="w-full px-3 py-2 text-left hover:bg-blue-50 transition-colors flex items-center justify-between group"
                                    >
                                        <div className="flex-1">
                                            <div className="font-medium text-gray-800 group-hover:text-blue-600">
                                                {company.name}
                                            </div>
                                            <div className="text-xs text-gray-500">
                                                MST: {company.taxCode}
                                            </div>
                                        </div>
                                        {exactMatch?.id === company.id && (
                                            <Check className="text-green-500" size={16} />
                                        )}
                                    </button>
                                ))}
                            </div>

                            {/* Divider */}
                            {value && value.trim() && !exactMatch && (
                                <div className="border-t border-gray-200"></div>
                            )}
                        </>
                    ) : null}

                    {/* Create New Option */}
                    {value && value.trim() && !exactMatch && (
                        <button
                            type="button"
                            onClick={handleCreateNew}
                            className="w-full px-3 py-2 text-left hover:bg-green-50 transition-colors flex items-center gap-2 text-green-700 font-medium"
                        >
                            <Plus size={16} />
                            <span>Tạo mới: "{value}"</span>
                        </button>
                    )}

                    {/* Empty State */}
                    {filteredCompanies.length === 0 && (!value || !value.trim()) && (
                        <div className="px-3 py-4 text-center text-gray-500 text-sm">
                            Gõ tên công ty để tìm kiếm hoặc tạo mới
                        </div>
                    )}
                </div>
            )}

            {/* Helper Text */}
            {exactMatch && (
                <p className="text-xs text-green-600 mt-1 flex items-center gap-1">
                    <Check size={12} />
                    Sẽ thêm vào công ty có sẵn
                </p>
            )}
            {value && value.trim() && !exactMatch && (
                <p className="text-xs text-blue-600 mt-1 flex items-center gap-1">
                    <Plus size={12} />
                    Sẽ tạo công ty mới
                </p>
            )}
        </div>
    );
};

export default CompanyAutocomplete;

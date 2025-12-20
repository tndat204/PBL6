import { useState, useEffect } from "react";
import { useAuth } from "../hooks/useAuth";
import { companyService } from "../services";
import { Building2, Globe, Mail, Phone, MapPin } from "lucide-react";

export default function RecruiterCompanyManagement() {
  const { company: authCompany } = useAuth();
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);
  
  const [formData, setFormData] = useState({
    name: "",
    description: "",
    website: "",
    email: "",
    phone: "",
    address: "",
    logoUrl: "",
  });

  const [addressParts, setAddressParts] = useState({
    province: "",
    ward: "",
    detail: ""
  });

  const [provinces, setProvinces] = useState([]);
  const [wards, setWards] = useState([]);

  useEffect(() => {
    // Fetch provinces
    const fetchProvinces = async () => {
      try {
        const response = await fetch("https://vietnamlabs.com/api/vietnamprovince");
        const data = await response.json();
        if (data.success && data.data) {
          setProvinces(data.data);
        }
      } catch (error) {
        console.error("Error fetching provinces:", error);
      }
    };
    fetchProvinces();
  }, []);

  useEffect(() => {
    if (authCompany?.id) {
      fetchCompanyData();
    }
  }, [authCompany]);

  const fetchCompanyData = async () => {
    try {
      setLoading(true);
      const data = await companyService.getCompanyById(authCompany.id);
      setFormData({
        name: data.name || "",
        description: data.description || "",
        website: data.website || "",
        email: data.email || "",
        phone: data.phone || "",
        address: data.address || "",
        logoUrl: data.logoUrl || "",
      });
    } catch (error) {
      console.error("Error fetching company:", error);
    } finally {
      setLoading(false);
    }
  };

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
            console.error("Error fetching wards:", error);
        }
    }
  };

  const handleWardChange = (e) => {
      setAddressParts(prev => ({ ...prev, ward: e.target.value }));
  };

  const handleDetailAddressChange = (e) => {
      setAddressParts(prev => ({ ...prev, detail: e.target.value }));
  };

  const handleChange = (e) => {
    const { name, value } = e.target;
    setFormData((prev) => ({ ...prev, [name]: value }));
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    
    // Validate address if parts are filled
    let fullAddress = formData.address;
    if (addressParts.province && addressParts.ward && addressParts.detail) {
      fullAddress = `${addressParts.detail}, ${addressParts.ward}, ${addressParts.province}`;
    }

    setSaving(true);
    try {
      const updateData = {
        ...formData,
        address: fullAddress,
      };
      
      await companyService.updateCompany(authCompany.id, updateData);
      alert("Cập nhật thông tin công ty thành công!");
      fetchCompanyData();
    } catch (error) {
      console.error("Error updating company:", error);
      alert("Không thể cập nhật thông tin công ty!");
    } finally {
      setSaving(false);
    }
  };

  if (loading) {
    return (
      <div className="flex items-center justify-center min-h-screen">
        <div className="animate-spin rounded-full h-12 w-12 border-4 border-emerald-500 border-t-transparent"></div>
      </div>
    );
  }

  return (
    <div>
      <div className="mb-6">
        <h1 className="text-2xl font-bold text-gray-900">Quản lý Công Ty</h1>
        <p className="text-gray-600 mt-1">Chỉnh sửa thông tin công ty của bạn</p>
      </div>

      <form onSubmit={handleSubmit} className="bg-white rounded-lg shadow-sm p-6 space-y-6">
        {/* Company Name */}
        <div>
          <label className="block text-sm font-medium text-gray-700 mb-2">
            <Building2 className="inline mr-2" size={18} />
            Tên công ty
          </label>
          <input
            type="text"
            name="name"
            value={formData.name}
            onChange={handleChange}
            className="w-full border border-gray-300 rounded-lg px-4 py-2 focus:ring-2 focus:ring-emerald-500 outline-none"
            required
          />
        </div>

        {/* Description */}
        <div>
          <label className="block text-sm font-medium text-gray-700 mb-2">
            Mô tả công ty
          </label>
          <textarea
            name="description"
            value={formData.description}
            onChange={handleChange}
            rows={4}
            className="w-full border border-gray-300 rounded-lg px-4 py-2 focus:ring-2 focus:ring-emerald-500 outline-none"
          />
        </div>

        {/* Contact Info */}
        <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">
              <Globe className="inline mr-2" size={18} />
              Website
            </label>
            <input
              type="url"
              name="website"
              value={formData.website}
              onChange={handleChange}
              className="w-full border border-gray-300 rounded-lg px-4 py-2 focus:ring-2 focus:ring-emerald-500 outline-none"
            />
          </div>

          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">
              <Mail className="inline mr-2" size={18} />
              Email
            </label>
            <input
              type="email"
              name="email"
              value={formData.email}
              onChange={handleChange}
              className="w-full border border-gray-300 rounded-lg px-4 py-2 focus:ring-2 focus:ring-emerald-500 outline-none"
            />
          </div>

          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">
              <Phone className="inline mr-2" size={18} />
              Số điện thoại
            </label>
            <input
              type="tel"
              name="phone"
              value={formData.phone}
              onChange={handleChange}
              className="w-full border border-gray-300 rounded-lg px-4 py-2 focus:ring-2 focus:ring-emerald-500 outline-none"
            />
          </div>
        </div>

        {/* Address */}
        <div>
          <label className="block text-sm font-medium text-gray-700 mb-2">
            <MapPin className="inline mr-2" size={18} />
            Địa chỉ
          </label>
          
          <div className="space-y-3">
            <div className="flex gap-2">
              <select 
                className="w-1/2 border rounded-lg px-2 py-2 focus:ring-2 focus:ring-emerald-500 outline-none text-sm"
                value={addressParts.province}
                onChange={handleProvinceChange}
              >
                <option value="">Tỉnh/Thành</option>
                {provinces.map((p, index) => (
                  <option key={index} value={p.province}>{p.province}</option>
                ))}
              </select>

              <select 
                className="w-1/2 border rounded-lg px-2 py-2 focus:ring-2 focus:ring-emerald-500 outline-none text-sm"
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
            
            <div>
              <input
                type="text"
                placeholder="Số nhà, đường"
                value={addressParts.detail}
                onChange={handleDetailAddressChange}
                className="w-full pl-3 pr-2 py-2 border rounded-lg focus:ring-2 focus:ring-emerald-500 focus:outline-none text-sm"
              />
            </div>

            <p className="text-xs text-gray-500">Địa chỉ hiện tại: {formData.address || "Chưa có"}</p>
          </div>
        </div>

        {/* Submit Button */}
        <div className="flex justify-end gap-3">
          <button
            type="submit"
            disabled={saving}
            className="bg-emerald-600 text-white px-6 py-2 rounded-lg hover:bg-emerald-700 transition disabled:opacity-50 disabled:cursor-not-allowed"
          >
            {saving ? "Đang lưu..." : "Lưu thay đổi"}
          </button>
        </div>
      </form>
    </div>
  );
}

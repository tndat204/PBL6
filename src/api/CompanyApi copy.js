const BASE_URL = '/api/companies';
export const getCompanies = async (token) => {
    const res = await fetch(`${BASE_URL}`, {
        method: 'GET',
        headers: {
            'content-type': 'application/json',
            'authorization': `bearer ${token}`
        }
    });

    if (!res.ok) {
        const err = await res.json().catch(() => ({}));
        throw new Error(err?.message || 'Lỗi khi lấy danh sách công ty');
    }

    return res.json();
};

export const createCompany = async (payload, token) => {
    const res = await fetch(`${BASE_URL}`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
            'Authorization': `Bearer ${token}`
        },
        body: JSON.stringify(payload)
    });
    if (!res.ok) {
        const err = await res.json().catch(() => ({}));
        throw new Error(err?.message || 'Tạo công ty thất bại');
    }
    return res.json();
};

export const updateCompany = async (id, payload, token) => {
    const res = await fetch(`${BASE_URL}/${id}`, {
        method: 'PUT',
        headers: {
            'Content-Type': 'application/json',
            'Authorization': `Bearer ${token}`
        },
        body: JSON.stringify(payload)
    });
    if (!res.ok) {
        const err = await res.json().catch(() => ({}));
        throw new Error(err?.message || 'Cập nhật công ty thất bại');
    }
    return res.json();
};

export const deleteCompany = async (id, token) => {
    const res = await fetch(`${BASE_URL}/${id}`, {
        method: 'DELETE',
        headers: {
            'Authorization': `Bearer ${token}`,
            'Content-Type': 'application/json'
        }
    });
    if (!res.ok) {
        const err = await res.json().catch(() => ({}));
        throw new Error(err?.message || 'Xóa công ty thất bại');
    }
    return res.json();
};

export const activateCompany = async (id, token) => {
    const res = await fetch(`${BASE_URL}/activate/${id}`, {
        method: 'PUT',
        headers: { 'Authorization': `Bearer ${token}` }
    });
    if (!res.ok) throw new Error('Kích hoạt công ty thất bại');
};

export const deactivateCompany = async (id, token) => {
    const res = await fetch(`${BASE_URL}/deactivate/${id}`, {
        method: 'PUT',
        headers: { 'Authorization': `Bearer ${token}` }
    });
    if (!res.ok) throw new Error('Vô hiệu hóa công ty thất bại');
};

export const uploadCompanyLogo = async (companyId, file, token) => {
    const formData = new FormData();
    formData.append('file', file);

    const res = await fetch(`${BASE_URL}/logo/${companyId}`, {
        method: 'PUT',
        headers: { 'Authorization': `Bearer ${token}` },
        body: formData
    });

    if (!res.ok) throw new Error('Upload logo thất bại');
};

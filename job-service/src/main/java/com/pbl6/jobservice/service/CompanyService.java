package com.pbl6.jobservice.service;

import com.pbl6.jobservice.dto.request.CreateCompanyRequest;
import com.pbl6.jobservice.dto.request.UpdateCompanyRequest;
import com.pbl6.jobservice.dto.response.CompanyResponse;

import java.util.List;

public interface CompanyService {
    public CompanyResponse createCompany(CreateCompanyRequest request);
    public CompanyResponse updateCompany(String id,UpdateCompanyRequest request);
    public CompanyResponse getCompanyById(String id);
    public List<CompanyResponse> getAllCompanies();
    public void deleteCompanyById(String id);
}

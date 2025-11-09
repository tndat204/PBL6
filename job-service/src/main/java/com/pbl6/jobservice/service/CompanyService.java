package com.pbl6.jobservice.service;

import com.pbl6.jobservice.dto.request.CreateCompanyRequest;
import com.pbl6.jobservice.dto.request.UpdateCompanyRequest;
import com.pbl6.jobservice.dto.response.CompanyResponse;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.util.List;

public interface CompanyService {
    public CompanyResponse createCompany(CreateCompanyRequest request);
    public CompanyResponse updateCompany(String id,UpdateCompanyRequest request);
    public CompanyResponse getCompanyById(String id);
    public List<CompanyResponse> getAllCompanies();
    public void deleteCompanyById(String id);
    public void activateCompanyById(String id);
    public void deactivateCompanyById(String id);
    public String uploadLogo(MultipartFile file,String companyId);
    public CompanyResponse getMyCompany();
    public void toggleUserStatus(String companyId,String userId);
}

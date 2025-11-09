package com.pbl6.jobservice.controller;

import com.pbl6.jobservice.dto.request.CreateCompanyRequest;
import com.pbl6.jobservice.dto.request.UpdateCompanyRequest;
import com.pbl6.jobservice.dto.response.APIResponse;
import com.pbl6.jobservice.dto.response.CompanyResponse;
import com.pbl6.jobservice.service.CompanyService;
import lombok.AccessLevel;
import lombok.experimental.FieldDefaults;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;

@RestController
@RequestMapping("/api/companies")
@FieldDefaults(level= AccessLevel.PRIVATE,makeFinal=true)
public class CompanyController {
    CompanyService companyService;

    public CompanyController(CompanyService companyService) {
        this.companyService = companyService;
    }

    @PostMapping
    public APIResponse<CompanyResponse> createCompany(@RequestBody CreateCompanyRequest request){
        return APIResponse.<CompanyResponse>builder()
                .code(200)
                .result(companyService.createCompany(request))
                .build();
    }
    @GetMapping("/{id}")
    public APIResponse<CompanyResponse> getCompany(@PathVariable String id){
        return APIResponse.<CompanyResponse>builder()
                .code(200)
                .result(companyService.getCompanyById(id))
                .build();
    }
    @GetMapping
    public APIResponse<List<CompanyResponse>> getAllCompanies(){
        return APIResponse.<List<CompanyResponse>>builder()
                .code(200)
                .result(companyService.getAllCompanies())
                .build();
    }
    @PutMapping("/{id}")
    public APIResponse<CompanyResponse> updateCompany(@PathVariable String id, @RequestBody UpdateCompanyRequest request){
        return APIResponse.<CompanyResponse>builder()
                .code(200)
                .result(companyService.updateCompany(id,request))
                .build();
    }
    @DeleteMapping("/{id}")
    public APIResponse<String> deleteCompany(@PathVariable String id){
        companyService.deleteCompanyById(id);
        return APIResponse.<String>builder()
                .code(200)
                .result("Company deleted successfully")
                .build();
    }
    @PutMapping("/{id}/activate")
    public APIResponse<String> activateCompany(@PathVariable String id){
        companyService.activateCompanyById(id);
        return APIResponse.<String>builder()
                .code(200)
                .result("Company activated successfully")
                .build();
    }
    @PutMapping("/{id}/deactivate")
    public APIResponse<String> deactivateCompany(@PathVariable String id){
        companyService.deactivateCompanyById(id);
        return APIResponse.<String>builder()
                .code(200)
                .result("Company deactivated successfully")
                .build();
    }
    @PutMapping("/{companyId}/logo")
    public APIResponse<String> uploadLogo(MultipartFile file, @PathVariable String companyId){
        return APIResponse.<String>builder()
                .code(200)
                .result(companyService.uploadLogo(file,companyId))
                .build();
    }
    @GetMapping("/me")
    public APIResponse<CompanyResponse> getMyCompany(){
        return APIResponse.<CompanyResponse>builder()
                .code(200)
                .result(companyService.getMyCompany())
                .build();
    }
    @PatchMapping("/{companyId}/users/{userId}/status")
    public APIResponse<String> toggleUserStatus(@PathVariable String companyId,@PathVariable String userId){
        companyService.toggleUserStatus(companyId,userId);
        return APIResponse.<String>builder()
                .code(200)
                .result("User status changed successfully")
                .build();
    }

}

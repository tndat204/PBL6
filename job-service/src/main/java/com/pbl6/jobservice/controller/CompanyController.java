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
@RequestMapping("/api/job/company")
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
    @GetMapping("/all")
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
    @PutMapping("/activate/{id}")
    public APIResponse<String> activateCompany(@PathVariable String id){
        companyService.activateCompanyById(id);
        return APIResponse.<String>builder()
                .code(200)
                .result("Company activated successfully")
                .build();
    }
    @PutMapping("/deactivate/{id}")
    public APIResponse<String> deactivateCompany(@PathVariable String id){
        companyService.deactivateCompanyById(id);
        return APIResponse.<String>builder()
                .code(200)
                .result("Company deactivated successfully")
                .build();
    }
    @PutMapping("/logo/{companyId}")
    public APIResponse<String> uploadLogo(MultipartFile file, @PathVariable String companyId){
        return APIResponse.<String>builder()
                .code(200)
                .result(companyService.uploadLogo(file,companyId))
                .build();
    }
}

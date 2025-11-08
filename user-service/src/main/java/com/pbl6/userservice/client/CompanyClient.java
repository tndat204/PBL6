package com.pbl6.userservice.client;

import com.pbl6.userservice.configuration.FeignClientConfig;
import com.pbl6.userservice.dto.request.CreateCompanyRequest;
import com.pbl6.userservice.dto.response.APIResponse;
import com.pbl6.userservice.dto.response.CompanyResponse;
import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.web.bind.annotation.*;

@FeignClient(
        name = "job-service",
        path = "/api/companies",
        configuration = FeignClientConfig.class
)
public interface CompanyClient {
    @PostMapping
    public APIResponse<CompanyResponse> createCompany(@RequestBody CreateCompanyRequest request);
}

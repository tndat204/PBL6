package com.pbl6.userservice.client;

import com.pbl6.userservice.configuration.FeignClientConfig;
import com.pbl6.userservice.dto.request.CreateCompanyRequest;
import com.pbl6.userservice.dto.response.APIResponse;
import com.pbl6.userservice.dto.response.CompanyResponse;
import com.pbl6.userservice.dto.shared.ProfileRequest;
import com.pbl6.userservice.dto.shared.ProfileResponse;
import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.web.bind.annotation.*;

@FeignClient(
        name = "profile-service",
        path = "/api/profiles",
        configuration = FeignClientConfig.class
)
public interface ProfileClient {
    @PostMapping
    public APIResponse<ProfileResponse> createProfile(@RequestBody ProfileRequest profileRequest);
}
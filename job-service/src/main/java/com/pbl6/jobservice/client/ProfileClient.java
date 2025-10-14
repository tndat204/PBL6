package com.pbl6.jobservice.client;

import com.pbl6.jobservice.configuration.AuthenticationRequestInterceptor;
import com.pbl6.jobservice.dto.response.APIResponse;
import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.web.bind.annotation.GetMapping;

@FeignClient(
        name = "profile-service",
        path = "/api/profile",
        configuration = {AuthenticationRequestInterceptor.class}
)
public interface ProfileClient {
    @GetMapping("/cv")
    public APIResponse<String> getCv();
}

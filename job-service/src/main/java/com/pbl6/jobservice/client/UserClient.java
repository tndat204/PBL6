package com.pbl6.jobservice.client;

import com.pbl6.jobservice.configuration.AuthenticationRequestInterceptor;
import com.pbl6.jobservice.dto.response.APIResponse;
import com.pbl6.jobservice.dto.response.UserResponse;
import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;

@FeignClient(
        name = "user-service",
        path = "/api",
        configuration = {AuthenticationRequestInterceptor.class}
)
public interface UserClient {
    @GetMapping("/users/{id}")
    APIResponse<UserResponse> getUserById(@PathVariable String id);
    @GetMapping("/users/me")
    APIResponse<UserResponse> getMyInfo();
    @GetMapping("/internal//users/{id}")
    APIResponse<UserResponse> getPublicUserById(@PathVariable String id);
}

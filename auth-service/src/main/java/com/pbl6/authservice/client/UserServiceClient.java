package com.pbl6.authservice.client;

import com.pbl6.authservice.dto.UserDTO;
import com.pbl6.authservice.dto.response.APIResponse;
import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;

@FeignClient(name = "user-service",path="/api/user")
public interface UserServiceClient {
    @GetMapping("/by-email")
    APIResponse<UserDTO> getUserByEmail(@RequestParam("email") String email);
}

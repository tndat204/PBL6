package com.pbl6.authservice.client;

import com.pbl6.authservice.dto.ResetPasswordDTO;
import com.pbl6.authservice.dto.UserDTO;
import com.pbl6.authservice.dto.response.APIResponse;
import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.web.bind.annotation.*;

@FeignClient(name = "user-service",path="/internal/user")
public interface UserServiceClient {
    @GetMapping("/by-email")
    APIResponse<UserDTO> getUserByEmail(@RequestParam("email") String email);

    @GetMapping("/check-email")
    APIResponse<Boolean> checkEmail(@RequestParam("email") String email);

    @PostMapping("/reset-password")
    APIResponse<String> resetPassword(@RequestBody ResetPasswordDTO request);
}

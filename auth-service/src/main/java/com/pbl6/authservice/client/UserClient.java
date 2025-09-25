package com.pbl6.authservice.client;
import com.pbl6.authservice.configuration.AuthenticationRequestInterceptor;
import com.pbl6.authservice.dto.shared.APIResponse;
import com.pbl6.authservice.dto.shared.CreateUserRequest;
import com.pbl6.authservice.dto.shared.ResetPasswordRequest;
import com.pbl6.authservice.dto.shared.UserResponse;
import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.web.bind.annotation.*;

@FeignClient(name = "user-service",path="/api/user/internal",configuration = {AuthenticationRequestInterceptor.class})
public interface UserClient {
    @GetMapping("/by-email")
    APIResponse<UserResponse> getUserByEmail(@RequestParam("email") String email);

    @GetMapping("/check-email")
    APIResponse<Boolean> checkEmail(@RequestParam("email") String email);

    @PostMapping("/reset-password")
    APIResponse<String> resetPassword(@RequestBody ResetPasswordRequest request);

    @PostMapping("/register")
    APIResponse<UserResponse>  registerUser(@RequestBody CreateUserRequest request);
}

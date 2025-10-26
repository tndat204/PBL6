package com.pbl6.authservice.client;
import com.pbl6.authservice.configuration.AuthenticationRequestInterceptor;
import com.pbl6.authservice.dto.shared.APIResponse;
import com.pbl6.authservice.dto.shared.CreateUserRequest;
import com.pbl6.authservice.dto.shared.ResetPasswordRequest;
import com.pbl6.authservice.dto.shared.UserResponse;
import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.web.bind.annotation.*;

@FeignClient(name = "user-service",path="/api/internal/users",configuration = {AuthenticationRequestInterceptor.class})
public interface UserClient {
    @GetMapping("/email")
    APIResponse<UserResponse> getUserByEmail(@RequestParam("email") String email);

    @GetMapping("/email/exists")
    APIResponse<Boolean> checkEmail(@RequestParam("email") String email);

    @PostMapping("/password/reset")
    APIResponse<String> resetPassword(@RequestBody ResetPasswordRequest request);

    @PostMapping
    APIResponse<UserResponse>  registerUser(@RequestBody CreateUserRequest request);
}

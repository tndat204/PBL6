package com.pbl6.userservice.controller.internal;

import com.pbl6.userservice.dto.response.APIResponse;
import com.pbl6.userservice.dto.shared.*;
import com.pbl6.userservice.service.UserService;
import jakarta.validation.Valid;
import lombok.AccessLevel;
import lombok.experimental.FieldDefaults;
import org.springframework.web.bind.annotation.*;
@RestController
@RequestMapping("/api/internal/users")
@FieldDefaults(level= AccessLevel.PRIVATE,makeFinal=true)
public class UserInternalController {
    UserService userService;

    public UserInternalController(UserService userService) {
        this.userService = userService;
    }

    @PostMapping
    public APIResponse<UserResponse> register(@Valid @RequestBody CreateUserRequest request){
        return APIResponse.<UserResponse>builder()
                .code(200)
                .result(userService.register(request))
                .build();
    }

    @PostMapping("/login")
    public APIResponse<UserResponse> login(@Valid @RequestBody LoginRequest request){
        return APIResponse.<UserResponse>builder()
                .code(200)
                .result(userService.login(request))
                .build();
    }

    @GetMapping("/email")
    public APIResponse<UserResponse> getUserByEmail(@RequestParam("email") String email) {
        return APIResponse.<UserResponse>builder()
                .code(200)
                .result(userService.getUserByEmail(email))
                .build();
    }

    @GetMapping("/email/exists")
    public APIResponse<Boolean> checkEmail(@RequestParam("email") String email) {
        boolean exists = userService.existsByEmail(email);
        return APIResponse.<Boolean>builder()
                .code(200)
                .message("Check email successfully")
                .result(exists)
                .build();
    }

    @PostMapping("/password/reset")
    public APIResponse<String> resetPassword(@Valid @RequestBody ResetPasswordRequest request) {
        userService.resetPassword(request);
        return APIResponse.<String>builder()
                .code(200)
                .result("Reset password succesfully")
                .build();
    }
    @GetMapping("/{id}")
    public APIResponse<ReviewerInfoResponse> getReviewerById(@PathVariable String id) {
        return APIResponse.<ReviewerInfoResponse>builder()
                .code(200)
                .result(userService.getReviewerInfo(id))
                .build();
    }
}

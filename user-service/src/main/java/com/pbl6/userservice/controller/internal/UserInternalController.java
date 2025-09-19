package com.pbl6.userservice.controller.internal;

import com.pbl6.userservice.dto.request.ResetPasswordRequest;
import com.pbl6.userservice.dto.response.APIResponse;
import com.pbl6.userservice.dto.response.UserDTO;
import com.pbl6.userservice.service.UserService;
import lombok.AccessLevel;
import lombok.experimental.FieldDefaults;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/internal/user")
@FieldDefaults(level= AccessLevel.PRIVATE,makeFinal=true)
public class UserInternalController {
    UserService userService;

    public UserInternalController(UserService userService) {
        this.userService = userService;
    }

    @GetMapping("/by-email")
    public APIResponse<UserDTO> getUserByEmail(@RequestParam("email") String email) {
        return APIResponse.<UserDTO>builder()
                .code(200)
                .result(userService.getUserByEmail(email))
                .build();
    }

    @GetMapping("/check-email")
    public APIResponse<Boolean> checkEmail(@RequestParam("email") String email) {
        boolean exists = userService.existsByEmail(email);
        return APIResponse.<Boolean>builder()
                .code(200)
                .message("Check email successfully")
                .result(exists)
                .build();
    }

    @PostMapping("/reset-password")
    public APIResponse<String> resetPassword(@RequestBody ResetPasswordRequest request) {
        userService.resetPassword(request);
        return APIResponse.<String>builder()
                .code(200)
                .result("Reset password succesfully")
                .build();
    }
}

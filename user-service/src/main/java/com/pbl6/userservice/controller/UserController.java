package com.pbl6.userservice.controller;

import com.pbl6.userservice.dto.request.CreateUserRequest;
import com.pbl6.userservice.dto.request.ResetPasswordRequest;
import com.pbl6.userservice.dto.request.SendOTPRequest;
import com.pbl6.userservice.dto.request.VerifyOTPRequest;
import com.pbl6.userservice.dto.response.APIResponse;
import com.pbl6.userservice.dto.response.UserDTO;
import com.pbl6.userservice.dto.response.UserResponse;
import com.pbl6.userservice.service.UserService;
import jakarta.mail.MessagingException;
import lombok.AccessLevel;
import lombok.experimental.FieldDefaults;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.mail.MailException;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/user")
@FieldDefaults(level= AccessLevel.PRIVATE)
public class UserController {
    @Autowired
    UserService userService;
    @PostMapping("/add")
    public APIResponse<UserResponse> createUser(@RequestBody CreateUserRequest request){
        return APIResponse.<UserResponse>builder()
                .code(200)
                .result(userService.createUser(request))
                .build();
    }
    @GetMapping("/by-email")
    public APIResponse<UserDTO> getUserByEmail(@RequestParam("email") String email) {
        return APIResponse.<UserDTO>builder()
                .code(200)
                .result(userService.getUserByEmail(email))
                .build();
    }
    @PostMapping("/send-otp")
    public APIResponse<String> sendOTP(@RequestBody SendOTPRequest request) throws MailException, MessagingException {
        userService.sendOTP(request);
        return APIResponse.<String>builder()
                .code(200)
                .result("Send OTP Successful")
                .build();
    }

    @PostMapping("/verify-otp")
    public APIResponse<String> verifyOTP(@RequestBody VerifyOTPRequest request) {
        if (userService.verifyOtp(request))
            return APIResponse.<String>builder()
                    .code(200)
                    .result("Validate OTP Successful")
                    .build();
        return APIResponse.<String>builder()
                .code(400)
                .result("Invalid OTP")
                .build();
    }

    @PostMapping("/reset-password")
    public APIResponse<String> resetPassword(@RequestBody ResetPasswordRequest request) {
        userService.resetPassword(request);
        return APIResponse.<String>builder()
                .code(200)
                .result("Reset Password Successfully")
                .build();
    }
}

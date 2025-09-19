package com.pbl6.authservice.controller;

import com.pbl6.authservice.dto.request.SendOTPRequest;
import com.pbl6.authservice.dto.request.VerifyOTPRequest;
import com.pbl6.authservice.dto.response.APIResponse;
import com.pbl6.authservice.service.OTPService;
import lombok.AccessLevel;
import lombok.experimental.FieldDefaults;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/auth/otp")
@FieldDefaults(level = AccessLevel.PRIVATE,makeFinal=true)
public class OTPController {
    OTPService otpService;

    public OTPController(OTPService otpService) {
        this.otpService = otpService;
    }

    @PostMapping("/forgot-password")
    public APIResponse<String> sendOTP(@RequestBody SendOTPRequest request){
        otpService.sendOTP(request);
        return APIResponse.<String>builder()
                .code(200)
                .result("Send OTP successfully!")
                .build();
    }
    @PostMapping("/verify-otp")
    public APIResponse<String> verifyOTP(@RequestBody VerifyOTPRequest request) {
        return APIResponse.<String>builder()
                .code(200)
                .result(otpService.verifyOtp(request))
                .build();
    }

}

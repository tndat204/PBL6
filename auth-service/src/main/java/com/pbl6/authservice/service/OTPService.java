package com.pbl6.authservice.service;

import com.pbl6.authservice.dto.request.SendOTPRequest;
import com.pbl6.authservice.dto.request.VerifyOTPRequest;

public interface OTPService {
    public void sendOTP(SendOTPRequest request);
    public String verifyOtp(VerifyOTPRequest request);
}

package com.pbl6.authservice.service;

import com.pbl6.authservice.dto.request.SendMailRequest;
import com.pbl6.authservice.dto.request.VerifyOTPRequest;

public interface OTPService {
    public void sendOTP(SendMailRequest request);
    public String verifyOtp(VerifyOTPRequest request);
}

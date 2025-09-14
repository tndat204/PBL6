package com.pbl6.userservice.service;

import com.pbl6.userservice.dto.request.CreateUserRequest;
import com.pbl6.userservice.dto.request.ResetPasswordRequest;
import com.pbl6.userservice.dto.request.SendOTPRequest;
import com.pbl6.userservice.dto.request.VerifyOTPRequest;
import com.pbl6.userservice.dto.response.UserDTO;
import com.pbl6.userservice.dto.response.UserResponse;
import jakarta.mail.MessagingException;
import org.springframework.mail.MailException;

public interface UserService {
    public UserResponse createUser(CreateUserRequest createUserRequest);

    public UserDTO getUserByEmail(String email);

    public void sendOTP(SendOTPRequest request) throws MailException, MessagingException;

    public boolean verifyOtp(VerifyOTPRequest request);

    public void resetPassword(ResetPasswordRequest request);
}

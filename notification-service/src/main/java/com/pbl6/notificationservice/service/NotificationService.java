package com.pbl6.notificationservice.service;

import com.pbl6.notificationservice.dto.request.SendOTPRequest;
import jakarta.mail.MessagingException;
import org.springframework.mail.MailException;

public interface NotificationService {
    public void sendOTP(SendOTPRequest request) throws MailException, MessagingException;
}

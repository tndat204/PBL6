package com.pbl6.notificationservice.service;

import com.pbl6.notificationservice.dto.request.SendEmailRequest;
import com.pbl6.notificationservice.dto.response.EmailResponse;

public interface EmailService {
    EmailResponse sendEmail(SendEmailRequest request);
}

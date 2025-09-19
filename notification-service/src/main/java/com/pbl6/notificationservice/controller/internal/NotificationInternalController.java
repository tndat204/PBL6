package com.pbl6.notificationservice.controller.internal;

import com.pbl6.notificationservice.dto.request.SendOTPRequest;
import com.pbl6.notificationservice.dto.response.APIResponse;
import com.pbl6.notificationservice.service.NotificationService;
import jakarta.mail.MessagingException;
import lombok.AccessLevel;
import lombok.experimental.FieldDefaults;
import org.springframework.mail.MailException;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/internal/notification")
@FieldDefaults(level= AccessLevel.PRIVATE,makeFinal = true)
public class NotificationInternalController {
    NotificationService notificationService;

    public NotificationInternalController(NotificationService notificationService) {
        this.notificationService = notificationService;
    }

    @PostMapping("/send-otp")
    public APIResponse<String> sendOtp(@RequestBody SendOTPRequest request) throws MailException, MessagingException {
        notificationService.sendOTP(request);

        return APIResponse.<String>builder()
                .code(200)
                .message("OTP đã được gửi tới email: " + request.getEmail())
                .build();
    }
}

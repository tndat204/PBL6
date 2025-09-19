package com.pbl6.authservice.client;

import com.pbl6.authservice.dto.SendOTPDTO;
import com.pbl6.authservice.dto.response.APIResponse;
import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;

@FeignClient(name = "notification-service",path="/internal/notification")
public interface NotificationServiceClient {
    @PostMapping("/send-otp")
    public APIResponse<String> sendOtp(@RequestBody SendOTPDTO request);
}

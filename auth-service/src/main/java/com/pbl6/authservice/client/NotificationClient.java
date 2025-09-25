package com.pbl6.authservice.client;

import com.pbl6.authservice.configuration.AuthenticationRequestInterceptor;
import com.pbl6.authservice.dto.shared.APIResponse;
import com.pbl6.authservice.dto.shared.SendOTPRequest;
import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;

@FeignClient(name = "notification-service",path="/internal/notification",configuration = {AuthenticationRequestInterceptor.class})
public interface NotificationClient {
    @PostMapping("/send-otp")
    public APIResponse<String> sendOtp(@RequestBody SendOTPRequest request);
}

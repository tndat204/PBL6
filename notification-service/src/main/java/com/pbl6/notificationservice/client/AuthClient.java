package com.pbl6.notificationservice.client;

import com.pbl6.notificationservice.dto.shared.APIResponse;
import com.pbl6.notificationservice.dto.shared.IntrospectRequest;
import com.pbl6.notificationservice.dto.shared.IntrospectResponse;
import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;

@FeignClient(name = "auth-service",path="/api/auth")
public interface AuthClient {
    @PostMapping("/introspect")
    public APIResponse<IntrospectResponse> introspect(@RequestBody IntrospectRequest request);
}

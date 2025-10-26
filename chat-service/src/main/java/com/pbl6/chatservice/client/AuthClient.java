package com.pbl6.chatservice.client;

import com.pbl6.chatservice.dto.request.IntrospectRequest;
import com.pbl6.chatservice.dto.response.APIResponse;
import com.pbl6.chatservice.dto.response.IntrospectResponse;
import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;

@FeignClient(
        name = "auth-service",
        path = "/api/auth"
)
public interface AuthClient {
    @PostMapping("/introspect")
    public APIResponse<IntrospectResponse> introspect(@RequestBody IntrospectRequest request);
}

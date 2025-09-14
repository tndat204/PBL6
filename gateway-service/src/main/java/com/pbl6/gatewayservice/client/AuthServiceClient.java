package com.pbl6.gatewayservice.client;


import com.pbl6.gatewayservice.dto.IntrospectRequest;
import com.pbl6.gatewayservice.dto.IntrospectResponse;
import com.pbl6.gatewayservice.dto.response.APIResponse;
import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;

@FeignClient(name = "user-service",path="/api/user")
public interface AuthServiceClient {

    @PostMapping("/introspect")
    public APIResponse<IntrospectResponse> introspect(@RequestBody IntrospectRequest request);
}
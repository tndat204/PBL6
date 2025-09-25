package com.pbl6.gatewayservice.service;

import com.pbl6.gatewayservice.client.AuthClient;
import com.pbl6.gatewayservice.dto.shared.IntrospectRequest;
import com.pbl6.gatewayservice.dto.response.APIResponse;
import com.pbl6.gatewayservice.dto.shared.IntrospectResponse;
import lombok.AccessLevel;
import lombok.RequiredArgsConstructor;
import lombok.experimental.FieldDefaults;
import org.springframework.stereotype.Service;
import reactor.core.publisher.Mono;

@Service
@RequiredArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE, makeFinal = true)
public class AuthService {
    AuthClient authClient;

    public Mono<APIResponse<IntrospectResponse>> introspect(String token){
        return authClient.introspect(IntrospectRequest.builder()
                .token(token)
                .build());
    }
}
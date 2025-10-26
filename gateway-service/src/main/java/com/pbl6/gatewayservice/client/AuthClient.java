package com.pbl6.gatewayservice.client;

import com.pbl6.gatewayservice.dto.shared.IntrospectRequest;
import com.pbl6.gatewayservice.dto.response.APIResponse;
import com.pbl6.gatewayservice.dto.shared.IntrospectResponse;
import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.service.annotation.PostExchange;
import reactor.core.publisher.Mono;

public interface AuthClient {
    @PostExchange(url = "/introspect", contentType = MediaType.APPLICATION_JSON_VALUE)
    Mono<APIResponse<IntrospectResponse>> introspect(@RequestBody IntrospectRequest request);
}
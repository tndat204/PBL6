package com.pbl6.gatewayservice.config;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.pbl6.gatewayservice.dto.response.APIResponse;
import com.pbl6.gatewayservice.service.AuthService;
import lombok.AccessLevel;
import lombok.RequiredArgsConstructor;
import lombok.experimental.FieldDefaults;
import lombok.extern.slf4j.Slf4j;
import org.springframework.cloud.gateway.filter.GatewayFilterChain;
import org.springframework.cloud.gateway.filter.GlobalFilter;
import org.springframework.core.Ordered;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.server.reactive.ServerHttpResponse;
import org.springframework.stereotype.Component;
import org.springframework.util.CollectionUtils;
import org.springframework.web.server.ServerWebExchange;
import reactor.core.publisher.Mono;

import java.util.List;

@Component
@Slf4j
@RequiredArgsConstructor
@FieldDefaults(level = AccessLevel.PACKAGE, makeFinal = true)
public class AuthenticationFilter implements GlobalFilter, Ordered {

    AuthService authService;
    ObjectMapper objectMapper;

    List<String> publicEndpoints = List.of(
            "/api/auth/token",
            "/api/auth/google-web",
            "/api/auth/google-app",
            "/api/auth/logout",
            "/api/auth/refresh",
            "/api/auth/password/reset",
            "/api/auth/otp/password/send",
            "/api/internal/users",
            "/api/auth/otp/verify",
            "/api/categories",
            "/api/skills",
            "/api/jobs",
            "/api/companies",
            "/api/reviews"
    );

    @Override
    public Mono<Void> filter(ServerWebExchange exchange, GatewayFilterChain chain) {
        String path = exchange.getRequest().getURI().getPath();
        String method = exchange.getRequest().getMethod().name();
        // 🚀 Nếu request trùng public endpoint hoặc WebSocket thì bỏ qua filter
        boolean isPublic = publicEndpoints.stream().anyMatch(path::startsWith)
                || path.startsWith("/ws"); // <-- tất cả /ws/** là public


        if (path.startsWith("/api/internal/users") && !"POST".equalsIgnoreCase(method)) {
            isPublic = false;
        }

        if ((path.startsWith("/api/categories")
                || path.startsWith("/api/skills")
                || path.startsWith("/api/jobs")
                || path.startsWith("/api/companies")
                || path.startsWith("/api/reviews"))
                && !"GET".equalsIgnoreCase(method)) {
            isPublic = false;
        }

        if (isPublic) {
            return chain.filter(exchange);
        }

        List<String> authHeader = exchange.getRequest().getHeaders().get(HttpHeaders.AUTHORIZATION);
        if (CollectionUtils.isEmpty(authHeader)) {
            return unauthenticated(exchange.getResponse());
        }

        String token = authHeader.get(0).replace("Bearer ", "");
        log.info("Token: {}", token);

        return authService.introspect(token)
                .flatMap(introspectResponse -> {
                    if (introspectResponse.getResult().isValid()) {
                        return chain.filter(exchange);
                    } else {
                        log.error("Token isValid = false. Introspect response: {}", introspectResponse);
                        return unauthenticated(exchange.getResponse());
                    }
                })
                .onErrorResume(throwable -> {
                    log.error("LỖI GỌI AUTH SERVICE: ", throwable);
                    return unauthenticated(exchange.getResponse());
                });
    }

    @Override
    public int getOrder() {
        return -1;
    }

    private Mono<Void> unauthenticated(ServerHttpResponse response) {
        APIResponse<?> apiResponse = APIResponse.builder()
                .code(1401)
                .message("Unauthenticated")
                .build();

        String body;
        try {
            body = objectMapper.writeValueAsString(apiResponse);
        } catch (JsonProcessingException e) {
            throw new RuntimeException(e);
        }

        response.setStatusCode(HttpStatus.UNAUTHORIZED);
        response.getHeaders().set(HttpHeaders.CONTENT_TYPE, MediaType.APPLICATION_JSON_VALUE);

        return response.writeWith(Mono.just(response.bufferFactory().wrap(body.getBytes())));
    }
}

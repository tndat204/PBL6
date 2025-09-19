package com.pbl6.gatewayservice.filter;

import com.pbl6.gatewayservice.service.JwtService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.cloud.gateway.filter.GatewayFilter;
import org.springframework.cloud.gateway.filter.factory.AbstractGatewayFilterFactory;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.server.reactive.ServerHttpRequest;
import org.springframework.http.server.reactive.ServerHttpResponse;
import org.springframework.stereotype.Component;
import org.springframework.util.StringUtils;
import org.springframework.web.server.ServerWebExchange;
import reactor.core.publisher.Mono;

@Component
@Slf4j
public class JwtAuthenticationFilter extends AbstractGatewayFilterFactory<JwtAuthenticationFilter.Config> {

    private final JwtService jwtService;

    // ✅ Mảng public endpoints
    private static final String[] PUBLIC_ENDPOINTS = {
            "/api/auth/**",      // login, register, forgot password...
            "/api/user/add",
            "/actuator"        // health check
    };

    // Constructor injection
    public JwtAuthenticationFilter(JwtService jwtService) {
        super(Config.class);
        this.jwtService = jwtService;
    }

    // Lấy token từ header Authorization
    private String extractTokenFromRequest(ServerHttpRequest request) {
        String authHeader = request.getHeaders().getFirst(HttpHeaders.AUTHORIZATION);
        if (StringUtils.hasText(authHeader) && authHeader.startsWith("Bearer ")) {
            return authHeader.substring(7);
        }
        return null;
    }

    // Kiểm tra endpoint public không cần token
    private boolean isPublicEndpoint(String path) {
        for (String endpoint : PUBLIC_ENDPOINTS) {
            if (path.startsWith(endpoint)) {
                return true;
            }
        }
        return false;
    }

    // Xử lý 401 Unauthorized
    private Mono<Void> handleUnauthorized(ServerWebExchange exchange, String message) {
        ServerHttpResponse response = exchange.getResponse();
        response.setStatusCode(HttpStatus.UNAUTHORIZED);
        response.getHeaders().add(HttpHeaders.CONTENT_TYPE, "application/json");
        String body = String.format("{\"error\": \"%s\", \"status\": %d}", message, HttpStatus.UNAUTHORIZED.value());
        return response.writeWith(Mono.just(response.bufferFactory().wrap(body.getBytes())));
    }

    @Override
    public GatewayFilter apply(Config config) {
        return (exchange, chain) -> {
            String path = exchange.getRequest().getURI().getPath();

            // Bỏ qua endpoint public
            if (isPublicEndpoint(path)) {
                return chain.filter(exchange);
            }

            // Lấy token
            String token = extractTokenFromRequest(exchange.getRequest());
            if (!StringUtils.hasText(token)) {
                log.warn("Missing Authorization header");
                return handleUnauthorized(exchange, "Missing Authorization header");
            }

            // Validate token
            boolean valid;
            try {
                valid = jwtService.validateToken(token);
            } catch (Exception e) {
                log.error("Error validating token: {}", e.getMessage());
                return handleUnauthorized(exchange, "Invalid token");
            }

            if (!valid) {
                log.warn("Invalid token");
                return handleUnauthorized(exchange, "Invalid token");
            }

            // Token hợp lệ → cho request đi tiếp
            return chain.filter(exchange);
        };
    }

    // Config class rỗng, có thể mở rộng sau
    public static class Config {}
}

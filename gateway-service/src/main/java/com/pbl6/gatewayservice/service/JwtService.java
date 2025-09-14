package com.pbl6.gatewayservice.service;

public interface JwtService {
    public boolean validateToken(String token);
    String extractUsername(String token);
}

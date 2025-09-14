package com.pbl6.gatewayservice.service.impl;

import com.pbl6.gatewayservice.service.JwtService;
import io.jsonwebtoken.Claims;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.security.Keys;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import java.security.Key;

@Service
@Slf4j
public class JwtServiceImpl implements JwtService {

    private final Key key;

    public JwtServiceImpl(@Value("${jwt.secret}") String secret) {
        this.key = Keys.hmacShaKeyFor(secret.getBytes());
    }

    @Override
    public boolean validateToken(String token) {
        try {
            Jwts.parserBuilder()
                    .setSigningKey(key)
                    .build()
                    .parseClaimsJws(token); // Nếu parse OK thì token hợp lệ
            return true;
        } catch (Exception e) {
            log.error("Invalid JWT: {}", e.getMessage());
            return false;
        }
    }

    @Override
    public String extractUsername(String token) {
        try {
            Claims claims = Jwts.parserBuilder()
                    .setSigningKey(key)
                    .build()
                    .parseClaimsJws(token)
                    .getBody();
            return claims.getSubject(); // thường subject chứa username/email
        } catch (Exception e) {
            log.error("Error extracting username: {}", e.getMessage());
            return null;
        }
    }
}

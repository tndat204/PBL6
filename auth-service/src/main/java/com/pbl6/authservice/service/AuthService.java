package com.pbl6.authservice.service;

import com.nimbusds.jose.JOSEException;
import com.nimbusds.jwt.SignedJWT;
import com.pbl6.authservice.dto.UserDTO;
import com.pbl6.authservice.dto.request.*;
import com.pbl6.authservice.dto.response.AuthenticationResponse;
import com.pbl6.authservice.dto.response.IntrospectResponse;

import java.text.ParseException;

public interface AuthService {
    public AuthenticationResponse login(LoginRequest loginRequest);

    public void logout(LogoutRequest logoutRequest) throws ParseException, JOSEException;

    public String buildScope(UserDTO user);
    public IntrospectResponse introspect(IntrospectRequest introspectRequest) throws JOSEException, ParseException;
    public String generateToken(UserDTO user,Long expiration);

    public SignedJWT verifyToken(String token, boolean isRefreshToken) throws JOSEException, ParseException;

    public AuthenticationResponse refreshToken(RefreshTokenRequest refreshTokenRequest) throws JOSEException, ParseException;

    public void resetPassword(String authHeader, ResetPasswordRequest request);

}

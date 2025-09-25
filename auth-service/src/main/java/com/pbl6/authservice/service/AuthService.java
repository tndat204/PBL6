package com.pbl6.authservice.service;

import com.nimbusds.jose.JOSEException;
import com.nimbusds.jwt.SignedJWT;
import com.pbl6.authservice.dto.request.*;
import com.pbl6.authservice.dto.response.AuthenticationResponse;
import com.pbl6.authservice.dto.shared.IntrospectRequest;
import com.pbl6.authservice.dto.shared.IntrospectResponse;
import com.pbl6.authservice.dto.shared.UserResponse;


import java.text.ParseException;

public interface AuthService {
    public AuthenticationResponse login(LoginRequest loginRequest);

    public void logout(LogoutRequest logoutRequest) throws ParseException, JOSEException;

    public String buildScope(UserResponse user);
    public IntrospectResponse introspect(IntrospectRequest introspectRequest) throws JOSEException, ParseException;
    public String generateToken(UserResponse user,Long expiration);

    public SignedJWT verifyToken(String token, boolean isRefreshToken) throws JOSEException, ParseException;

    public AuthenticationResponse refreshToken(RefreshTokenRequest refreshTokenRequest) throws JOSEException, ParseException;

    public void resetPassword(NewPasswordRequest request);

    public AuthenticationResponse outboundAuthenticate(String code);

}

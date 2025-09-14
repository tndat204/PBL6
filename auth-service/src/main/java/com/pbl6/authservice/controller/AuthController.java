package com.pbl6.authservice.controller;

import com.nimbusds.jose.JOSEException;
import com.pbl6.authservice.dto.request.IntrospectRequest;
import com.pbl6.authservice.dto.request.LoginRequest;
import com.pbl6.authservice.dto.request.LogoutRequest;
import com.pbl6.authservice.dto.request.RefreshTokenRequest;
import com.pbl6.authservice.dto.response.APIResponse;
import com.pbl6.authservice.dto.response.AuthenticationResponse;
import com.pbl6.authservice.dto.response.IntrospectResponse;
import com.pbl6.authservice.service.AuthService;
import lombok.AccessLevel;
import lombok.experimental.FieldDefaults;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.text.ParseException;

@RestController
@RequestMapping("/api/auth")
@FieldDefaults(level= AccessLevel.PRIVATE)
public class AuthController {

    @Autowired
    AuthService authService;

    @PostMapping("/login")
    public APIResponse<AuthenticationResponse> login(@RequestBody LoginRequest request) {
        var result = authService.login(request);
        return APIResponse.<AuthenticationResponse>builder()
                .result(result)
                .code(200)
                .build();
    }

    @PostMapping("/logout")
    public APIResponse<String>  logout(@RequestBody LogoutRequest request) throws ParseException, JOSEException {
        authService.logout(request);
        return APIResponse.<String>builder()
                .result("Logout Successful")
                .code(200)
                .build();
    }
    @PostMapping("/refresh")
    APIResponse<AuthenticationResponse> refreshToken(@RequestBody RefreshTokenRequest request)
            throws ParseException, JOSEException {
        var result = authService.refreshToken(request);
        return APIResponse.<AuthenticationResponse>builder()
                .code(200)
                .result(result)
                .build();
    }
    @PostMapping("/verify")
    public APIResponse<IntrospectResponse> introspect(@RequestBody IntrospectRequest request)
            throws JOSEException, ParseException {
        var result = authService.introspect(request);
        return APIResponse.<IntrospectResponse>builder()
                .code(1000)
                .result(result)
                .build();
    }
}

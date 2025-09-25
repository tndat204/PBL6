package com.pbl6.authservice.controller;

import com.nimbusds.jose.JOSEException;
import com.pbl6.authservice.dto.request.*;
import com.pbl6.authservice.dto.response.AuthenticationResponse;
import com.pbl6.authservice.dto.shared.APIResponse;
import com.pbl6.authservice.dto.shared.IntrospectRequest;
import com.pbl6.authservice.dto.shared.IntrospectResponse;
import com.pbl6.authservice.service.AuthService;
import lombok.AccessLevel;
import lombok.experimental.FieldDefaults;
import org.springframework.web.bind.annotation.*;
import java.text.ParseException;

@RestController
@RequestMapping("/api/auth")
@FieldDefaults(level= AccessLevel.PRIVATE,makeFinal=true)
public class AuthController {

    AuthService authService;

    public AuthController(AuthService authService) {
        this.authService = authService;
    }

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
                .code(200)
                .result(result)
                .build();
    }

    @PostMapping("/reset-password")
    public APIResponse<String> resetPassword(@RequestBody NewPasswordRequest request){
        authService.resetPassword(request);
        return APIResponse.<String>builder()
                .code(200)
                .result("Reset Password Successful")
                .build();
    }

    @PostMapping("/outbound/authentication")
    APIResponse<AuthenticationResponse> outboundAuthenticate(@RequestParam("code") String code ){
        var result = authService.outboundAuthenticate(code);
        return APIResponse.<AuthenticationResponse>builder()
                .result(result)
                .code(200)
                .build();
    }
}

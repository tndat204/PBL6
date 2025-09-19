package com.pbl6.authservice.service.impl;

import com.nimbusds.jose.*;
import com.nimbusds.jose.crypto.MACSigner;
import com.nimbusds.jose.crypto.MACVerifier;
import com.nimbusds.jwt.JWTClaimsSet;
import com.nimbusds.jwt.SignedJWT;
import com.pbl6.authservice.client.UserServiceClient;
import com.pbl6.authservice.configuration.CustomJwtDecoder;
import com.pbl6.authservice.dto.ResetPasswordDTO;
import com.pbl6.authservice.dto.UserDTO;
import com.pbl6.authservice.dto.request.*;
import com.pbl6.authservice.dto.response.AuthenticationResponse;
import com.pbl6.authservice.dto.response.IntrospectResponse;
import com.pbl6.authservice.entity.InvalidatedToken;
import com.pbl6.authservice.exception.AppException;
import com.pbl6.authservice.exception.ErrorCode;
import com.pbl6.authservice.repository.InvalidatedTokenRepository;
import com.pbl6.authservice.service.AuthService;
import io.jsonwebtoken.JwtException;
import lombok.AccessLevel;
import lombok.RequiredArgsConstructor;
import lombok.experimental.FieldDefaults;
import lombok.experimental.NonFinal;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.security.oauth2.jwt.JwtDecoder;

import java.text.ParseException;
import java.time.Instant;
import java.time.temporal.ChronoUnit;
import java.util.Date;
import java.util.Optional;
import java.util.StringJoiner;
import java.util.UUID;

@Service
@FieldDefaults(level = AccessLevel.PRIVATE, makeFinal = true)
@RequiredArgsConstructor
@Slf4j
public class AuthServiceImpl implements AuthService {

    @NonFinal
    @Value("${jwt.secret}")
    protected String SIGN_KEY;

    @NonFinal
    @Value("${jwt.expiration}")
    protected long expiration;
    @NonFinal

    @Value("${jwt.refresh-duration}")
    protected long refreshDuration;

    PasswordEncoder passwordEncoder;
    InvalidatedTokenRepository invalidatedTokenRepository;
    UserServiceClient userServiceClient;
    CustomJwtDecoder  customJwtDecoder;

    // Lấy user bằng Feign
    public UserDTO getUserByEmail(String email) {
        try {
            return userServiceClient.getUserByEmail(email).getResult();
        } catch (Exception e) {
            log.error("Error fetching user info via Feign: {}", e.getMessage());
            throw new AppException(ErrorCode.UNAUTHENTICATED);
        }
    }


    @Override
    public AuthenticationResponse login(LoginRequest request) {
        // Gọi user-service lấy thông tin user theo email
        UserDTO user = Optional.ofNullable(
                userServiceClient.getUserByEmail(request.getEmail()).getResult()
        ).orElseThrow(() -> new AppException(ErrorCode.USER_NOT_FOUND));

        if (!passwordEncoder.matches(request.getPassword(), user.getPassword())) {
            throw new AppException(ErrorCode.WRONG_PASSWORD);
        }

        if (!user.isEnabled()) {
            throw new AppException(ErrorCode.DEACTIVE_ACCOUNT);
        }

        String token = generateToken(user, expiration);

        return AuthenticationResponse.builder()
                .token(token)
                .authenticated(true)
                .build();
    }


    @Override
    public void logout(LogoutRequest logoutRequest) throws ParseException, JOSEException {
        try {
            var signToken = verifyToken(logoutRequest.getToken(), true);

            String jit = signToken.getJWTClaimsSet().getJWTID();
            Date expiryTime = signToken.getJWTClaimsSet().getExpirationTime();

            InvalidatedToken invalidatedToken =
                    InvalidatedToken.builder().id(UUID.fromString(jit)).expiryTime(expiryTime).build();

            invalidatedTokenRepository.save(invalidatedToken);
        } catch (AppException exception) {
        }
    }

    @Override
    public String buildScope(UserDTO user) {
        StringJoiner stringJoiner = new StringJoiner(" ");
        if (user.getRoles() != null) {
            user.getRoles().forEach(role -> {
                stringJoiner.add("ROLE_" + role.getName());
                if (role.getPermissions() != null) {
                    role.getPermissions().forEach(permission -> stringJoiner.add(permission.getName()));
                }
            });
        }
        return stringJoiner.toString();
    }

    @Override
    public String generateToken(UserDTO user, Long expiration) {
        JWSHeader header = new JWSHeader(JWSAlgorithm.HS512);
        JWTClaimsSet jwtClaimsSet = new JWTClaimsSet.Builder()
                .subject(user.getEmail())
                .issuer("itjobhunt.com")
                .issueTime(new Date())
                .expirationTime(new Date(Instant.now().plus(expiration, ChronoUnit.SECONDS).toEpochMilli()))
                .jwtID(UUID.randomUUID().toString())
                .claim("scope", buildScope(user))
                .claim("userId", user.getId())
                .build();
        Payload payload = new Payload(jwtClaimsSet.toJSONObject());
        JWSObject jwsObject = new JWSObject(header, payload);
        try {
            jwsObject.sign(new MACSigner(SIGN_KEY.getBytes()));
            return jwsObject.serialize();
        } catch (JOSEException e) {
            throw new RuntimeException("Error generating token", e);
        }
    }

    @Override
    public IntrospectResponse introspect(IntrospectRequest introspectRequest) throws JOSEException, ParseException {
        var token = introspectRequest.getToken();
        boolean isValid = true;

        try {
            verifyToken(token, false);
        } catch (AppException e) {
            isValid = false;
        }

        return IntrospectResponse.builder().valid(isValid).build();
    }

    @Override
    public SignedJWT verifyToken(String token, boolean isRefreshToken) throws JOSEException, ParseException {
        JWSVerifier verifier = new MACVerifier(SIGN_KEY.getBytes());

        SignedJWT signedJWT = SignedJWT.parse(token);

        Date expiryTime = (isRefreshToken)
                ? new Date(signedJWT
                .getJWTClaimsSet()
                .getIssueTime()
                .toInstant()
                .plus(refreshDuration, ChronoUnit.SECONDS)
                .toEpochMilli())
                : signedJWT.getJWTClaimsSet().getExpirationTime();

        var verified = signedJWT.verify(verifier);

        if (!(verified && expiryTime.after(new Date()))) throw new AppException(ErrorCode.UNAUTHENTICATED);

        if (invalidatedTokenRepository.existsById(UUID.fromString(signedJWT.getJWTClaimsSet().getJWTID())))
            throw new AppException(ErrorCode.UNAUTHENTICATED);

        return signedJWT;
    }
    @Override
    public AuthenticationResponse refreshToken(RefreshTokenRequest refreshTokenRequest) throws JOSEException, ParseException {
        var signedJWT = verifyToken(refreshTokenRequest.getToken(), true);

        invalidatedTokenRepository.save(
                InvalidatedToken.builder()
                        .id(UUID.fromString(signedJWT.getJWTClaimsSet().getJWTID()))
                        .expiryTime(signedJWT.getJWTClaimsSet().getExpirationTime())
                        .build()
        );

        // Sử dụng Feign lấy user
        UserDTO user = getUserByEmail(signedJWT.getJWTClaimsSet().getSubject());

        String token = generateToken(user, refreshDuration);

        return AuthenticationResponse.builder()
                .token(token)
                .authenticated(true)
                .build();
    }

    @Override
    public void resetPassword(String authHeader, ResetPasswordRequest request) {
        // Log thông tin

        String token = authHeader.replace("Bearer ", "");
        Jwt jwt;
        try {
            jwt = customJwtDecoder.decode(token);
        } catch (JwtException e) {
            throw new AppException(ErrorCode.INVALID_TOKEN);
        }

        String type = (String) jwt.getClaims().get("type");
        if (!"RESET_PASSWORD".equals(type)) {
            throw new AppException(ErrorCode.INVALID_TOKEN);
        }
        String email = jwt.getSubject();
        ResetPasswordDTO resetPasswordDTO = new ResetPasswordDTO();
        resetPasswordDTO.setEmail(email);
        resetPasswordDTO.setNewPassword(request.getNewPassword());
        userServiceClient.resetPassword(resetPasswordDTO);
    }
}

package com.pbl6.authservice.service.impl;

import com.nimbusds.jose.*;
import com.nimbusds.jose.crypto.MACSigner;
import com.nimbusds.jwt.JWTClaimsSet;
import com.pbl6.authservice.client.UserClient;
import com.pbl6.authservice.dto.OTPInfo;
import com.pbl6.authservice.dto.request.SendMailRequest;
import com.pbl6.authservice.dto.request.VerifyOTPRequest;
import com.pbl6.authservice.exception.AppException;
import com.pbl6.authservice.exception.ErrorCode;
import com.pbl6.authservice.service.OTPService;
import com.pbl6.event.dto.NotificationEvent;
import lombok.AccessLevel;
import lombok.RequiredArgsConstructor;
import lombok.experimental.FieldDefaults;
import lombok.experimental.NonFinal;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.kafka.core.KafkaTemplate;
import org.springframework.stereotype.Service;

import java.time.Instant;
import java.time.temporal.ChronoUnit;
import java.util.*;

@Service
@FieldDefaults(level = AccessLevel.PRIVATE, makeFinal = true)
@RequiredArgsConstructor
@Slf4j
public class OTPServiceImpl implements OTPService {

    Map<String, OTPInfo> otpStore = new HashMap<>();

    UserClient userServiceClient;
    KafkaTemplate<String, Object> kafkaTemplate;
    @NonFinal
    @Value("${jwt.secret}")
    protected String SIGN_KEY;

    @NonFinal
    @Value("${jwt.reset-duration}") // default 5 phút
    long resetExpiration;

    @Override
    public void sendOTP(SendMailRequest request) {
        if (userServiceClient.checkEmail(request.getEmail()).getResult()) {
            otpStore.remove(request.getEmail());
            Random random = new Random();
            int otp = 100000 + random.nextInt(900000);
            otpStore.put(request.getEmail(), new OTPInfo(otp));
            NotificationEvent notificationEvent = NotificationEvent.builder()
                    .channel("EMAIL")
                    .recipient(request.getEmail())
                    .templateCode("otp_template")
                    .subject("Mã OTP của bạn")
                    .param(Map.of("otp", otp, "expire", 5))
                    .build();
            kafkaTemplate.send("notification-delivery", notificationEvent);
        } else {
            throw new AppException(ErrorCode.EMAIL_NOT_FOUND);
        }
    }

    @Override
    public String verifyOtp(VerifyOTPRequest request) {
        OTPInfo otpInfo = otpStore.get(request.getEmail());
        if (otpInfo != null && !otpInfo.isExpired() && otpInfo.getOtp().equals(request.getOtp())) {
            otpStore.remove(request.getEmail()); // xài xong thì remove
            return generateResetToken(request.getEmail(),resetExpiration);
        }
        throw new AppException(ErrorCode.INVALID_OTP);
    }

    private String generateResetToken(String email, Long expiration) {
        JWSHeader header = new JWSHeader(JWSAlgorithm.HS512);
        JWTClaimsSet jwtClaimsSet = new JWTClaimsSet.Builder()
                .subject(email)
                .issuer("itjobhunt.com")
                .issueTime(new Date())
                .expirationTime(new Date(Instant.now().plus(expiration, ChronoUnit.SECONDS).toEpochMilli()))
                .jwtID(UUID.randomUUID().toString())
                .claim("type", "RESET_PASSWORD")
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
}

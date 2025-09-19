package com.pbl6.authservice.dto;

import java.time.LocalDateTime;

import lombok.AccessLevel;
import lombok.Data;
import lombok.experimental.FieldDefaults;

@Data
@FieldDefaults(level = AccessLevel.PRIVATE)
public class OTPInfo {
    private String otp;
    private LocalDateTime sentTime;

    public OTPInfo(int otp) {
        this.otp = String.valueOf(otp);
        this.sentTime = LocalDateTime.now();
    }

    public boolean isExpired() {
        return sentTime.plusMinutes(5).isBefore(LocalDateTime.now());
    }
}

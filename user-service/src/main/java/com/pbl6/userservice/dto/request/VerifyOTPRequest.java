package com.pbl6.userservice.dto.request;

import lombok.AccessLevel;
import lombok.Data;
import lombok.experimental.FieldDefaults;

@Data
@FieldDefaults(level= AccessLevel.PRIVATE)
public class VerifyOTPRequest {
    String email;
    String otp;
}

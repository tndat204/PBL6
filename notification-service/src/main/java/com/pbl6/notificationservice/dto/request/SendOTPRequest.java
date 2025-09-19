package com.pbl6.notificationservice.dto.request;

import lombok.AccessLevel;
import lombok.Data;
import lombok.experimental.FieldDefaults;

@Data
@FieldDefaults(level= AccessLevel.PRIVATE)
public class SendOTPRequest {
    String email;
    int otp;
}

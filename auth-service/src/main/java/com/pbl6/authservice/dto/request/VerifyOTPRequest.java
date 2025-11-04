package com.pbl6.authservice.dto.request;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import lombok.AccessLevel;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.experimental.FieldDefaults;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
@FieldDefaults(level = AccessLevel.PRIVATE)
public class VerifyOTPRequest {
    @NotBlank(message = "Email không được để trống")
    @Email(message="Email không đúng định dạng")
    String email;
    @NotBlank(message = "OTP không được để trống")
    String otp;
}

package com.pbl6.authservice.dto;

import lombok.AccessLevel;
import lombok.Data;
import lombok.experimental.FieldDefaults;

@Data
@FieldDefaults(level= AccessLevel.PRIVATE)
public class ResetPasswordDTO {
    String email;
    String newPassword;
}

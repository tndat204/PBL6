package com.pbl6.userservice.dto.shared;

import com.pbl6.userservice.validation.ValidPassword;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import lombok.*;
import lombok.experimental.FieldDefaults;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
@FieldDefaults(level = AccessLevel.PRIVATE)
public class ResetPasswordRequest {
    @Email(message="Email không đúng định dạng")
    String email;
    @ValidPassword
    String newPassword;
}

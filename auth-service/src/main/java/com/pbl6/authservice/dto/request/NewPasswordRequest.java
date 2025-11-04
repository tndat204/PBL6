package com.pbl6.authservice.dto.request;

import com.pbl6.authservice.validation.ValidPassword;
import lombok.*;
import lombok.experimental.FieldDefaults;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
@FieldDefaults(level = AccessLevel.PRIVATE)
public class NewPasswordRequest {
    @ValidPassword
    String newPassword;
}

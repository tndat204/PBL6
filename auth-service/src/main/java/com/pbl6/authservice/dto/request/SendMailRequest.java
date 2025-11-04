package com.pbl6.authservice.dto.request;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import lombok.*;
import lombok.experimental.FieldDefaults;
import org.apache.hc.core5.http.Message;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
@FieldDefaults(level = AccessLevel.PRIVATE)
public class SendMailRequest {
    @Email(message="Email không đúng định dạng")
    @NotBlank(message = "Email không được để trống")
    String email;
}

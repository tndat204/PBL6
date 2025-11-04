package com.pbl6.userservice.dto.shared;
import com.fasterxml.jackson.annotation.JsonFormat;
import com.pbl6.userservice.validation.Adult;
import com.pbl6.userservice.validation.ValidPassword;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import lombok.*;
import lombok.experimental.FieldDefaults;

import java.util.Date;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
@FieldDefaults(level = AccessLevel.PRIVATE)
public class CreateUserRequest {
    @NotBlank(message = "Username không được để trống")
    String username;
    @ValidPassword
    String password;
    @NotBlank(message = "Email không được để trống")
    @Email(message = "Email không đúng định dạng")
    String email;
    String phone;
    String fullName;
    String address;
    String taxCode;
    String nameCompany;
    String avatarUrl;
    @Adult
    @JsonFormat(pattern = "yyyy-MM-dd")
    Date birthDate;
}

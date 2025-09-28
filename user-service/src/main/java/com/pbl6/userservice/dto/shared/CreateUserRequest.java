package com.pbl6.userservice.dto.shared;
import lombok.*;
import lombok.experimental.FieldDefaults;

import java.util.Date;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
@FieldDefaults(level = AccessLevel.PRIVATE)
public class CreateUserRequest {
    String username;
    String password;
    String email;
    String phone;
    String fullName;
    String address;
    String taxCode;
    String nameCompany;
    String avatarUrl;
    Date birthDate;
}

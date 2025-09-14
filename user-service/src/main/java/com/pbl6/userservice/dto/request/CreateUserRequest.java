package com.pbl6.userservice.dto.request;

import lombok.AccessLevel;
import lombok.Data;
import lombok.experimental.FieldDefaults;

import java.util.Date;

@Data
@FieldDefaults(level = AccessLevel.PRIVATE)
public class CreateUserRequest {
    String username;
    String password;
    String email;
    String phone;
    String address;
    Date birthDate;
}

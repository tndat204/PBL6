package com.pbl6.userservice.dto.response;

import lombok.AccessLevel;
import lombok.Data;
import lombok.experimental.FieldDefaults;

import java.util.HashSet;
import java.util.Set;

@Data
@FieldDefaults(level = AccessLevel.PRIVATE)
public class UserResponse {
    String email;
    String username;
    String password;
    Boolean isEnable;
    Set<RoleResponse> roles = new HashSet<>();
}

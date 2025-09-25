package com.pbl6.userservice.dto.shared;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.*;
import lombok.experimental.FieldDefaults;

import java.util.Set;
import java.util.UUID;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
@FieldDefaults(level = AccessLevel.PRIVATE)
public class UserResponse {
    UUID id;
    String username;
    String password;
    String email;
    String phone;
    String address;
    String fullName;
    @JsonProperty("isEnabled")
    Boolean enabled;
    Set<RoleResponse> roles;
}
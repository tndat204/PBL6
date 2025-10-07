package com.pbl6.authservice.dto.shared;

import java.util.Set;
import java.util.UUID;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.*;
import lombok.experimental.FieldDefaults;

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
    String avatarUrl;
    Set<RoleResponse> roles;
}
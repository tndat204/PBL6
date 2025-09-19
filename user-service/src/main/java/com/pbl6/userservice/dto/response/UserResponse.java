package com.pbl6.userservice.dto.response;

import com.fasterxml.jackson.annotation.JsonProperty;
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
    @JsonProperty("isEnabled")
    Boolean enabled;
    Set<RoleResponse> roles = new HashSet<>();
}

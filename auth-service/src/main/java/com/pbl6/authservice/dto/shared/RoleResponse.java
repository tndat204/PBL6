package com.pbl6.authservice.dto.shared;

import java.util.Set;

import com.pbl6.authservice.dto.shared.PermissionResponse;
import lombok.*;
import lombok.experimental.FieldDefaults;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
@FieldDefaults(level = AccessLevel.PRIVATE)
public class RoleResponse {
    String name;
    Set<PermissionResponse> permissions;
}
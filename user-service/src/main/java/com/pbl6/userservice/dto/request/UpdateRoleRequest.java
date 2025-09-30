package com.pbl6.userservice.dto.request;

import lombok.*;
import lombok.experimental.FieldDefaults;

import java.util.Set;
import java.util.UUID;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE)
public class UpdateRoleRequest {
    String name;
    Set<UUID> permissionIds;
}

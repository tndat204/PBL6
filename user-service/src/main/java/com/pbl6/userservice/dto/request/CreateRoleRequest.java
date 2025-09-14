package com.pbl6.userservice.dto.request;

import com.pbl6.userservice.entity.Permission;
import lombok.AccessLevel;
import lombok.Data;
import lombok.experimental.FieldDefaults;

import java.util.HashSet;
import java.util.Set;
import java.util.UUID;

@Data
@FieldDefaults(level= AccessLevel.PRIVATE)
public class CreateRoleRequest {
    String name;
    Set<UUID> permissionIds;
}

package com.pbl6.userservice.service;

import com.pbl6.userservice.dto.request.CreateRoleRequest;
import com.pbl6.userservice.dto.shared.RoleResponse;

public interface RoleService {
    public RoleResponse createRole(CreateRoleRequest createRoleRequest);
}

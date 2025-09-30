package com.pbl6.userservice.service;

import com.pbl6.userservice.dto.request.CreateRoleRequest;
import com.pbl6.userservice.dto.request.UpdateRoleRequest;
import com.pbl6.userservice.dto.shared.RoleResponse;

import java.util.List;

public interface RoleService {
    public RoleResponse createRole(CreateRoleRequest createRoleRequest);
    public List<RoleResponse> getRole(String id);
    public RoleResponse updateRole(String roleId,UpdateRoleRequest updateRoleRequest);
    public void deteleRole(String roleId);
}

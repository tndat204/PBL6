package com.pbl6.userservice.service;

import com.pbl6.userservice.dto.request.PermissionRequest;
import com.pbl6.userservice.dto.response.PermissionResponse;

import java.util.List;

public interface PermissionService {
    public PermissionResponse createPermission(PermissionRequest permissionRequest);
    public PermissionResponse updatePermission(String id,PermissionRequest permissionRequest);
    public void deletePermission(String id);
    public List<PermissionResponse > getPermission(String id);
}

package com.pbl6.userservice.service.impl;

import com.pbl6.userservice.dto.request.PermissionRequest;
import com.pbl6.userservice.dto.response.PermissionResponse;
import com.pbl6.userservice.entity.Permission;
import com.pbl6.userservice.exception.AppException;
import com.pbl6.userservice.exception.ErrorCode;
import com.pbl6.userservice.repository.PermissionRepository;
import com.pbl6.userservice.repository.RoleRepository;
import com.pbl6.userservice.service.PermissionService;
import lombok.AccessLevel;
import lombok.RequiredArgsConstructor;
import lombok.experimental.FieldDefaults;
import org.modelmapper.ModelMapper;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
@FieldDefaults(level = AccessLevel.PRIVATE,makeFinal=true)
@RequiredArgsConstructor
public class PermissionServiceImpl implements PermissionService {
    ModelMapper modelMapper;
    PermissionRepository permissionRepository;
    RoleRepository roleRepository;

    @PreAuthorize("hasRole('ADMIN')")
    public PermissionResponse createPermission(PermissionRequest permissionRequest) {
        Permission permission=new Permission();
        permission.setName(permissionRequest.getName());
        Permission savedPermission=permissionRepository.save(permission);
        return modelMapper.map(savedPermission,PermissionResponse.class);
    }

    @PreAuthorize("hasRole('ADMIN')")
    public PermissionResponse updatePermission(String id,PermissionRequest permissionRequest) {
        Permission permission = permissionRepository.findById(UUID.fromString(id))
                .orElseThrow(() -> new AppException(ErrorCode.PERMISSION_NOT_FOUND));
        permission.setName(permissionRequest.getName());
        Permission updated = permissionRepository.save(permission);
        return modelMapper.map(updated, PermissionResponse.class);
    }

    @PreAuthorize("hasRole('ADMIN')")
    public void deletePermission(String id) {
        Permission permission = permissionRepository.findById(UUID.fromString(id))
                .orElseThrow(() -> new AppException(ErrorCode.PERMISSION_NOT_FOUND));

        long count = roleRepository.countRolesWithPermission(UUID.fromString(id));
        if(count > 0) {
            throw new AppException(ErrorCode.PERMISSION_IN_USE);
        }
        permissionRepository.delete(permission);
    }

    @PreAuthorize("hasRole('ADMIN')")
    public List<PermissionResponse> getPermission(String id) {
        List<Permission> permissions;

        if (id == null || id.isEmpty()) {
            permissions = permissionRepository.findAll();
        } else {
            Optional<Permission> permission = permissionRepository.findById(UUID.fromString(id));
            if (permission.isEmpty()) {
                throw new AppException(ErrorCode.PERMISSION_NOT_FOUND);
            }
            permissions = List.of(permission.get());
        }

        return permissions.stream()
                .map(p -> modelMapper.map(p, PermissionResponse.class))
                .collect(Collectors.toList());
    }
}

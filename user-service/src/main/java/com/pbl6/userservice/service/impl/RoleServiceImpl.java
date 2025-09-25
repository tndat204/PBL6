package com.pbl6.userservice.service.impl;

import com.pbl6.userservice.dto.request.CreateRoleRequest;
import com.pbl6.userservice.dto.shared.RoleResponse;
import com.pbl6.userservice.entity.Permission;
import com.pbl6.userservice.entity.Role;
import com.pbl6.userservice.exception.AppException;
import com.pbl6.userservice.exception.ErrorCode;
import com.pbl6.userservice.repository.PermissionRepository;
import com.pbl6.userservice.repository.RoleRepository;
import com.pbl6.userservice.service.RoleService;
import lombok.AccessLevel;
import lombok.RequiredArgsConstructor;
import lombok.experimental.FieldDefaults;
import org.modelmapper.ModelMapper;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.stereotype.Service;

import java.util.HashSet;
import java.util.Set;

@Service
@FieldDefaults(level = AccessLevel.PRIVATE,makeFinal=true)
@RequiredArgsConstructor
public class RoleServiceImpl implements RoleService {

    ModelMapper modelMapper = new ModelMapper();
    RoleRepository roleRepository;
    PermissionRepository permissionRepository;
    @PreAuthorize("hasRole('ADMIN')")
    public RoleResponse createRole(CreateRoleRequest request) {
        if (roleRepository.existsByName(request.getName())) {
            throw new AppException(ErrorCode.USER_EXISTED);
        }
        Role role = new Role();
        role.setName(request.getName());

        if (request.getPermissionIds() != null && !request.getPermissionIds().isEmpty()) {
            Set<Permission> permissions = new HashSet<>(permissionRepository.findAllById(request.getPermissionIds()));
            role.setPermissions(permissions);
        }

        Role savedRole = roleRepository.save(role);

        return modelMapper.map(savedRole, RoleResponse.class);
    }
}

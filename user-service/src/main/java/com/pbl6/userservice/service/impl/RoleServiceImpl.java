package com.pbl6.userservice.service.impl;

import com.pbl6.userservice.dto.request.CreateRoleRequest;
import com.pbl6.userservice.dto.request.UpdateRoleRequest;
import com.pbl6.userservice.dto.shared.RoleResponse;
import com.pbl6.userservice.entity.Permission;
import com.pbl6.userservice.entity.Role;
import com.pbl6.userservice.exception.AppException;
import com.pbl6.userservice.exception.ErrorCode;
import com.pbl6.userservice.repository.PermissionRepository;
import com.pbl6.userservice.repository.RoleRepository;
import com.pbl6.userservice.repository.UserRepository;
import com.pbl6.userservice.service.RoleService;
import lombok.AccessLevel;
import lombok.RequiredArgsConstructor;
import lombok.experimental.FieldDefaults;
import org.modelmapper.ModelMapper;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.stereotype.Service;

import java.util.*;
import java.util.stream.Collectors;

@Service
@FieldDefaults(level = AccessLevel.PRIVATE,makeFinal=true)
@RequiredArgsConstructor
public class RoleServiceImpl implements RoleService {

    ModelMapper modelMapper = new ModelMapper();
    RoleRepository roleRepository;
    PermissionRepository permissionRepository;
    UserRepository userRepository;
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

    @PreAuthorize("hasRole('ADMIN')")
    public List<RoleResponse> getRole(String id) {
        List<Role> roles;

        if (id == null || id.isEmpty()) {
            roles = roleRepository.findAll();
        } else {
            Optional<Role> roleOptional = roleRepository.findById(UUID.fromString(id));
            if (roleOptional.isEmpty()) {
                throw new AppException(ErrorCode.ROLE_NOT_FOUND);
            }
            roles = List.of(roleOptional.get());
        }
        return roles.stream()
                .map(role -> modelMapper.map(role, RoleResponse.class))
                .toList();
    }

    @PreAuthorize("hasRole('ADMIN')")
    public RoleResponse updateRole(String roleId,UpdateRoleRequest updateRoleRequest) {
        Role role = roleRepository.findById(UUID.fromString(roleId))
                .orElseThrow(() -> new AppException(ErrorCode.ROLE_NOT_FOUND));

        role.setName(updateRoleRequest.getName());
        Set<Permission> permissions = new HashSet<>();
        if (updateRoleRequest.getPermissionIds() != null) {
            permissions = updateRoleRequest.getPermissionIds().stream()
                    .map(id -> permissionRepository.findById(id)
                            .orElseThrow(() -> new AppException(ErrorCode.PERMISSION_NOT_FOUND)))
                    .collect(Collectors.toSet());
        }
        role.setPermissions(permissions);
        Role updatedRole = roleRepository.save(role);
        return modelMapper.map(updatedRole, RoleResponse.class);
    }

    @PreAuthorize("hasRole('ADMIN')")
    public void deteleRole(String roleId) {
        Role role = roleRepository.findById(UUID.fromString(roleId))
                .orElseThrow(() -> new AppException(ErrorCode.ROLE_NOT_FOUND));
        long count = userRepository.countUsersWithRole(role.getId());
        if (count > 0) {
            throw new AppException(ErrorCode.ROLE_IN_USE);
        }
        roleRepository.delete(role);
    }

}

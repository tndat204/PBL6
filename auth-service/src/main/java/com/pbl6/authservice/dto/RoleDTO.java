package com.pbl6.authservice.dto;

import lombok.Data;

import java.util.List;

@Data
public class RoleDTO {
    private String name;
    private List<PermissionDTO> permissions;
}
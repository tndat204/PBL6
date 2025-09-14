package com.pbl6.userservice.controller;

import com.pbl6.userservice.dto.request.CreateRoleRequest;
import com.pbl6.userservice.dto.response.APIResponse;
import com.pbl6.userservice.dto.response.RoleResponse;
import com.pbl6.userservice.dto.response.UserResponse;
import com.pbl6.userservice.service.RoleService;
import lombok.AccessLevel;
import lombok.experimental.FieldDefaults;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/role")
@FieldDefaults(level= AccessLevel.PRIVATE)
public class RoleController {
    @Autowired
    RoleService roleService;

    @PostMapping("/add")
    APIResponse<RoleResponse> createRole(@RequestBody CreateRoleRequest request){
        return APIResponse.<RoleResponse>builder()
                .code(200)
                .result(roleService.createRole(request))
                .build();
    }
}

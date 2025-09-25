package com.pbl6.userservice.controller.external;

import com.pbl6.userservice.dto.request.CreateRoleRequest;
import com.pbl6.userservice.dto.response.APIResponse;
import com.pbl6.userservice.service.RoleService;
import lombok.AccessLevel;
import lombok.experimental.FieldDefaults;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import com.pbl6.userservice.dto.shared.RoleResponse;
@RestController
@RequestMapping("/api/role")
@FieldDefaults(level= AccessLevel.PRIVATE,makeFinal = true)
public class RoleController {
    RoleService roleService;

    public RoleController(RoleService roleService) {
        this.roleService = roleService;
    }

    @PostMapping("/add")
    APIResponse<RoleResponse> createRole(@RequestBody CreateRoleRequest request){
        return APIResponse.<RoleResponse>builder()
                .code(200)
                .result(roleService.createRole(request))
                .build();
    }
}

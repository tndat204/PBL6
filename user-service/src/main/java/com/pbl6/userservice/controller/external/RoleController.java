package com.pbl6.userservice.controller.external;

import com.pbl6.userservice.dto.request.CreateRoleRequest;
import com.pbl6.userservice.dto.request.UpdateRoleRequest;
import com.pbl6.userservice.dto.response.APIResponse;
import com.pbl6.userservice.service.RoleService;
import lombok.AccessLevel;
import lombok.experimental.FieldDefaults;
import org.springframework.web.bind.annotation.*;
import com.pbl6.userservice.dto.shared.RoleResponse;

import java.util.List;

@RestController
@RequestMapping("/api/user/role")
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
    @GetMapping
    APIResponse<List<RoleResponse>> getRole(@RequestParam(required = false) String id){
        return APIResponse.<List<RoleResponse>>builder()
                .code(200)
                .result(roleService.getRole(id))
                .build();
    }

    @PutMapping("/{roleId}")
    APIResponse<RoleResponse> updateRole(@PathVariable String roleId,@RequestBody UpdateRoleRequest request){
        return APIResponse.<RoleResponse>builder()
                .code(200)
                .result(roleService.updateRole(roleId,request))
                .build();
    }

    @DeleteMapping("/{roleId}")
    APIResponse<String> deleteRole(@PathVariable String roleId){
        roleService.deteleRole(roleId);
        return  APIResponse.<String>builder()
                .code(200)
                .result("Role Deleted Successfully")
                .build();
    }

}

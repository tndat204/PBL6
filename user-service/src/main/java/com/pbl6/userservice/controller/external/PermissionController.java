package com.pbl6.userservice.controller.external;

import com.pbl6.userservice.dto.request.PermissionRequest;
import com.pbl6.userservice.dto.response.APIResponse;
import com.pbl6.userservice.dto.response.PermissionResponse;
import com.pbl6.userservice.service.PermissionService;
import lombok.AccessLevel;
import lombok.experimental.FieldDefaults;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/permissions")
@FieldDefaults(level= AccessLevel.PRIVATE,makeFinal = true)
public class PermissionController {
    PermissionService permissionService;

    public PermissionController(PermissionService permissionService) {
        this.permissionService = permissionService;
    }

    @PostMapping
    APIResponse<PermissionResponse> createPermission(@RequestBody PermissionRequest request){
        return APIResponse.<PermissionResponse>builder()
                .code(200)
                .result(permissionService.createPermission(request))
                .build();
    }

    @GetMapping
    APIResponse<List<PermissionResponse>> getPermission(@RequestParam(required = false) String id){
        return APIResponse.<List<PermissionResponse>>builder()
                .code(200)
                .result(permissionService.getPermission(id))
                .build();
    }

    @PutMapping("/{id}")
    APIResponse<PermissionResponse> updatePermission(@PathVariable String id, @RequestBody PermissionRequest request){
        return APIResponse.<PermissionResponse>builder()
                .code(200)
                .result(permissionService.updatePermission(id, request))
                .build();
    }

    @DeleteMapping("/{id}")
    APIResponse<Void> deletePermission(@PathVariable String id){
        permissionService.deletePermission(id);
        return APIResponse.<Void>builder()
                .code(200)
                .build();
    }
}

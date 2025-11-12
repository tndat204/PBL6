package com.pbl6.userservice.controller.external;

import com.pbl6.userservice.dto.request.ChangePasswordRequest;
import com.pbl6.userservice.dto.request.UpdateUserRequest;
import com.pbl6.userservice.dto.response.APIResponse;
import com.pbl6.userservice.dto.shared.ResetPasswordRequest;
import com.pbl6.userservice.dto.shared.UserResponse;
import com.pbl6.userservice.service.UserService;
import lombok.AccessLevel;
import lombok.experimental.FieldDefaults;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;

@RestController
@RequestMapping("/api/users")
@FieldDefaults(level= AccessLevel.PRIVATE,makeFinal=true)
public class UserController {
    UserService userService;

    public UserController(UserService userService) {
        this.userService = userService;
    }

    @PostMapping("/password/reset")
    public APIResponse<String> resetPassword(@RequestBody ResetPasswordRequest request) {
        userService.resetPassword(request);
        return APIResponse.<String>builder()
                .code(200)
                .result("Reset Password Successfully")
                .build();
    }

    @GetMapping("/me")
    public APIResponse<UserResponse> getMyInfo() {
        return APIResponse.<UserResponse>builder()
                .code(200)
                .result(userService.getMyInfo())
                .build();
    }
    @GetMapping
    public APIResponse<List<UserResponse>> getAllUsers() {
        return APIResponse.<List<UserResponse>>builder()
                .code(200)
                .result(userService.getAllUsers())
                .build();
    }
    @GetMapping("/{id}")
    public APIResponse<UserResponse> getUserById(@PathVariable String id) {
        return APIResponse.<UserResponse>builder()
                .code(200)
                .result(userService.getUserById(id))
                .build();
    }
    @PutMapping("/{id}/status")
    public APIResponse<String> changeStatus(@PathVariable("id") String id){
        userService.changeStatus(id);
        return APIResponse.<String>builder()
                .code(200)
                .result("Change Status Successfully")
                .build();
    }
    @PutMapping("/me/avatar")
    public APIResponse<String> uploadAvatar(@RequestParam("file") MultipartFile file){
        return APIResponse.<String>builder()
                .code(200)
                .result(userService.uploadAvatar(file))
                .build();
    }
    @PatchMapping("/me")
    public APIResponse<UserResponse> updateMyInfo(@RequestBody UpdateUserRequest request){
        return APIResponse.<UserResponse>builder()
                .code(200)
                .result(userService.updateMyInfo(request))
                .build();
    }
    @DeleteMapping("/{id}")
    public APIResponse<String> deleteUser(@PathVariable String id){
        userService.deleteUser(id);
        return APIResponse.<String>builder()
                .code(200)
                .result("Delete User Successfully")
                .build();
    }
    @PutMapping("/{userId}/role/{roleId}")
    public APIResponse<String> upgradeRole(@PathVariable String userId, @PathVariable String roleId){
        userService.upgradeRole(userId,roleId);
        return APIResponse.<String>builder()
                .code(200)
                .result("Upgrade Role Successfully")
                .build();
    }
    @PutMapping("/me/password")
    public APIResponse<String> changePassword(@RequestBody ChangePasswordRequest request){
        userService.changePassword(request);
        return APIResponse.<String>builder()
                .code(200)
                .result("Change Password Successfully")
                .build();
    }
}

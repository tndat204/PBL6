package com.pbl6.userservice.controller.external;

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
@RequestMapping("/api/user")
@FieldDefaults(level= AccessLevel.PRIVATE,makeFinal=true)
public class UserController {
    UserService userService;

    public UserController(UserService userService) {
        this.userService = userService;
    }

    @PostMapping("/reset-password")
    public APIResponse<String> resetPassword(@RequestBody ResetPasswordRequest request) {
        userService.resetPassword(request);
        return APIResponse.<String>builder()
                .code(200)
                .result("Reset Password Successfully")
                .build();
    }

    @GetMapping("/my-info")
    public APIResponse<UserResponse> getMyInfo() {
        return APIResponse.<UserResponse>builder()
                .code(200)
                .result(userService.getMyInfo())
                .build();
    }
    @GetMapping("/all")
    public APIResponse<List<UserResponse>> getAllUsers() {
        return APIResponse.<List<UserResponse>>builder()
                .code(200)
                .result(userService.getAllUsers())
                .build();
    }
    @PutMapping("/change-status")
    public APIResponse<String> changeStatus(@RequestParam("id") String id){
        userService.changeStatus(id);
        return APIResponse.<String>builder()
                .code(200)
                .result("Change Status Successfully")
                .build();
    }
    @PutMapping("/upload-avatar")
    public APIResponse<String> uploadAvatar(@RequestParam("file") MultipartFile file){
        userService.uploadAvatar(file);
        return APIResponse.<String>builder()
                .code(200)
                .result("Upload Avatar Successfully")
                .build();
    }
}

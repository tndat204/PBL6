package com.pbl6.userservice.controller.external;

import com.pbl6.userservice.dto.request.CreateUserRequest;
import com.pbl6.userservice.dto.request.ResetPasswordRequest;
import com.pbl6.userservice.dto.response.APIResponse;
import com.pbl6.userservice.dto.response.UserDTO;
import com.pbl6.userservice.dto.response.UserResponse;
import com.pbl6.userservice.service.UserService;
import lombok.AccessLevel;
import lombok.experimental.FieldDefaults;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/user")
@FieldDefaults(level= AccessLevel.PRIVATE,makeFinal=true)
public class UserController {
    UserService userService;

    public UserController(UserService userService) {
        this.userService = userService;
    }
    @PostMapping("/add")
    public APIResponse<UserResponse> createUser(@RequestBody CreateUserRequest request){
        return APIResponse.<UserResponse>builder()
                .code(200)
                .result(userService.createUser(request))
                .build();
    }

    @PostMapping("/reset-password")
    public APIResponse<String> resetPassword(@RequestBody ResetPasswordRequest request) {
        userService.resetPassword(request);
        return APIResponse.<String>builder()
                .code(200)
                .result("Reset Password Successfully")
                .build();
    }
}

package com.pbl6.userservice.service;


import com.pbl6.userservice.dto.shared.CreateUserRequest;
import com.pbl6.userservice.dto.shared.ResetPasswordRequest;
import com.pbl6.userservice.dto.shared.UserResponse;

import java.util.List;

public interface UserService {
    public UserResponse register(CreateUserRequest createUserRequest);

    public UserResponse getUserByEmail(String email);

    public boolean existsByEmail(String email);

    public void resetPassword(ResetPasswordRequest request);

    public UserResponse getMyInfo();

    public List<UserResponse> getAllUsers();
}

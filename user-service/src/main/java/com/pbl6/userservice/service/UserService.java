package com.pbl6.userservice.service;

import com.pbl6.userservice.dto.request.CreateUserRequest;
import com.pbl6.userservice.dto.request.ResetPasswordRequest;
import com.pbl6.userservice.dto.response.UserDTO;
import com.pbl6.userservice.dto.response.UserResponse;

public interface UserService {
    public UserResponse createUser(CreateUserRequest createUserRequest);

    public UserDTO getUserByEmail(String email);

    public boolean existsByEmail(String email);

    public void resetPassword(ResetPasswordRequest request);
}

package com.pbl6.userservice.service;


import com.pbl6.userservice.dto.request.ChangePasswordRequest;
import com.pbl6.userservice.dto.request.UpdateUserRequest;
import com.pbl6.userservice.dto.shared.*;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;

public interface UserService {
    public UserResponse register(CreateUserRequest createUserRequest);

    public UserResponse getUserByEmail(String email);

    public boolean existsByEmail(String email);

    public void resetPassword(ResetPasswordRequest request);

    public UserResponse getMyInfo();

    public List<UserResponse> getAllUsers();

    public ReviewerInfoResponse getReviewerInfo(String reviewerId);

    public void changeStatus(String id);

    public String uploadAvatar(MultipartFile file);

    public UserResponse updateMyInfo(UpdateUserRequest request);

    public void deleteUser(String id);

    public void upgradeRole(String userId,String roleId);

    public UserResponse updateUser(String userId,UpdateUserRequest request);
    public void changePassword(ChangePasswordRequest request);
    public UserResponse getUserById(String id);
    public UserResponse login(LoginRequest request);
}

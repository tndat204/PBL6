package com.pbl6.userservice.service.impl;

import com.pbl6.userservice.dto.shared.CreateUserRequest;
import com.pbl6.userservice.dto.shared.ResetPasswordRequest;
import com.pbl6.userservice.dto.shared.UserResponse;
import com.pbl6.userservice.entity.User;
import com.pbl6.userservice.exception.AppException;
import com.pbl6.userservice.exception.ErrorCode;
import com.pbl6.userservice.repository.RoleRepository;
import com.pbl6.userservice.repository.UserRepository;
import com.pbl6.userservice.service.UserService;
import lombok.AccessLevel;
import lombok.RequiredArgsConstructor;
import lombok.experimental.FieldDefaults;
import org.modelmapper.ModelMapper;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

@Service
@FieldDefaults(level = AccessLevel.PRIVATE,makeFinal=true)
@RequiredArgsConstructor
public class UserServiceImpl implements UserService {
    UserRepository userRepository;
    RoleRepository roleRepository;
    PasswordEncoder passwordEncoder;
    ModelMapper modelMapper;
    public UserResponse register(CreateUserRequest request) {
        User user = modelMapper.map(request, User.class);

        user.setPassword(passwordEncoder.encode(request.getPassword()));

        roleRepository.findByName("USER").ifPresent(user.getRoles()::add);
        user.setEnabled(true);
        try {
            User savedUser = userRepository.save(user);
            return modelMapper.map(savedUser, UserResponse.class);
        } catch (DataIntegrityViolationException e) {
            // Trường username/email/phone bị trùng (vi phạm unique constraint)
            throw new AppException(ErrorCode.USER_EXISTED);
        }
    }

    @Override
    public UserResponse getUserByEmail(String email) {
        return userRepository.findByEmail(email)
                .map(user -> modelMapper.map(user, UserResponse.class))
                .orElse(null);
    }

    @Override
    public boolean existsByEmail(String email) {
        return userRepository.existsByEmail(email);
    }


    @Override
    public void resetPassword(ResetPasswordRequest request) {
        User user = userRepository.findByEmail(request.getEmail())
                .orElseThrow(() -> new AppException(ErrorCode.USER_NOT_FOUND));

        user.setPassword(passwordEncoder.encode(request.getNewPassword()));
        user.setUpdatedBy(request.getEmail());
        userRepository.save(user);
    }

    @Override
    public UserResponse getMyInfo() {
        var context = SecurityContextHolder.getContext();
        String email = context.getAuthentication().getName();

        Optional<User> user = userRepository.findByEmail(email);

        return modelMapper.map(user, UserResponse.class);
    }

    @PreAuthorize("hasRole('ADMIN')")
    public List<UserResponse> getAllUsers() {
        var users=userRepository.findAll();

        return users.stream()
                .map(user->modelMapper.map(user,UserResponse.class))
                .collect(Collectors.toList());
    }

}

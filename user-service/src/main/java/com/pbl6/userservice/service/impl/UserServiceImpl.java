package com.pbl6.userservice.service.impl;

import com.pbl6.userservice.dto.request.*;
import com.pbl6.userservice.dto.response.UserDTO;
import com.pbl6.userservice.dto.response.UserResponse;
import com.pbl6.userservice.entity.Role;
import com.pbl6.userservice.entity.User;
import com.pbl6.userservice.exception.AppException;
import com.pbl6.userservice.exception.ErrorCode;
import com.pbl6.userservice.repository.RoleRepository;
import com.pbl6.userservice.repository.UserRepository;
import com.pbl6.userservice.service.UserService;
import jakarta.mail.MessagingException;
import jakarta.mail.internet.MimeMessage;
import lombok.AccessLevel;
import lombok.RequiredArgsConstructor;
import lombok.experimental.FieldDefaults;
import org.modelmapper.ModelMapper;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.mail.MailException;
import org.springframework.mail.MailSender;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.mail.javamail.MimeMessageHelper;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import java.util.HashMap;
import java.util.Map;
import java.util.Optional;
import java.util.Random;

@Service
@FieldDefaults(level = AccessLevel.PRIVATE,makeFinal=true)
@RequiredArgsConstructor
public class UserServiceImpl implements UserService {
    UserRepository userRepository;
    RoleRepository roleRepository;
    PasswordEncoder passwordEncoder;
    ModelMapper modelMapper;
    public UserResponse createUser(CreateUserRequest request) {
        User user = modelMapper.map(request, User.class);

        user.setPassword(passwordEncoder.encode(request.getPassword()));

        roleRepository.findByName("USER").ifPresent(user.getRoles()::add);

        try {
            User savedUser = userRepository.save(user);
            return modelMapper.map(savedUser, UserResponse.class);
        } catch (DataIntegrityViolationException e) {
            // Trường username/email/phone bị trùng (vi phạm unique constraint)
            throw new AppException(ErrorCode.USER_EXISTED);
        }
    }

    @Override
    public UserDTO getUserByEmail(String email) {
        return userRepository.findByEmail(email)
                .map(user -> modelMapper.map(user, UserDTO.class))
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

}

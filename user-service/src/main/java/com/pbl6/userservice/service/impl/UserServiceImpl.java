package com.pbl6.userservice.service.impl;

import com.pbl6.event.dto.NotificationEvent;
import com.pbl6.event.dto.UserRegisteredEvent;
import com.pbl6.userservice.client.CompanyClient;
import com.pbl6.userservice.client.FileClient;
import com.pbl6.userservice.client.ProfileClient;
import com.pbl6.userservice.dto.request.ChangePasswordRequest;
import com.pbl6.userservice.dto.request.CreateCompanyRequest;
import com.pbl6.userservice.dto.request.UpdateUserRequest;
import com.pbl6.userservice.dto.shared.*;
import com.pbl6.userservice.entity.Role;
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
import org.springframework.kafka.core.KafkaTemplate;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.util.*;
import java.util.stream.Collectors;

@Service
@FieldDefaults(level = AccessLevel.PRIVATE,makeFinal=true)
@RequiredArgsConstructor
public class UserServiceImpl implements UserService {
    UserRepository userRepository;
    RoleRepository roleRepository;
    PasswordEncoder passwordEncoder;
    ModelMapper modelMapper;
    KafkaTemplate<String, Object> kafkaTemplate;
    FileClient  fileClient;
    CompanyClient companyClient;
    ProfileClient profileClient;
    static final String USER_REGISTERED_TOPIC = "user_registered_topic";
    public UserResponse register(CreateUserRequest request) {
        if (userRepository.existsByEmail(request.getEmail())) {
            throw new AppException(ErrorCode.EMAIL_EXISTED);
        }

        if (userRepository.existsByUsername(request.getUsername())) {
            throw new AppException(ErrorCode.USERNAME_EXISTED);
        }

        if (request.getPhone() != null && userRepository.existsByPhone(request.getPhone())) {
            throw new AppException(ErrorCode.PHONE_EXISTED);
        }

        User user = modelMapper.map(request, User.class);

        user.setPassword(passwordEncoder.encode(request.getPassword()));

        user.setEnabled(true);

        if (request.getNameCompany() != null) {
            roleRepository.findByName("RECRUITER").ifPresent(user.getRoles()::add);
        } else {
            roleRepository.findByName("USER").ifPresent(user.getRoles()::add);
        }

        try {
            User savedUser = userRepository.save(user);
            Set<String> roleNames=savedUser.getRoles().stream().map(Role::getName).collect(Collectors.toSet());
            UserRegisteredEvent event = new UserRegisteredEvent(
                    savedUser.getId().toString(),
                    roleNames
            );
            kafkaTemplate.send(USER_REGISTERED_TOPIC, savedUser.getId().toString(), event);
            if(request.getNameCompany() != null){
                CreateCompanyRequest createCompanyRequest= CreateCompanyRequest.builder()
                        .ownerID(savedUser.getId())
                        .name(request.getNameCompany())
                        .taxCode(request.getTaxCode())
                        .build();

                companyClient.createCompany(createCompanyRequest);
            }
            NotificationEvent notificationEvent = NotificationEvent.builder()
                    .channel("EMAIL")
                    .recipient(savedUser.getEmail())
                    .templateCode("welcome_template")
                    .subject("Chào mừng đến với IT Job Hunt!")
                    .param(Map.of( "name", savedUser.getFullName(),
                            "email", savedUser.getEmail()))
                    .build();

            kafkaTemplate.send("notification-delivery", notificationEvent);

            ProfileRequest profileRequest = ProfileRequest.builder()
                    .userId(savedUser.getId())
                    .build();
            profileClient.createProfile(profileRequest);
            return modelMapper.map(savedUser, UserResponse.class);
        } catch (DataIntegrityViolationException e) {
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

    @Override
    public ReviewerInfoResponse getReviewerInfo(String reviewerId) {
        Optional<User> userOptional = userRepository.findById(UUID.fromString(reviewerId));
        if(userOptional.isEmpty()){
            throw new AppException(ErrorCode.USER_NOT_FOUND);
        }
        User user = userOptional.get();
        return ReviewerInfoResponse.builder()
                .avatarUrl(user.getAvatarUrl())
                .fullName(user.getFullName())
                .build();
    }

    @PreAuthorize("hasRole('ADMIN')")
    public void changeStatus(String id) {
        Optional<User> userOptional = userRepository.findById(UUID.fromString(id));

        if (userOptional.isEmpty()) {
            throw new AppException(ErrorCode.USER_NOT_FOUND);
        }

        User user = userOptional.get();
        user.setEnabled(!user.isEnabled());
        userRepository.save(user);
    }

    @Override
    public String uploadAvatar(MultipartFile file) {
        String url=fileClient.uploadFile(file,"avatars").getResult();
        var context = SecurityContextHolder.getContext();
        String email = context.getAuthentication().getName();

        Optional<User> userOptional = userRepository.findByEmail(email);
        if(userOptional.isEmpty()){
            throw new AppException(ErrorCode.USER_NOT_FOUND);
        }
        User user = userOptional.get();
        user.setAvatarUrl(url);
        userRepository.save(user);
        return url;
    }

    @Override
    public UserResponse updateMyInfo(UpdateUserRequest request) {
        var context = SecurityContextHolder.getContext();
        String email = context.getAuthentication().getName();

        Optional<User> userOptional = userRepository.findByEmail(email);
        if(userOptional.isEmpty()){
            throw new AppException(ErrorCode.USER_NOT_FOUND);
        }
        User user = userOptional.get();
        modelMapper.getConfiguration().setSkipNullEnabled(true);
        modelMapper.map(request,user);
        userRepository.save(user);
        return modelMapper.map(user,UserResponse.class);
    }

    @PreAuthorize("hasRole('ADMIN')")
    public void deleteUser(String id) {
        Optional<User> userOptional = userRepository.findById(UUID.fromString(id));

        if (userOptional.isEmpty()) {
            throw new AppException(ErrorCode.USER_NOT_FOUND);
        }
        User user = userOptional.get();
        userRepository.delete(user);
    }

    @PreAuthorize("hasRole('ADMIN')")
    public void upgradeRole(String userId, String roleId) {
        Optional<User> userOptional = userRepository.findById(UUID.fromString(userId));

        if (userOptional.isEmpty()) {
            throw new AppException(ErrorCode.USER_NOT_FOUND);
        }
        Optional<Role> roleOptional = roleRepository.findById(UUID.fromString(roleId));
        if (roleOptional.isEmpty()) {
            throw new AppException(ErrorCode.ROLE_NOT_FOUND);
        }

        User user = userOptional.get();
        Role role = roleOptional.get();
        if (!user.getRoles().contains(role)) {
            user.getRoles().add(role);
            userRepository.save(user);
        } else {
            throw new AppException(ErrorCode.ROLE_ALREADY_ASSIGNED);
        }

    }

    @PreAuthorize("hasRole('ADMIN')")
    public UserResponse updateUser(String userId, UpdateUserRequest request) {
        Optional<User> userOptional = userRepository.findById(UUID.fromString(userId));
        if(userOptional.isEmpty()){
            throw new AppException(ErrorCode.USER_NOT_FOUND);
        }
        User user = userOptional.get();
        modelMapper.getConfiguration().setSkipNullEnabled(true);
        modelMapper.map(request,user);
        userRepository.save(user);
        return modelMapper.map(user,UserResponse.class);
    }

    @Override
    public void changePassword(ChangePasswordRequest request) {
        var context = SecurityContextHolder.getContext();
        String email = context.getAuthentication().getName();

        Optional<User> userOptional = userRepository.findByEmail(email);
        if(userOptional.isEmpty()){
            throw new AppException(ErrorCode.USER_NOT_FOUND);
        }
        User user = userOptional.get();
        if(!passwordEncoder.matches(request.getOldPassword(),user.getPassword())){
            throw new AppException(ErrorCode.OLDPASSWORD_INCORRECT);
        }
        user.setPassword(passwordEncoder.encode(request.getNewPassword()));
        userRepository.save(user);
    }

    @Override
    public UserResponse getUserById(String id) {
        Optional<User> userOptional = userRepository.findById(UUID.fromString(id));
        if(userOptional.isEmpty()){
            throw new AppException(ErrorCode.USER_NOT_FOUND);
        }
        User user = userOptional.get();
        return modelMapper.map(user,UserResponse.class);
    }

    @Override
    public UserResponse login(LoginRequest request) {
        Optional<User> userOptional = userRepository.findByEmail(request.getEmail());
        if(userOptional.isEmpty()){
            throw new AppException(ErrorCode.USER_NOT_FOUND);
        }
        User user = userOptional.get();
        if (!passwordEncoder.matches(request.getPassword(), user.getPassword())) {
            throw new AppException(ErrorCode.WRONG_PASSWORD);
        }
        if (!user.isEnabled()) {
            throw new AppException(ErrorCode.DEACTIVE_ACCOUNT);
        }
        return modelMapper.map(user,UserResponse.class);
    }

}

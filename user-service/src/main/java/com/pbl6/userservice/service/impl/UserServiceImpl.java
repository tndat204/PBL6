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
    JavaMailSender javaMailSender;
    PasswordEncoder passwordEncoder;
    ModelMapper modelMapper;
    Map<String, OTPInfo> otpStore = new HashMap<>();
    @PreAuthorize("hasRole('ADMIN')")
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
    public void sendOTP(SendOTPRequest request) throws MailException, MessagingException {
        if (userRepository.existsByEmail(request.getEmail())) {
            if (otpStore.containsKey(request.getEmail())) otpStore.remove(request.getEmail());
            Random random = new Random();
            int otp = 100000 + random.nextInt(900000);
            otpStore.put(request.getEmail(), new OTPInfo(otp));
            String subject = "ĐÂY LÀ MÃ OTP CỦA BẠN";
            String htmlContent =
                    "<div style='font-family: Arial, sans-serif; max-width: 600px; margin: auto; padding: 20px; " +
                            "border: 1px solid #ddd; border-radius: 10px; background-color: #f9f9f9;'>" +
                            "<h2 style='color: #4CAF50; text-align: center;'>Xác thực OTP</h2>" +
                            "<p style='font-size: 16px; color: #333; text-align: center;'>Mã OTP của bạn là:</p>" +
                            "<div style='text-align: center; margin: 20px 0;'>" +
                            "<span style='display: inline-block; font-size: 28px; font-weight: bold; " +
                            "color: #ffffff; background-color: #4CAF50; padding: 10px 20px; border-radius: 8px;'>" +
                            otp +
                            "</span>" +
                            "</div>" +
                            "<p style='font-size: 14px; color: #555; text-align: center;'>Mã OTP sẽ hết hạn sau <b>5 phút</b>.</p>" +
                            "<hr style='margin: 20px 0; border: none; border-top: 1px solid #ddd;'/>" +
                            "<p style='font-size: 14px; color: #555; text-align: center;'>Cảm ơn bạn đã sử dụng dịch vụ của chúng tôi!</p>" +
                            "<p style='font-size: 12px; font-style: italic; color: #888; text-align: center;'>Nếu bạn không yêu cầu mã OTP này, vui lòng bỏ qua email này.</p>" +
                            "</div>";
            MimeMessage message = javaMailSender.createMimeMessage();
            MimeMessageHelper helper = new MimeMessageHelper(message, true);
            helper.setFrom("IT Job Hunt <shopddhpbl3@gmail.com>");
            helper.setTo(request.getEmail());
            helper.setSubject(subject);
            helper.setText(htmlContent, true);
            javaMailSender.send(message);
        } else {
            throw new AppException(ErrorCode.EMAIL_NOT_FOUND);
        }
    }

    @Override
    public boolean verifyOtp(VerifyOTPRequest request) {
        OTPInfo otpInfo = otpStore.get(request.getEmail());
        if (otpInfo != null && !otpInfo.isExpired() && otpInfo.getOtp().equals(request.getOtp())) return true;
        return false;
    }

    @Override
    public void resetPassword(ResetPasswordRequest request) {
        User user = userRepository.findByEmail(request.getEmail())
                .orElseThrow(() -> new AppException(ErrorCode.USER_NOT_FOUND));

        user.setPassword(passwordEncoder.encode(request.getNewPassword()));
        userRepository.save(user);
    }


}

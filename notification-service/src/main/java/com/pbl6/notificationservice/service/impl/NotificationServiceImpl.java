package com.pbl6.notificationservice.service.impl;

import com.pbl6.notificationservice.dto.shared.SendOTPRequest;
import com.pbl6.notificationservice.service.NotificationService;
import jakarta.mail.MessagingException;
import jakarta.mail.internet.MimeMessage;
import lombok.AccessLevel;
import lombok.RequiredArgsConstructor;
import lombok.experimental.FieldDefaults;
import org.springframework.mail.MailException;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.mail.javamail.MimeMessageHelper;
import org.springframework.stereotype.Service;

@Service
@FieldDefaults(level = AccessLevel.PRIVATE,makeFinal=true)
@RequiredArgsConstructor
public class NotificationServiceImpl implements NotificationService {
    JavaMailSender javaMailSender;
    @Override
    public void sendOTP(SendOTPRequest request) throws MailException, MessagingException {
        String subject = "ĐÂY LÀ MÃ OTP CỦA BẠN";
        String htmlContent =
                "<div style='font-family: Arial, sans-serif; max-width: 600px; margin: auto; padding: 20px; " +
                        "border: 1px solid #ddd; border-radius: 10px; background-color: #f9f9f9;'>" +
                        "<h2 style='color: #4CAF50; text-align: center;'>Xác thực OTP</h2>" +
                        "<p style='font-size: 16px; color: #333; text-align: center;'>Mã OTP của bạn là:</p>" +
                        "<div style='text-align: center; margin: 20px 0;'>" +
                        "<span style='display: inline-block; font-size: 28px; font-weight: bold; " +
                        "color: #ffffff; background-color: #4CAF50; padding: 10px 20px; border-radius: 8px;'>" +
                        request.getOtp() +
                        "</span>" +
                        "</div>" +
                        "<p style='font-size: 14px; color: #555; text-align: center;'>Mã OTP sẽ hết hạn sau <b>5 phút</b>.</p>" +
                        "</div>";

        MimeMessage message = javaMailSender.createMimeMessage();
        MimeMessageHelper helper = new MimeMessageHelper(message, true);
        helper.setFrom("IT Job Hunt <shopddhpbl3@gmail.com>");
        helper.setTo(request.getEmail());
        helper.setSubject(subject);
        helper.setText(htmlContent, true);
        javaMailSender.send(message);
    }

}

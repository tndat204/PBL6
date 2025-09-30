package com.pbl6.notificationservice.service.impl;

import com.pbl6.notificationservice.client.EmailClient;
import com.pbl6.notificationservice.dto.request.EmailRequest;
import com.pbl6.notificationservice.dto.request.SendEmailRequest;
import com.pbl6.notificationservice.dto.request.Sender;
import com.pbl6.notificationservice.dto.response.EmailResponse;
import com.pbl6.notificationservice.exception.AppException;
import com.pbl6.notificationservice.exception.ErrorCode;
import com.pbl6.notificationservice.service.EmailService;
import feign.FeignException;
import lombok.AccessLevel;
import lombok.RequiredArgsConstructor;
import lombok.experimental.FieldDefaults;
import lombok.experimental.NonFinal;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@FieldDefaults(level = AccessLevel.PRIVATE,makeFinal=true)
@RequiredArgsConstructor
public class EmailServiceImpl implements EmailService {

    EmailClient emailClient;

    @NonFinal
    @Value("${brevo.api_key}")
    protected String apiKey;

    @Override
    public EmailResponse sendEmail(SendEmailRequest request) {
        EmailRequest emailRequest = EmailRequest.builder()
                .sender(Sender.builder()
                        .name("IT Job Hunt")
                        .email("dattran10102k4@gmail.com")
                        .build())
                .to(List.of(request.getTo()))
                .subject(request.getSubject())
                .htmlContent(request.getHtmlContent())
                .build();
        try {
            return emailClient.sendEmail(apiKey, emailRequest);
        } catch (FeignException e){
            throw new AppException(ErrorCode.CANNOT_SEND_EMAIL);
        }

    }
}

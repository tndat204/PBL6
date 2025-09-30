package com.pbl6.notificationservice.controller.external;

import com.pbl6.notificationservice.dto.request.SendEmailRequest;
import com.pbl6.notificationservice.dto.response.EmailResponse;
import com.pbl6.notificationservice.dto.shared.APIResponse;
import com.pbl6.notificationservice.service.EmailService;
import lombok.AccessLevel;
import lombok.RequiredArgsConstructor;
import lombok.experimental.FieldDefaults;
import lombok.extern.slf4j.Slf4j;
import org.springframework.kafka.annotation.KafkaListener;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequiredArgsConstructor
@RequestMapping("/notification/email")
@Slf4j
@FieldDefaults(level = AccessLevel.PRIVATE, makeFinal = true)
public class EmailController {
    EmailService emailService;

    @PostMapping("/email/send")
    APIResponse<EmailResponse> sendEmail(@RequestBody SendEmailRequest request){
        return APIResponse.<EmailResponse>builder()
                .code(200)
                .result(emailService.sendEmail(request))
                .build();
    }
}

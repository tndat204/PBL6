package com.pbl6.notificationservice.controller.external;
import com.pbl6.event.dto.NotificationEvent;
import com.pbl6.notificationservice.dto.request.Recipient;
import com.pbl6.notificationservice.dto.request.SendEmailRequest;
import com.pbl6.notificationservice.service.EmailService;
import lombok.AccessLevel;
import lombok.RequiredArgsConstructor;
import lombok.experimental.FieldDefaults;
import lombok.extern.slf4j.Slf4j;
import org.springframework.kafka.annotation.KafkaListener;
import org.springframework.stereotype.Component;
import org.thymeleaf.TemplateEngine;
import org.thymeleaf.context.Context;

@Slf4j
@Component
@RequiredArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE, makeFinal = true)
public class NotificationController {

    EmailService emailService;
    TemplateEngine templateEngine; // inject template engine

    @KafkaListener(topics = "notification-delivery")
    public void listenNotificationDelivery(NotificationEvent message){
        log.info("Message received: {}", message);

        // 1. Render HTML từ templateCode + param
        Context context = new Context();
        if (message.getParam() != null) {
            context.setVariables(message.getParam());
        }

        String htmlContent = templateEngine.process(message.getTemplateCode(), context);

        emailService.sendEmail(SendEmailRequest.builder()
                .to(Recipient.builder()
                        .email(message.getRecipient())
                        .build())
                .subject(message.getSubject())
                .htmlContent(htmlContent)
                .build());
    }
}


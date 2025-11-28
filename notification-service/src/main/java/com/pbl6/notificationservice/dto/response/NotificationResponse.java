package com.pbl6.notificationservice.dto.response;

import com.pbl6.notificationservice.entity.enums.NotificationType;
import lombok.*;
import lombok.experimental.FieldDefaults;

import java.time.LocalDateTime;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
@FieldDefaults(level = AccessLevel.PRIVATE)
public class NotificationResponse {
    String id;
    String recipientId;
    String senderId;
    String title;
    String message;
    NotificationType type;
    String targetUrl;
    boolean isRead;
    LocalDateTime createdAt;
}

package com.pbl6.notificationservice.entity;

import com.pbl6.notificationservice.entity.enums.NotificationType;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.mapping.Document;
import java.time.LocalDateTime;

@Document(collection = "notifications")
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class Notification {

    @Id
    private String id;

    // Người nhận thông báo (Quan trọng để query)
    private String recipientId;

    // Người gửi (Optional - ví dụ HR nào gửi, hoặc System)
    private String senderId;

    private String title;
    private String message;

    // Loại thông báo: JOB_APPLY, SYSTEM, CHAT... để Frontend hiện icon tương ứng
    private NotificationType type;


    // Trạng thái đã xem chưa
    @Builder.Default
    private boolean isRead = false;

    private LocalDateTime createdAt;
}


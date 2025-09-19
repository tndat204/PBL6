package com.pbl6.notificationservice.entity;

import com.pbl6.notificationservice.enums.NotificationStatus;
import jakarta.persistence.*;
import lombok.*;
import lombok.experimental.FieldDefaults;

import java.util.UUID;

@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE)
@Entity
public class Notification {
    @Id
    @Column(name = "notification_id", updatable = false, nullable = false)
    UUID notificationId;

    @Column(nullable = false)
    String content;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    NotificationStatus status;

    @Column(name = "user_id", nullable = false)
    UUID userId;
}

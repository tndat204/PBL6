package com.pbl6.chatservice.entity;

import jakarta.persistence.*;
import lombok.*;
import lombok.experimental.FieldDefaults;

import java.time.LocalDateTime;
import java.util.UUID;

@Entity
@Table(name = "messages")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
@FieldDefaults(level = AccessLevel.PRIVATE)
public class Message {

    @Id
    @GeneratedValue
    @Column(columnDefinition = "uuid")
    UUID messageId;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "conversation_id", nullable = false)
    Conversation conversation;

    @Column(nullable = false, columnDefinition = "uuid")
    UUID senderId;

    @Column(columnDefinition = "TEXT")
    String content; // Chứa text hoặc URL của file/ảnh

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 10)
    MessageType messageType;

    @Column(length = 255)
    String fileName;

    Integer fileSize; // Kích thước file (bytes)

    @Column(nullable = false)
    LocalDateTime sentAt;

    public enum MessageType {
        TEXT, IMAGE, FILE, STICKER
    }
}
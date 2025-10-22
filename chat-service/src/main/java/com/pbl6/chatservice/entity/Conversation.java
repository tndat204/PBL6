package com.pbl6.chatservice.entity;

import jakarta.persistence.*;
import lombok.*;
import lombok.experimental.FieldDefaults;

import java.time.LocalDateTime;
import java.util.UUID;

@Entity
@Table(name = "conversations", uniqueConstraints = {
        // Đảm bảo tính duy nhất cho cặp user (đã sắp xếp)
        @UniqueConstraint(columnNames = {"user1_id", "user2_id"})
})
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
@FieldDefaults(level = AccessLevel.PRIVATE)
public class Conversation {

    @Id
    @GeneratedValue
    @Column(columnDefinition = "uuid")
    UUID conversationId;

    @Column(nullable = false, columnDefinition = "uuid")
    UUID user1Id; // ID nhỏ hơn (đã sắp xếp)

    @Column(nullable = false, columnDefinition = "uuid")
    UUID user2Id; // ID lớn hơn (đã sắp xếp)

    @Column(nullable = false)
    LocalDateTime createdAt;

    @Column(nullable = false)
    LocalDateTime lastMessageAt;

}
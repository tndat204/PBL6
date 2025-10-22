package com.pbl6.chatservice.entity;

import jakarta.persistence.*;
import lombok.*;
import lombok.experimental.FieldDefaults;

import java.time.LocalDateTime;
import java.util.UUID;

@Entity
@Table(name = "message_reactions", uniqueConstraints = {
        @UniqueConstraint(columnNames = {"message_id", "user_id"})
})
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
@FieldDefaults(level = AccessLevel.PRIVATE)
public class MessageReaction {

    @Id
    @GeneratedValue
    @Column(columnDefinition = "uuid")
    UUID id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "message_id", nullable = false)
    Message message;

    @Column(name = "user_id", nullable = false, columnDefinition = "uuid")
    UUID userId;

    @Enumerated(EnumType.STRING)
    @Column(name = "reaction_type", nullable = false, length = 20)
    ReactionType reactionType;

    @Column(nullable = false)
    LocalDateTime createdAt = LocalDateTime.now();

    public enum ReactionType {
        LIKE, HEART, LAUGH, WOW, SAD, ANGRY
    }
}
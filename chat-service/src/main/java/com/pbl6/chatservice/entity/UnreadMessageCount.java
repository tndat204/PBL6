package com.pbl6.chatservice.entity;

import jakarta.persistence.*;
import lombok.*;
import lombok.experimental.FieldDefaults;

@Entity
@Table(name = "unread_message_counts")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
@FieldDefaults(level = AccessLevel.PRIVATE)
public class UnreadMessageCount {

    @EmbeddedId
    UnreadMessageCountId id;

    @Column(nullable = false)
    Integer count = 0;

    @MapsId("conversationId")
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "conversation_id")
    Conversation conversation;
}
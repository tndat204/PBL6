package com.pbl6.chatservice.dto.response;

import lombok.*;
import lombok.experimental.FieldDefaults;

import java.time.LocalDateTime;
import java.util.UUID;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE)
public class ConversationResponse {
    UUID conversationId;
    UUID user1Id;
    UUID user2Id;
    LocalDateTime lastMessageAt;
}

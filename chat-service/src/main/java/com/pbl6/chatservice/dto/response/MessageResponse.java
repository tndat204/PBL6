package com.pbl6.chatservice.dto.response;

import lombok.*;
import lombok.experimental.FieldDefaults;

import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE)
public class MessageResponse {
    UUID messageId;
    UUID conversationId;
    UUID senderId;
    UUID receiverId;
    String messageType;
    String content;
    LocalDateTime sentAt;
    String fileName;

    List<ReactionResponse> reactions;
}

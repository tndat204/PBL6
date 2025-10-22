package com.pbl6.chatservice.dto.request;

import lombok.*;
import lombok.experimental.FieldDefaults;

import java.util.UUID;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE)
public class MessageRequest {
    UUID conversationId;
    UUID senderId;
    String messageType;
    String content;
    String fileName;
    String fileSize;
}

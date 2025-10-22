package com.pbl6.chatservice.dto.request;

import lombok.*;
import lombok.experimental.FieldDefaults;

import java.util.UUID;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE)
public class ReactionRequest {
    UUID messageId;
    UUID userId;
    String reactionType;
}

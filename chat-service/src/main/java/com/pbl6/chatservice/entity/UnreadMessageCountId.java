package com.pbl6.chatservice.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Embeddable;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.io.Serializable;
import java.util.UUID;

@Embeddable
@Data
@NoArgsConstructor
@AllArgsConstructor
public class UnreadMessageCountId implements Serializable {

    @Column(name = "conversation_id", columnDefinition = "uuid")
    private UUID conversationId;

    @Column(name = "user_id", columnDefinition = "uuid")
    private UUID userId;
}
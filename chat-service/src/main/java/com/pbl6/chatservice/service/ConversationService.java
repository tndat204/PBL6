package com.pbl6.chatservice.service;

import com.pbl6.chatservice.dto.response.ConversationResponse;

import java.util.List;
import java.util.UUID;

public interface ConversationService {
    public ConversationResponse getOrCreateConversation(UUID targetUserId);
    public List<ConversationResponse> getUserConversations();
    public void markAsRead(UUID conversationId);
}

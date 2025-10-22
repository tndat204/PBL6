package com.pbl6.chatservice.service;

import com.pbl6.chatservice.dto.request.MessageRequest;
import com.pbl6.chatservice.dto.request.ReactionRequest;
import com.pbl6.chatservice.dto.response.MessageResponse;
import com.pbl6.chatservice.dto.response.ReactionResponse;

import java.util.List;
import java.util.UUID;

public interface MessageService {
    public MessageResponse processAndSaveMessage(MessageRequest request,UUID userId);
    public List<MessageResponse> getMessageHistory(UUID conversationId, int page, int size);
    public ReactionResponse processReaction(ReactionRequest request,UUID userId);

}

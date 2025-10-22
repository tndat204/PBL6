package com.pbl6.chatservice.service.impl;

import com.pbl6.chatservice.dto.response.ConversationResponse;
import com.pbl6.chatservice.entity.Conversation;
import com.pbl6.chatservice.entity.UnreadMessageCount;
import com.pbl6.chatservice.entity.UnreadMessageCountId;
import com.pbl6.chatservice.exception.AppException;
import com.pbl6.chatservice.exception.ErrorCode;
import com.pbl6.chatservice.repository.ConversationRepository;
import com.pbl6.chatservice.repository.UnreadCountRepository;
import com.pbl6.chatservice.service.ConversationService;
import jakarta.transaction.Transactional;
import lombok.AccessLevel;
import lombok.RequiredArgsConstructor;
import lombok.experimental.FieldDefaults;
import org.modelmapper.ModelMapper;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
@FieldDefaults(level = AccessLevel.PRIVATE,makeFinal=true)
@RequiredArgsConstructor
public class ConversationServiceImpl implements ConversationService {
    ConversationRepository conversationRepository;
    ModelMapper modelMapper;
    UnreadCountRepository  unreadCountRepository;
    @Transactional
    public ConversationResponse getOrCreateConversation(UUID targetUserId) {
        UUID currentUserId = getCurrentUserId();

        // Sắp xếp ID để đảm bảo chỉ có một bản ghi cho cặp user
        UUID user1Id = currentUserId.compareTo(targetUserId) < 0 ? currentUserId : targetUserId;
        UUID user2Id = currentUserId.compareTo(targetUserId) < 0 ? targetUserId : currentUserId;

        return conversationRepository
                .findByUser1IdAndUser2Id(user1Id, user2Id)
                .map(conv -> modelMapper.map(conv, ConversationResponse.class))
                .orElseGet(() -> {
                    // Tạo mới Conversation
                    Conversation newConversation = Conversation.builder()
                            .user1Id(user1Id)
                            .user2Id(user2Id)
                            .createdAt(LocalDateTime.now())
                            .lastMessageAt(LocalDateTime.now())
                            .build();

                    Conversation savedConv = conversationRepository.save(newConversation);

                    // Khởi tạo Unread Count cho cả hai người
                    unreadCountRepository.save(new UnreadMessageCount(new UnreadMessageCountId(savedConv.getConversationId(), user1Id), 0, savedConv));
                    unreadCountRepository.save(new UnreadMessageCount(new UnreadMessageCountId(savedConv.getConversationId(), user2Id), 0, savedConv));

                    return modelMapper.map(savedConv, ConversationResponse.class);
                });
    }

    @Override
    public List<ConversationResponse> getUserConversations() {
        UUID currentUserId = getCurrentUserId();

        List<Conversation> conversations = conversationRepository.findByUser1IdOrUser2IdOrderByLastMessageAtDesc(currentUserId, currentUserId);

        return conversations.stream()
                .map(conv -> modelMapper.map(conv, ConversationResponse.class))
                .collect(Collectors.toList());
    }

    @Transactional
    public void markAsRead(UUID conversationId) {
        UUID currentUserId = getCurrentUserId();

        if (!conversationRepository.existsById(conversationId)) {
            throw new AppException(ErrorCode.CONVERSATION_NOT_FOUND);
        }

        unreadCountRepository.resetUnreadCount(conversationId, currentUserId);
    }
    private UUID getCurrentUserId() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        if (!(authentication.getPrincipal() instanceof Jwt jwt)) {
            throw new RuntimeException("Cannot get userId from token");
        }
        return UUID.fromString(jwt.getClaimAsString("userId"));
    }
}

package com.pbl6.chatservice.service.impl;

import com.pbl6.chatservice.dto.request.MessageRequest;
import com.pbl6.chatservice.dto.request.ReactionRequest;
import com.pbl6.chatservice.dto.response.MessageResponse;
import com.pbl6.chatservice.dto.response.ReactionResponse;
import com.pbl6.chatservice.entity.Conversation;
import com.pbl6.chatservice.entity.Message;
import com.pbl6.chatservice.entity.MessageReaction;
import com.pbl6.chatservice.exception.AppException;
import com.pbl6.chatservice.exception.ErrorCode;
import com.pbl6.chatservice.repository.ConversationRepository;
import com.pbl6.chatservice.repository.MessageReactionRepository;
import com.pbl6.chatservice.repository.MessageRepository;
import com.pbl6.chatservice.repository.UnreadCountRepository;
import com.pbl6.chatservice.service.MessageService;
import jakarta.transaction.Transactional;
import lombok.AccessLevel;
import lombok.RequiredArgsConstructor;
import lombok.experimental.FieldDefaults;
import org.modelmapper.ModelMapper;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.*;
import java.util.stream.Collectors;

@Service
@FieldDefaults(level = AccessLevel.PRIVATE,makeFinal=true)
@RequiredArgsConstructor
public class MessageServiceImpl implements MessageService {
    ModelMapper modelMapper;
    MessageRepository messageRepository;
    ConversationRepository conversationRepository;
    UnreadCountRepository  unreadCountRepository;
    SimpMessagingTemplate messagingTemplate;
    MessageReactionRepository reactionRepository;
    @Transactional
    public MessageResponse processAndSaveMessage(MessageRequest request,UUID userId) {
        UUID conversationId = request.getConversationId();

        // 1. Ánh xạ các trường hợp hợp lý
        Message message = new Message();
        message.setContent(request.getContent());
        message.setMessageType(Message.MessageType.valueOf(request.getMessageType().toUpperCase()));
        message.setFileName(request.getFileName());
        message.setFileSize(request.getFileSize() != null ? Integer.parseInt(request.getFileSize()) : null);
        message.setSenderId(userId);
        message.setSentAt(LocalDateTime.now());

        // 2. Gán Conversation
        Conversation conversation = conversationRepository.findById(conversationId)
                .orElseThrow(() -> new AppException(ErrorCode.CONVERSATION_NOT_FOUND));
        message.setConversation(conversation);

        // 3. Lưu tin nhắn
        Message savedMessage = messageRepository.save(message);

        // 4. Cập nhật Last Message và Unread Count
        conversation.setLastMessageAt(savedMessage.getSentAt());
        conversationRepository.save(conversation);

        UUID receiverId = conversation.getUser1Id().equals(userId) ? conversation.getUser2Id() : conversation.getUser1Id();
        unreadCountRepository.incrementUnreadCount(conversation.getConversationId(), receiverId);

        // 5. Map sang Response
        MessageResponse response = modelMapper.map(savedMessage, MessageResponse.class);
        response.setReceiverId(receiverId);

        // 6. Phát tin nhắn
        sendChatMessageUpdate(response);

        return response;
    }


    @Override
    public List<MessageResponse> getMessageHistory(UUID conversationId, int page, int size) {
        if (!conversationRepository.existsById(conversationId)) {
            throw new AppException(ErrorCode.CONVERSATION_NOT_FOUND);
        }

        Pageable pageable = PageRequest.of(page, size, Sort.by("sentAt").descending());
        List<Message> messages = messageRepository.findByConversation_ConversationId(conversationId, pageable);

        // Lấy tất cả Message IDs để truy vấn Reactions
        List<UUID> messageIds = messages.stream().map(Message::getMessageId).collect(Collectors.toList());
        Map<UUID, List<ReactionResponse>> reactionsMap = getReactionsForMessages(messageIds);

        return messages.stream()
                .map(message -> {
                    MessageResponse response = modelMapper.map(message, MessageResponse.class);
                    // Gán Reactions cho từng tin nhắn
                    response.setReactions(reactionsMap.getOrDefault(message.getMessageId(), Collections.emptyList()));
                    return response;
                })
                .collect(Collectors.toList());
    }

    @Transactional
    public ReactionResponse processReaction(ReactionRequest request,UUID userId) {
        UUID messageId = request.getMessageId();
        String newReactionTypeStr = request.getReactionType();

        // 1. Kiểm tra tồn tại tin nhắn
        Message message = messageRepository.findById(messageId)
                .orElseThrow(() -> new AppException(ErrorCode.MESSAGE_NOT_FOUND));

        // 2. Tìm Reaction hiện có của người dùng này trên tin nhắn này
        Optional<MessageReaction> existingReactionOpt = reactionRepository
                .findByMessage_MessageIdAndUserId(messageId, userId);

        ReactionResponse finalReactionResponse;

        if (existingReactionOpt.isPresent()) {
            MessageReaction existingReaction = existingReactionOpt.get();

            // --- Tình huống 1: Đã tồn tại Reaction ---

            // Kiểm tra xem Reaction mới có giống Reaction cũ không (Toggle off)
            if (existingReaction.getReactionType().name().equalsIgnoreCase(newReactionTypeStr)) {

                // XÓA (DELETE): Reaction trùng -> Xóa Reaction hiện tại
                reactionRepository.delete(existingReaction);

                // Tạo Response đặc biệt để thông báo cho FE là Reaction đã bị xóa
                finalReactionResponse = ReactionResponse.builder()
                        .messageId(messageId)
                        .userId(userId)
                        .id(existingReaction.getId()) // Gửi ID của Reaction bị xóa
                        .reactionType("DELETED") // Dùng giá trị DELETED để báo hiệu xóa
                        .build();
            } else {

                // CẬP NHẬT (UPDATE): Reaction mới khác Reaction cũ -> Đổi loại Reaction
                try {
                    existingReaction.setReactionType(MessageReaction.ReactionType.valueOf(newReactionTypeStr.toUpperCase()));
                } catch (IllegalArgumentException e) {
                    throw new AppException(ErrorCode.INVALID_REACTION_TYPE);
                }
                existingReaction.setCreatedAt(LocalDateTime.now());
                MessageReaction updatedReaction = reactionRepository.save(existingReaction);

                // Map thủ công các field cần thiết để tránh ModelMapper lỗi
                finalReactionResponse = ReactionResponse.builder()
                        .id(updatedReaction.getId())
                        .messageId(updatedReaction.getMessage().getMessageId())
                        .userId(updatedReaction.getUserId())
                        .reactionType(updatedReaction.getReactionType().name())
                        .build();
            }
        } else {

            // --- Tình huống 2: Chưa có Reaction -> TẠO MỚI (CREATE) ---

            MessageReaction.ReactionType reactionType;
            try {
                reactionType = MessageReaction.ReactionType.valueOf(newReactionTypeStr.toUpperCase());
            } catch (IllegalArgumentException e) {
                throw new AppException(ErrorCode.INVALID_REACTION_TYPE);
            }

            MessageReaction newReaction = MessageReaction.builder()
                    .message(message)
                    .userId(userId)
                    .reactionType(reactionType)
                    .createdAt(LocalDateTime.now())
                    .build();

            MessageReaction createdReaction = reactionRepository.save(newReaction);

            // Map thủ công
            finalReactionResponse = ReactionResponse.builder()
                    .id(createdReaction.getId())
                    .messageId(createdReaction.getMessage().getMessageId())
                    .userId(createdReaction.getUserId())
                    .reactionType(createdReaction.getReactionType().name())
                    .build();
        }

        // 4. Phát thông báo Reaction qua WebSocket để cập nhật UI của cả hai người dùng
        sendReactionUpdate(finalReactionResponse, message);

        return finalReactionResponse;
    }


    private UUID getCurrentUserId() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        if (!(authentication.getPrincipal() instanceof Jwt jwt)) {
            throw new RuntimeException("Cannot get userId from token");
        }
        return UUID.fromString(jwt.getClaimAsString("userId"));
    }
    private void sendChatMessageUpdate(MessageResponse response) {
        // Gửi đến người nhận
        messagingTemplate.convertAndSendToUser(response.getReceiverId().toString(), "/queue/messages", response);
        // Gửi lại cho người gửi
        messagingTemplate.convertAndSendToUser(response.getSenderId().toString(), "/queue/messages", response);
    }

    // Phương thức gửi Reaction Update qua WebSocket
    private void sendReactionUpdate(ReactionResponse response, Message message) {
        Conversation conversation = message.getConversation();
        UUID user1 = conversation.getUser1Id();
        UUID user2 = conversation.getUser2Id();

        // Gửi đến cả hai người dùng trong cuộc trò chuyện
        messagingTemplate.convertAndSendToUser(user1.toString(), "/queue/reactions", response);
        messagingTemplate.convertAndSendToUser(user2.toString(), "/queue/reactions", response);
    }

    // Helper để lấy Reactions cho nhiều tin nhắn (Tối ưu hóa)
    private Map<UUID, List<ReactionResponse>> getReactionsForMessages(List<UUID> messageIds) {
        List<MessageReaction> reactions = reactionRepository.findByMessageIds(messageIds);

        return reactions.stream()
                .map(reaction -> modelMapper.map(reaction, ReactionResponse.class))
                .collect(Collectors.groupingBy(ReactionResponse::getMessageId));
    }
}

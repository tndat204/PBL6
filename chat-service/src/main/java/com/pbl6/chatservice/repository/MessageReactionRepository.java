package com.pbl6.chatservice.repository;

import com.pbl6.chatservice.entity.MessageReaction;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface MessageReactionRepository extends JpaRepository<MessageReaction, UUID> {

    // Tìm kiếm Reaction của một người dùng trên một tin nhắn cụ thể
    Optional<MessageReaction> findByMessage_MessageIdAndUserId(UUID messageId, UUID userId);

    // Lấy tất cả Reactions cho một tin nhắn
    List<MessageReaction> findByMessage_MessageId(UUID messageId);

    // Lấy tất cả Reactions cho nhiều tin nhắn (dùng khi load lịch sử)
    @Query("SELECT r FROM MessageReaction r WHERE r.message.messageId IN :messageIds")
    List<MessageReaction> findByMessageIds(@Param("messageIds") List<UUID> messageIds);
}


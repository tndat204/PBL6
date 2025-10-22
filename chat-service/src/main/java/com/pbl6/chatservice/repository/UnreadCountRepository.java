package com.pbl6.chatservice.repository;

import com.pbl6.chatservice.entity.UnreadMessageCount;
import com.pbl6.chatservice.entity.UnreadMessageCountId;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.UUID;

@Repository
public interface UnreadCountRepository extends JpaRepository<UnreadMessageCount, UnreadMessageCountId> {

    // Tăng số lượng tin nhắn chưa đọc lên 1
    @Modifying
    @Query("UPDATE UnreadMessageCount u SET u.count = u.count + 1 WHERE u.id.conversationId = :convId AND u.id.userId = :userId")
    void incrementUnreadCount(@Param("convId") UUID convId, @Param("userId") UUID userId);

    // Đặt số lượng tin nhắn chưa đọc về 0 (đánh dấu đã đọc)
    @Modifying
    @Query("UPDATE UnreadMessageCount u SET u.count = 0 WHERE u.id.conversationId = :convId AND u.id.userId = :userId")
    void resetUnreadCount(@Param("convId") UUID convId, @Param("userId") UUID userId);
}

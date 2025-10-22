package com.pbl6.chatservice.repository;

import com.pbl6.chatservice.entity.Conversation;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface ConversationRepository extends JpaRepository<Conversation, UUID> {
    Optional<Conversation> findByUser1IdAndUser2Id(UUID user1Id, UUID user2Id);

    List<Conversation> findByUser1IdOrUser2IdOrderByLastMessageAtDesc(UUID user1Id, UUID user2Id);
}

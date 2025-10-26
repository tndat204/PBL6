package com.pbl6.chatservice.controller;

import com.pbl6.chatservice.dto.response.APIResponse;
import com.pbl6.chatservice.dto.response.ConversationResponse;
import com.pbl6.chatservice.dto.response.MessageResponse;
import com.pbl6.chatservice.service.ConversationService;
import com.pbl6.chatservice.service.MessageService;
import lombok.AccessLevel;
import lombok.experimental.FieldDefaults;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/conversations")
@FieldDefaults(level= AccessLevel.PRIVATE,makeFinal = true)
public class ConversationController {
    ConversationService conversationService;
    public ConversationController(ConversationService conversationService) {
        this.conversationService = conversationService;
    }
    @PostMapping("/{targetUserId}")
    public APIResponse<ConversationResponse> startConversation(@PathVariable("targetUserId") UUID targetUserId){
        return APIResponse.<ConversationResponse>builder()
                .code(200)
                .result(conversationService.getOrCreateConversation(targetUserId))
                .build();
    }

    @GetMapping
    public APIResponse<List<ConversationResponse>> getUserConversations(){
        return APIResponse.<List<ConversationResponse>>builder()
                .code(200)
                .result(conversationService.getUserConversations())
                .build();
    }


}

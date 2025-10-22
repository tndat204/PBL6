package com.pbl6.chatservice.controller;

import com.pbl6.chatservice.dto.request.MessageRequest;
import com.pbl6.chatservice.dto.request.ReactionRequest;
import com.pbl6.chatservice.dto.response.APIResponse;
import com.pbl6.chatservice.dto.response.MessageResponse;
import com.pbl6.chatservice.service.MessageService;
import lombok.AccessLevel;
import lombok.experimental.FieldDefaults;
import lombok.extern.slf4j.Slf4j;
import org.springframework.messaging.handler.annotation.MessageMapping;
import org.springframework.messaging.handler.annotation.Payload;
import org.springframework.web.bind.annotation.*;

import java.security.Principal;
import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/chat/message")
@FieldDefaults(level = AccessLevel.PRIVATE, makeFinal = true)
@Slf4j
public class MessageController {

    MessageService messageService;

    public MessageController(MessageService messageService) {
        this.messageService = messageService;
    }

    // WebSocket send message
    @MessageMapping("/chat.send")
    public void sendMessage(Principal principal,@Payload MessageRequest request){
        messageService.processAndSaveMessage(request, UUID.fromString(principal.getName()));
    }

    // WebSocket react message
    @MessageMapping("/chat.react")
    public void handleReaction(Principal principal,@Payload ReactionRequest request){
        messageService.processReaction(request,UUID.fromString(principal.getName()));
    }

    @GetMapping("/{conversationId}")
    public APIResponse<List<MessageResponse>> getMessages(@PathVariable("conversationId") UUID conversationId,
                                                          @RequestParam(defaultValue = "0") int page,
                                                          @RequestParam(defaultValue = "20") int size){
        return APIResponse.<List<MessageResponse>>builder()
                .code(200)
                .result(messageService.getMessageHistory(conversationId,page,size))
                .build();
    }

}

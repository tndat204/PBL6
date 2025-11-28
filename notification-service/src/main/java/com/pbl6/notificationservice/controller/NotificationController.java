package com.pbl6.notificationservice.controller;

import com.pbl6.notificationservice.dto.response.NotificationResponse;
import com.pbl6.notificationservice.dto.shared.APIResponse;
import com.pbl6.notificationservice.service.NotificationService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/notifications")
@RequiredArgsConstructor
public class NotificationController {

    private final NotificationService notificationService;


    @GetMapping
    public APIResponse<List<NotificationResponse>> getNotifications() {
        return APIResponse.<List<NotificationResponse>>builder()
                .code(200)
                .result(notificationService.getNotifications())
                .build();
    }

    @PutMapping("/{id}/read")
    public APIResponse<String> markAsRead(@PathVariable String id) {
        notificationService.markAsRead(id);
        return APIResponse.<String>builder()
                .code(200)
                .result("Successful")
                .build();
    }

    @PutMapping("/read-all")
    public APIResponse<String> markAllAsRead() {
        notificationService.markAllAsRead();
        return APIResponse.<String>builder()
                .code(200)
                .result("Successful")
                .build();
    }
}
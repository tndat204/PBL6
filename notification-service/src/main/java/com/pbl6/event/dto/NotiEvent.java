package com.pbl6.event.dto;


import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class NotiEvent {
    private String recipientId;
    private String title;
    private String message;
    private String type;
    private String targetUrl;
    private String senderId;
}
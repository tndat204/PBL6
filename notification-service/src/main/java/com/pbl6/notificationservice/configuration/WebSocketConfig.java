package com.pbl6.notificationservice.configuration;

import org.springframework.context.annotation.Configuration;
import org.springframework.messaging.simp.config.MessageBrokerRegistry;
import org.springframework.web.socket.config.annotation.EnableWebSocketMessageBroker;
import org.springframework.web.socket.config.annotation.StompEndpointRegistry;
import org.springframework.web.socket.config.annotation.WebSocketMessageBrokerConfigurer;

@Configuration
@EnableWebSocketMessageBroker
public class WebSocketConfig implements WebSocketMessageBrokerConfigurer {

    @Override
    public void registerStompEndpoints(StompEndpointRegistry registry) {
        // Đăng ký endpoint '/ws'. Đây là cái Frontend sẽ kết nối vào.
        registry.addEndpoint("/ws")
                // QUAN TRỌNG: Cho phép mọi nguồn (vì Gateway sẽ gọi vào đây)
                // Nếu dùng Spring Boot đời mới (2.4+), dùng setAllowedOriginPatterns
                .setAllowedOriginPatterns("*")
                .withSockJS(); // Hỗ trợ fallback cho trình duyệt cũ
    }

    @Override
    public void configureMessageBroker(MessageBrokerRegistry registry) {
        // Prefix cho các topic mà client subscribe
        registry.enableSimpleBroker("/topic", "/queue");
        // Prefix để client gửi tin lên (nếu có chat 2 chiều)
        registry.setApplicationDestinationPrefixes("/app");
    }
}
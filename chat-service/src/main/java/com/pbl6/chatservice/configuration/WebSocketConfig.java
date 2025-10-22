package com.pbl6.chatservice.configuration;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Configuration;
import org.springframework.messaging.simp.config.ChannelRegistration;
import org.springframework.messaging.simp.config.MessageBrokerRegistry;
import org.springframework.messaging.support.ChannelInterceptor;
import org.springframework.web.socket.config.annotation.EnableWebSocketMessageBroker;
import org.springframework.web.socket.config.annotation.StompEndpointRegistry;
import org.springframework.web.socket.config.annotation.WebSocketMessageBrokerConfigurer;

@Configuration
@EnableWebSocketMessageBroker
public class WebSocketConfig implements WebSocketMessageBrokerConfigurer {
    @Autowired
    ChannelInterceptor jwtChannelInterceptor;
    @Override
    public void configureMessageBroker(MessageBrokerRegistry config) {
        // Destination prefix cho tin nhắn riêng tư (server -> client)
        config.enableSimpleBroker("/user");

        // Destination prefix cho các messages client gửi lên server (gọi controller)
        config.setApplicationDestinationPrefixes("/app");

        // Cấu hình endpoint để Spring biết cách gửi tin nhắn riêng tư
        config.setUserDestinationPrefix("/user");
    }

    @Override
    public void registerStompEndpoints(StompEndpointRegistry registry) {
        registry.addEndpoint("/ws")
                .setAllowedOrigins("http://localhost:5173/")
                .withSockJS();
    }
    @Override
    public void configureClientInboundChannel(ChannelRegistration registration) {
        registration.interceptors(jwtChannelInterceptor);
    }
}
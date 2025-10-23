package com.pbl6.chatservice.configuration;

import com.pbl6.chatservice.client.AuthClient;
import com.pbl6.chatservice.dto.request.IntrospectRequest;
import com.pbl6.chatservice.exception.AppException;
import com.pbl6.chatservice.exception.ErrorCode;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.messaging.Message;
import org.springframework.messaging.MessageChannel;
import org.springframework.messaging.simp.stomp.StompCommand;
import org.springframework.messaging.simp.stomp.StompHeaderAccessor;
import org.springframework.messaging.support.ChannelInterceptor;
import org.springframework.messaging.support.MessageHeaderAccessor;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.security.oauth2.jwt.JwtDecoder;

import java.util.Collections;

@Configuration
public class WebSocketAuthConfig {

    private final JwtDecoder jwtDecoder;
    private final AuthClient authClient;
    public WebSocketAuthConfig(JwtDecoder jwtDecoder, AuthClient authClient) {
        this.jwtDecoder = jwtDecoder;
        this.authClient = authClient;
    }

    @Bean
    public ChannelInterceptor jwtChannelInterceptor() {
        return new ChannelInterceptor() {
            @Override
            public Message<?> preSend(Message<?> message, MessageChannel channel) {
                StompHeaderAccessor accessor =
                        MessageHeaderAccessor.getAccessor(message, StompHeaderAccessor.class);

                // Chỉ xử lý CONNECT command
                if (StompCommand.CONNECT.equals(accessor.getCommand())) {
                    String authHeader = accessor.getFirstNativeHeader("Authorization");

                    if (authHeader != null && authHeader.startsWith("Bearer ")) {
                        String token = authHeader.substring(7);
                        IntrospectRequest request =IntrospectRequest.builder().token(token).build();
                        if(!authClient.introspect(request).getResult().isValid()){
                            throw new AppException(ErrorCode.UNAUTHENTICATED);
                        }
                        try {
                            Jwt jwt = jwtDecoder.decode(token);

                            String userId = jwt.getClaimAsString("userId");

                            // SET Principal thủ công
                            accessor.setUser(new UsernamePasswordAuthenticationToken(
                                    userId, null, Collections.emptyList()
                            ));

                        } catch (Exception e) {
                            throw new AppException(ErrorCode.UNAUTHENTICATED);
                        }
                    }
                }

                return message;
            }
        };
    }
}

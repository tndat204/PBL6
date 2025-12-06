package com.pbl6.notificationservice.configuration;

import com.pbl6.notificationservice.client.AuthClient;
import com.pbl6.notificationservice.dto.shared.APIResponse;
import com.pbl6.notificationservice.dto.shared.IntrospectRequest;
import com.pbl6.notificationservice.dto.shared.IntrospectResponse;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.messaging.Message;
import org.springframework.messaging.MessageChannel;
import org.springframework.messaging.simp.stomp.StompCommand;
import org.springframework.messaging.simp.stomp.StompHeaderAccessor;
import org.springframework.messaging.support.ChannelInterceptor;
import org.springframework.messaging.support.MessageHeaderAccessor;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.stereotype.Component;

import java.text.ParseException;
import java.util.List;

@Slf4j
@Component
@RequiredArgsConstructor
public class AuthChannelInterceptor implements ChannelInterceptor {

    private final AuthClient authClient;

    @Override
    public Message<?> preSend(Message<?> message, MessageChannel channel) {
        StompHeaderAccessor accessor = MessageHeaderAccessor.getAccessor(message, StompHeaderAccessor.class);

        // Chỉ check khi Client bắt đầu kết nối (CONNECT)
        if (accessor != null && StompCommand.CONNECT.equals(accessor.getCommand())) {

            // 1. Lấy Token từ Header "Authorization"
            String authHeader = accessor.getFirstNativeHeader("Authorization");

            if (authHeader != null && authHeader.startsWith("Bearer ")) {
                String token = authHeader.substring(7);
                log.info("WebSocket Connecting... Checking Token: {}", token);

                try {
                    IntrospectRequest request = new IntrospectRequest(token);
                    APIResponse<IntrospectResponse> response = authClient.introspect(request);

                    if (response != null && response.getResult() != null && response.getResult().isValid()) {
                        log.info("Token Validated by Auth Service ✅");

                        String userId = getUserIdFromToken(token);

                        UsernamePasswordAuthenticationToken user =
                                new UsernamePasswordAuthenticationToken(userId, null, List.of());
                        accessor.setUser(user);

                    } else {
                        log.error("Token isValid = false. Rejecting connection ❌");
                        return null;
                    }

                } catch (Exception e) {
                    log.error("LỖI GỌI AUTH SERVICE TỪ WEBSOCKET: {}", e.getMessage());
                    return null;
                }

            } else {
                log.warn("Không tìm thấy Header Authorization hoặc sai định dạng");
                return null;
            }
        }

        //CHECK QUYỀN SUBSCRIBE ---
        if (accessor != null && StompCommand.SUBSCRIBE.equals(accessor.getCommand())) {
            String userId = accessor.getUser() != null ? accessor.getUser().getName() : null;
            String destination = accessor.getDestination();

            if (userId != null && destination != null && !destination.contains(userId)) {
                log.error("User {} cố tình subscribe vào topic lạ: {}", userId, destination);
                throw new IllegalArgumentException("Bạn không có quyền xem thông báo của người khác!");
            }
        }

        return message;
    }

    private String getUserIdFromToken(String token) throws ParseException {
        return com.nimbusds.jwt.JWTParser.parse(token).getJWTClaimsSet().getStringClaim("userId");
    }
}
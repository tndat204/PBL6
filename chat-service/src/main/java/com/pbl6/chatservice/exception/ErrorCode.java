package com.pbl6.chatservice.exception;

import lombok.Getter;
import org.springframework.http.HttpStatus;
import org.springframework.http.HttpStatusCode;

@Getter
public enum ErrorCode {
    UNCATEGORIZED_EXCEPTION(9999, "Lỗi chưa định nghĩa", HttpStatus.INTERNAL_SERVER_ERROR),
    UNAUTHENTICATED(1004, "Chưa xác thực", HttpStatus.UNAUTHORIZED),
    UNAUTHORIZED(1006, "You do not have permission", HttpStatus.FORBIDDEN),
    CONVERSATION_NOT_FOUND(4001,"Không tìm thấy cuộc trò chuyện", HttpStatus.NOT_FOUND),
    MESSAGE_NOT_FOUND(4002,"Không tìm thấy tin nhắn", HttpStatus.NOT_FOUND),
    INVALID_REACTION_TYPE(4003,"Loại cảm xúc không hợp lệ", HttpStatus.BAD_REQUEST);
    private final int code;
    private final String message;
    private HttpStatusCode statusCode;


    ErrorCode(int code, String message, HttpStatusCode statusCode) {
        this.code = code;
        this.message = message;
        this.statusCode = statusCode;
    }
}
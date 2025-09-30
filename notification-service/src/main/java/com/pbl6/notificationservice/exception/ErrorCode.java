package com.pbl6.notificationservice.exception;

import lombok.Getter;
import org.springframework.http.HttpStatus;
import org.springframework.http.HttpStatusCode;

@Getter
public enum ErrorCode {
    INVALID_KEY(1009, "Uncategorized error", HttpStatus.BAD_REQUEST),
    UNAUTHENTICATED(1004, "Chưa xác thực", HttpStatus.UNAUTHORIZED),
    CANNOT_SEND_EMAIL(1020,"Không thể gửi email",HttpStatus.BAD_REQUEST);
    private final int code;
    private final String message;
    private HttpStatusCode statusCode;


    ErrorCode(int code, String message, HttpStatusCode statusCode) {
        this.code = code;
        this.message = message;
        this.statusCode = statusCode;
    }
}
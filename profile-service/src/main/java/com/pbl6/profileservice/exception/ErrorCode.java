package com.pbl6.profileservice.exception;

import lombok.Getter;
import org.springframework.http.HttpStatus;
import org.springframework.http.HttpStatusCode;

@Getter
public enum ErrorCode {
    UNCATEGORIZED_EXCEPTION(9999, "Lỗi chưa định nghĩa", HttpStatus.INTERNAL_SERVER_ERROR),
    UNAUTHORIZED(1006, "You do not have permission", HttpStatus.FORBIDDEN),
    INVALID_KEY(1009, "Uncategorized error", HttpStatus.BAD_REQUEST),
    UNAUTHENTICATED(1004, "Chưa xác thực", HttpStatus.UNAUTHORIZED),
    CATEGORY_NOT_FOUND(3001,"Không tồn tại danh mục",HttpStatus.NOT_FOUND),
    SKILL_NOT_FOUND(3002,"Không tồn tại kỹ năng",HttpStatus.NOT_FOUND);
    private final int code;
    private final String message;
    private HttpStatusCode statusCode;


    ErrorCode(int code, String message, HttpStatusCode statusCode) {
        this.code = code;
        this.message = message;
        this.statusCode = statusCode;
    }
}
package com.pbl6.jobservice.exception;

import lombok.Getter;
import org.springframework.http.HttpStatus;
import org.springframework.http.HttpStatusCode;

@Getter
public enum ErrorCode {
    UNCATEGORIZED_EXCEPTION(9999, "Lỗi chưa định nghĩa", HttpStatus.INTERNAL_SERVER_ERROR),
    UNAUTHORIZED(1006, "You do not have permission", HttpStatus.FORBIDDEN),
    INVALID_KEY(1009, "Uncategorized error", HttpStatus.BAD_REQUEST),
    UNAUTHENTICATED(1004, "Chưa xác thực", HttpStatus.UNAUTHORIZED),
    COMPANY_NOT_FOUND(2000, "Công ty không tồn tại", HttpStatus.NOT_FOUND),
    NOT_ALLOW_TO_POST(2001,"Bạn không được phép đăng việc làm cho công ty này", HttpStatus.FORBIDDEN),
    JOB_NOT_FOUND(2002,"Công việc không tồn tại", HttpStatus.NOT_FOUND),
    NOT_ALLOW_TO_UPDATE(2003,"Bạn không được phép chỉnh sửa công việc cho công ty này", HttpStatus.FORBIDDEN),
    NOT_ALLOW_TO_DELETE(2004,"Bạn không được phép xóa công việc của công ty này", HttpStatus.FORBIDDEN),
    COMPANY_NOT_ACTIVE(2005,"Công ty chưa được kích hoạt", HttpStatus.FORBIDDEN),
    APPLICATION_NOT_FOUND(2006,"Đơn ứng tuyển không tồn tại", HttpStatus.NOT_FOUND);
    private final int code;
    private final String message;
    private HttpStatusCode statusCode;


    ErrorCode(int code, String message, HttpStatusCode statusCode) {
        this.code = code;
        this.message = message;
        this.statusCode = statusCode;
    }
}
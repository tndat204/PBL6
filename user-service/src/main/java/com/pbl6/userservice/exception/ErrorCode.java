package com.pbl6.userservice.exception;

import org.springframework.http.HttpStatus;
import org.springframework.http.HttpStatusCode;

import lombok.Getter;

@Getter
public enum ErrorCode {
    USERNAME_EXISTED(1001, "Đã tồn tại username", HttpStatus.BAD_REQUEST),
    EMAIL_EXISTED(1002, "Đã tồn tại email", HttpStatus.BAD_REQUEST),
    PHONE_EXISTED(1003, "Đã tồn tại số điện thoại", HttpStatus.BAD_REQUEST),
    UNCATEGORIZED_EXCEPTION(9999, "Lỗi chưa định nghĩa", HttpStatus.INTERNAL_SERVER_ERROR),
    USERNAME_INVALID(2000, "Tên đăng nhập chưa hợp lệ", HttpStatus.BAD_REQUEST),
    UNAUTHENTICATED(1004, "Chưa xác thực", HttpStatus.UNAUTHORIZED),
    USER_NOT_FOUND(1005, "Người dùng không tồn tại", HttpStatus.NOT_FOUND),
    UNAUTHORIZED(1006, "You do not have permission", HttpStatus.FORBIDDEN),
    INVALID_DOB(1008, "Your age must be at least {min}", HttpStatus.BAD_REQUEST),
    INVALID_KEY(1009, "Uncategorized error", HttpStatus.BAD_REQUEST),
    EMAIL_NOT_FOUND(1010, "Email not found", HttpStatus.BAD_REQUEST),
    USER_EXISTED(1011,"Tên đăng nhập hoặc email hoặc sdt đã tồn tại",HttpStatus.BAD_REQUEST),
    ROLE_NOT_FOUND(1012,"Vai trò không tồn tại",HttpStatus.BAD_REQUEST),
    ROLE_EXISTED(1020,"Vai trò đã tồn tại",HttpStatus.BAD_REQUEST),
    DEACTIVE_ACCOUNT(1013,"Tài khoản không kích hoạt",HttpStatus.FORBIDDEN),
    OLDPASSWORD_INCORRECT(1014,"Sai mật khẩu cũ",HttpStatus.BAD_REQUEST),
    PROJECT_NOT_FOUND(1015,"Dự án không tồn tại",HttpStatus.BAD_REQUEST),
    NOT_IN_THE_PROJ(1016,"Bạn không có trong dự án này",HttpStatus.BAD_REQUEST),
    GROUPCHAT_NOT_FOUND(1017,"Nhóm trò chuyện không tồn tại",HttpStatus.BAD_REQUEST),
    INVALID_FILE(1018,"File không hợp lệ",HttpStatus.BAD_REQUEST),
    UPLOAD_FILE_FAILED(1019,"Tải file lên không được",HttpStatus.BAD_REQUEST);
    private final int code;
    private final String message;
    private HttpStatusCode statusCode;


    ErrorCode(int code, String message, HttpStatusCode statusCode) {
        this.code = code;
        this.message = message;
        this.statusCode = statusCode;
    }
}
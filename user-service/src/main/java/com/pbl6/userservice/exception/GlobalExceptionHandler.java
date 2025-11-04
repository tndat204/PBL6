package com.pbl6.userservice.exception;

import java.util.Map;
import java.util.stream.Collectors;

import com.pbl6.userservice.dto.response.APIResponse;

import org.springframework.context.support.DefaultMessageSourceResolvable;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.ControllerAdvice;
import org.springframework.web.bind.annotation.ExceptionHandler;


@ControllerAdvice
public class GlobalExceptionHandler {
    private static final String MIN_ATTRIBUTE = "min";
    @ExceptionHandler(MethodArgumentNotValidException.class)
    public ResponseEntity<APIResponse> handleValidationExceptions(MethodArgumentNotValidException ex) {
        APIResponse apiResponse = new APIResponse();
        apiResponse.setCode(ErrorCode.VALIDATION_FAILED.getCode()); // tạo code riêng cho validation
        // Gộp tất cả lỗi field thành 1 message hoặc list
        String message = ex.getBindingResult()
                .getFieldErrors()
                .stream()
                .map(DefaultMessageSourceResolvable::getDefaultMessage)
                .collect(Collectors.joining("; "));
        apiResponse.setMessage(message);
        return ResponseEntity.badRequest().body(apiResponse);
    }
    @ExceptionHandler(value = Exception.class)
    ResponseEntity<APIResponse> handlingException(Exception e) {
        // Tạo đối tượng APIResponse
        APIResponse apiResponse = new APIResponse();

        // Đặt mã lỗi và thông điệp mặc định
        apiResponse.setCode(ErrorCode.UNCATEGORIZED_EXCEPTION.getCode());
        apiResponse.setMessage(ErrorCode.UNCATEGORIZED_EXCEPTION.getMessage());

        // In ra thông tin chi tiết của lỗi trong console
        System.err.println("Exception occurred: " + e.getMessage());

        // Nếu bạn muốn thêm thông tin về lớp lỗi, có thể sử dụng e.getClass().getName()
        System.err.println("Exception class: " + e.getClass().getName());

        // Trả về phản hồi lỗi
        return ResponseEntity.badRequest().body(apiResponse);
    }

    @ExceptionHandler(value = AppException.class)
    ResponseEntity<APIResponse> handlingAppException(AppException e) {
        ErrorCode errorCode = e.getErrorCode();
        APIResponse apiResponse = new APIResponse();
        apiResponse.setCode(errorCode.getCode());
        apiResponse.setMessage(errorCode.getMessage());
        return ResponseEntity.status(errorCode.getStatusCode()).body(apiResponse);
    }

    @ExceptionHandler(value = AccessDeniedException.class)
    ResponseEntity<APIResponse> handlingAccessDeniedException(AccessDeniedException exception) {
        ErrorCode errorCode = ErrorCode.UNAUTHORIZED;

        return ResponseEntity.status(errorCode.getStatusCode())
                .body(APIResponse.builder()
                        .code(errorCode.getCode())
                        .message(errorCode.getMessage())
                        .build());
    }

    private String mapAttribute(String message, Map<String, Object> attributes) {
        String minValue = String.valueOf(attributes.get(MIN_ATTRIBUTE));

        return message.replace("{" + MIN_ATTRIBUTE + "}", minValue);
    }
}
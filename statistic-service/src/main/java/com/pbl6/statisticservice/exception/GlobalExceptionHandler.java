package com.pbl6.statisticservice.exception;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.pbl6.statisticservice.dto.response.APIResponse;
import feign.FeignException;
import org.springframework.context.support.DefaultMessageSourceResolvable;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.ControllerAdvice;
import org.springframework.web.bind.annotation.ExceptionHandler;

import java.util.Map;
import java.util.stream.Collectors;

@ControllerAdvice
public class GlobalExceptionHandler {
    private static final String MIN_ATTRIBUTE = "min";
    @ExceptionHandler(value = FeignException.class)
    ResponseEntity<APIResponse> handlingFeignException(FeignException exception) {
        try {
            // Bước 1: Lấy nội dung lỗi (response body) từ Feign
            String content = exception.contentUTF8();

            // Nếu nội dung rỗng, trả về lỗi mặc định
            if (content == null || content.isEmpty()) {
                return ResponseEntity.status(exception.status()).build();
            }

            // Bước 2: Dùng Jackson ObjectMapper để chuyển chuỗi JSON thành object APIResponse
            ObjectMapper mapper = new ObjectMapper();
            APIResponse apiResponse = mapper.readValue(content, APIResponse.class);

            // Bước 3: Trả về ResponseEntity với status code và body gốc từ service kia
            return ResponseEntity
                    .status(exception.status())
                    .body(apiResponse);

        } catch (JsonProcessingException e) {
            // Trường hợp không parse được JSON (ví dụ service kia chết trả về HTML lỗi),
            // thì fallback về lỗi chung hoặc log ra
            return ResponseEntity
                    .status(exception.status())
                    .body(APIResponse.builder()
                            .code(ErrorCode.UNCATEGORIZED_EXCEPTION.getCode())
                            .message(exception.getMessage()) // Hoặc message tùy chỉnh
                            .build());
        }
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
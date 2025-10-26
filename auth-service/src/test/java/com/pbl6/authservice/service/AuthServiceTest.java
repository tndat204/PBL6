package com.pbl6.authservice.service;

import com.pbl6.authservice.client.UserClient;
import com.pbl6.authservice.dto.request.LoginRequest;
import com.pbl6.authservice.dto.shared.APIResponse;
import com.pbl6.authservice.dto.shared.RoleResponse;
import com.pbl6.authservice.dto.shared.UserResponse;
import com.pbl6.authservice.exception.AppException;
import com.pbl6.authservice.exception.ErrorCode;
import com.pbl6.authservice.repository.InvalidatedTokenRepository;
import com.pbl6.authservice.service.impl.AuthServiceImpl;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.Spy;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.test.util.ReflectionTestUtils;
import java.util.Set;
import java.util.UUID;
import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;


@ExtendWith(MockitoExtension.class)
class AuthServiceTest {

    // 2. @Mock: Tạo các phiên bản giả lập của các dependency
    @Mock
    PasswordEncoder passwordEncoder;

    @Mock
    UserClient userServiceClient;

    @Mock
    InvalidatedTokenRepository invalidatedTokenRepository;

    // **FIX LỖI HERE**: Thay thế @InjectMocks bằng @Spy để có thể kiểm tra
    // tương tác của các phương thức nội bộ (như generateToken)
    @Spy
    @InjectMocks
    AuthServiceImpl authService;

    // Dữ liệu mẫu cho User và Request
    private LoginRequest validRequest;
    private UserResponse activeUser;
    private UserResponse inactiveUser;

    @BeforeEach
    void setUp() {
        // Thiết lập các giá trị @Value bằng ReflectionTestUtils
        ReflectionTestUtils.setField(authService, "SIGN_KEY", "ABCDEF1234567890ABCDEF1234567890ABCDEF1234567890");
        ReflectionTestUtils.setField(authService, "expiration", 3600L);
        ReflectionTestUtils.setField(authService, "refreshDuration", 86400L);

        validRequest = new LoginRequest("test@example.com", "password123");

        activeUser = UserResponse.builder()
                .email("test@example.com")
                .password("encoded_password")
                .enabled(true)
                .id(UUID.fromString("771e84a2-1463-4f9e-b08e-8a03f4f1a6b0"))
                .roles(Set.of(RoleResponse.builder().name("USER").build()))
                .build();

        inactiveUser = UserResponse.builder()
                .email("inactive@example.com")
                .password("encoded_password")
                .enabled(false)
                .id(UUID.fromString("2f5c09d5-4d01-4c6c-940e-7d1a2f6b8c9d"))
                .roles(Set.of(RoleResponse.builder().name("USER").build()))
                .build();
    }

    // --- TEST CASES CHO PHƯƠNG THỨC login ---

    @Test
    @DisplayName("Login thành công với người dùng hợp lệ và mật khẩu đúng")
    void login_ValidUserAndCorrectPassword_ReturnsAuthenticationResponse() {
        // GIVEN
        when(userServiceClient.getUserByEmail(validRequest.getEmail()))
                .thenReturn(APIResponse.<UserResponse>builder().result(activeUser).build());

        when(passwordEncoder.matches(validRequest.getPassword(), activeUser.getPassword()))
                .thenReturn(true);

        // Giả lập phương thức generateToken trên đối tượng @Spy
        // **Đã sửa**: Sử dụng trực tiếp 'authService' vì nó là @Spy
        doReturn("mocked_jwt_token").when(authService).generateToken(any(UserResponse.class), any(Long.class));

        // WHEN
        var response = authService.login(validRequest);

        // THEN
        assertNotNull(response);
        assertEquals("mocked_jwt_token", response.getToken());

        // Kiểm tra tương tác trên đối tượng @Spy
        verify(userServiceClient, times(1)).getUserByEmail(validRequest.getEmail());
        verify(passwordEncoder, times(1)).matches(validRequest.getPassword(), activeUser.getPassword());
        verify(authService, times(1)).generateToken(activeUser, 3600L);
    }

    @Test
    @DisplayName("Login thất bại khi người dùng không tồn tại")
    void login_UserNotFound_ThrowsUserNotFoundException() {
        // GIVEN
        when(userServiceClient.getUserByEmail(any())).thenReturn(APIResponse.<UserResponse>builder().result(null).build());

        // WHEN & THEN
        AppException exception = assertThrows(AppException.class, () -> authService.login(validRequest));
        assertEquals(ErrorCode.USER_NOT_FOUND, exception.getErrorCode());

        verify(passwordEncoder, never()).matches(any(), any());
    }

    @Test
    @DisplayName("Login thất bại khi mật khẩu không đúng")
    void login_WrongPassword_ThrowsWrongPasswordException() {
        // GIVEN
        when(userServiceClient.getUserByEmail(validRequest.getEmail()))
                .thenReturn(APIResponse.<UserResponse>builder().result(activeUser).build());

        when(passwordEncoder.matches(validRequest.getPassword(), activeUser.getPassword()))
                .thenReturn(false);

        // WHEN & THEN
        AppException exception = assertThrows(AppException.class, () -> authService.login(validRequest));
        assertEquals(ErrorCode.WRONG_PASSWORD, exception.getErrorCode());

        // **Đã sửa**: Verify trên đối tượng @Spy đã được fix
        verify(passwordEncoder, times(1)).matches(validRequest.getPassword(), activeUser.getPassword());
        verify(authService, never()).generateToken(any(), any());
    }

    @Test
    @DisplayName("Login thất bại khi tài khoản bị vô hiệu hóa (Disabled)")
    void login_DeactiveAccount_ThrowsDeactiveAccountException() {
        // GIVEN
        LoginRequest inactiveRequest = new LoginRequest("inactive@example.com", "password456");

        when(userServiceClient.getUserByEmail(inactiveRequest.getEmail()))
                .thenReturn(APIResponse.<UserResponse>builder().result(inactiveUser).build());

        when(passwordEncoder.matches(inactiveRequest.getPassword(), inactiveUser.getPassword()))
                .thenReturn(true);

        // WHEN & THEN
        AppException exception = assertThrows(AppException.class, () -> authService.login(inactiveRequest));
        assertEquals(ErrorCode.DEACTIVE_ACCOUNT, exception.getErrorCode());

        // **Đã sửa**: Verify trên đối tượng @Spy đã được fix
        verify(authService, never()).generateToken(any(), any());
    }

    // --- TEST CASES CHO PHƯƠNG THỨC getUserByEmail ---

    @Test
    @DisplayName("getUserByEmail thành công")
    void getUserByEmail_Success_ReturnsUserResponse() {
        // GIVEN
        when(userServiceClient.getUserByEmail(activeUser.getEmail()))
                .thenReturn(APIResponse.<UserResponse>builder().result(activeUser).build());

        // WHEN
        var user = authService.getUserByEmail(activeUser.getEmail());

        // THEN
        assertNotNull(user);
        assertEquals(activeUser.getEmail(), user.getEmail());
        verify(userServiceClient, times(1)).getUserByEmail(activeUser.getEmail());
    }

    @Test
    @DisplayName("getUserByEmail thất bại do lỗi Feign Client")
    void getUserByEmail_FeignError_ThrowsUnauthenticatedException() {
        // GIVEN
        doThrow(new RuntimeException("Feign connection error")).when(userServiceClient).getUserByEmail(any());

        // WHEN & THEN
        AppException exception = assertThrows(AppException.class, () -> authService.getUserByEmail("any@email.com"));
        assertEquals(ErrorCode.UNAUTHENTICATED, exception.getErrorCode());
    }
}

# Gateway Service

Gateway Service đóng vai trò là API Gateway cho hệ thống microservices, thực hiện routing và xác thực JWT trước khi chuyển request xuống các service bên dưới. Gateway cũng hoạt động như Eureka Server để service discovery.

## Cấu hình Port

- **Gateway Service (Eureka Server)**: 8080
- **Auth Service**: 8081  
- **User Service**: 8082
- **Order Service**: 8083

## Eureka Server

Gateway Service cũng hoạt động như Eureka Server để quản lý service discovery:
- **Eureka Dashboard**: http://localhost:8080
- **Eureka API**: http://localhost:8080/eureka/

## Routing Configuration

### 1. Auth Service (Không cần xác thực)
```
GET/POST http://localhost:8080/api/auth/**
→ Routes to: lb://auth-service/api/auth/**
```

### 2. User Service (Cần xác thực JWT)
```
GET/POST http://localhost:8080/api/user/**
→ Routes to: lb://user-service/api/user/**
```

### 3. Order Service (Cần xác thực JWT)
```
GET/POST http://localhost:8080/api/order/**
→ Routes to: lb://order-service/api/order/**
```

**Lưu ý**: `lb://` có nghĩa là load balancing thông qua service discovery của Eureka.

## Public Endpoints (Không cần JWT)

- `/api/auth/**` - Tất cả endpoint của auth service
- `/api/user/add` - Đăng ký user mới
- `/api/user/send-otp` - Gửi OTP
- `/api/user/verify-otp` - Xác thực OTP
- `/api/user/reset-password` - Reset password
- `/actuator/health` - Health check
- `/actuator/info` - Service info

## Protected Endpoints (Cần JWT)

Tất cả các endpoint khác đều cần JWT token trong header:
```
Authorization: Bearer <your-jwt-token>
```

## Cách sử dụng

### 1. Đăng nhập để lấy JWT token
```bash
curl -X POST http://localhost:8080/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "username": "your-username",
    "password": "your-password"
  }'
```

### 2. Sử dụng JWT token cho các request khác
```bash
curl -X GET http://localhost:8080/api/user/profile \
  -H "Authorization: Bearer <your-jwt-token>"
```

## JWT Authentication Flow

1. Client gửi request với JWT token trong header `Authorization: Bearer <token>`
2. Gateway Service extract token từ header
3. Gateway Service gọi Auth Service để validate token qua endpoint `/api/auth/introspect`
4. Nếu token hợp lệ, request được forward đến service tương ứng
5. Nếu token không hợp lệ, trả về 401 Unauthorized

## Error Responses

### 401 Unauthorized
```json
{
  "error": "Missing authentication token",
  "status": 401
}
```

```json
{
  "error": "Invalid authentication token", 
  "status": 401
}
```

## Configuration

Cấu hình trong `application.yml`:

```yaml
auth-service:
  url: http://localhost:8081  # URL của auth service

spring:
  cloud:
    gateway:
      routes:
        - id: auth-service
          uri: http://localhost:8081
          predicates:
            - Path=/api/auth/**
        
        - id: user-service  
          uri: http://localhost:8082
          predicates:
            - Path=/api/user/**
          filters:
            - name: JwtAuthenticationFilter
```

## Development

### Chạy tất cả services (Thứ tự quan trọng)

**1. Chạy Gateway Service trước (Eureka Server)**
```bash
cd gateway-service
mvn spring-boot:run
```

**2. Chạy Auth Service**
```bash
cd auth-service
mvn spring-boot:run
```

**3. Chạy User Service**
```bash
cd user-service
mvn spring-boot:run
```

### Kiểm tra Eureka Dashboard
Sau khi chạy tất cả services, truy cập: http://localhost:8080

Bạn sẽ thấy các service đã đăng ký:
- AUTH-SERVICE
- USER-SERVICE
- GATEWAY-SERVICE

## Testing

Test gateway với các endpoint:

1. **Public endpoint** (không cần token):
```bash
curl http://localhost:8080/api/auth/health
```

2. **Protected endpoint** (cần token):
```bash
curl -H "Authorization: Bearer <valid-token>" http://localhost:8080/api/user/profile
```

3. **Protected endpoint** (không có token):
```bash
curl http://localhost:8080/api/user/profile
# Should return 401 Unauthorized
```

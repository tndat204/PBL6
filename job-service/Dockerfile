# 1. Chọn Base Image (Môi trường chạy Java)
# Nếu bạn dùng Java 21, hãy đổi số 17 thành 21
FROM eclipse-temurin:17-jre-alpine

# 2. Tạo thư mục làm việc trong container
WORKDIR /app

# 3. Copy file .jar đã build từ máy bạn vào trong container
# Lưu ý: Lệnh này giả định bạn đã build ra file .jar trong thư mục target
COPY target/*.jar app.jar

# Hãy sửa số 8081 này khớp với file application.properties của bạn
EXPOSE 8085

# 5. Lệnh chạy ứng dụng khi container khởi động
ENTRYPOINT ["java", "-jar", "app.jar"]
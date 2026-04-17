# PBL6 -  IT Recruitment Platform

![React](https://img.shields.io/badge/Web-React_Vite-61DAFB?logo=react&style=flat-square)
![Flutter](https://img.shields.io/badge/Mobile-Flutter-02569B?logo=flutter&style=flat-square)
![Java](https://img.shields.io/badge/Backend-Java_Spring_Boot-6DB33F?logo=spring&style=flat-square)
![Kafka](https://img.shields.io/badge/Event_Streaming-Apache_Kafka-231F20?logo=apachekafka&style=flat-square)
![PostgreSQL](https://img.shields.io/badge/Database-SQL_%7C_NoSQL-336791?logo=postgresql&style=flat-square)
![AI](https://img.shields.io/badge/AI-CV_Scoring-FF6F00?logo=openai&style=flat-square)

> **Hệ thống Tuyển dụng và Tìm kiếm việc làm ngành CNTT**

## 📖 Giới thiệu

**PBL6** là một nền tảng hỗ trợ tuyển dụng và tìm kiếm việc làm chuyên biệt cho lĩnh vực IT. Dự án được xây dựng dựa trên kiến trúc **Microservices** tiên tiến, đảm bảo khả năng mở rộng cao và hiệu năng xử lý độc lập cho từng dịch vụ.

Hệ thống cung cấp trải nghiệm liền mạch trên cả hai nền tảng: **Web App** (dành cho Nhà tuyển dụng/Admin) và **Mobile App** (dành cho Ứng viên). Điểm nhấn kỹ thuật của dự án là việc tích hợp **AI Server** độc lập để phân tích, chấm điểm CV (CV Scoring) tự động và hệ thống luồng sự kiện (Event Streaming) sử dụng **Apache Kafka** để xử lý dữ liệu thời gian thực.

## ✨ Các tính năng nổi bật

### 🧠 Trí tuệ nhân tạo (AI CV Scoring)
- **Đánh giá tự động:** AI phân tích nội dung, kỹ năng và kinh nghiệm từ CV của ứng viên (định dạng PDF/Word) để đối chiếu với yêu cầu của Job Description (JD).
- **Trích xuất dữ liệu:** Tự động điền thông tin profile dựa trên CV tải lên.

### 🏢 Phân hệ Nhà tuyển dụng (Web)
- **Quản lý tuyển dụng:** Đăng tin, quản lý chiến dịch, lọc và theo dõi trạng thái hồ sơ.
- **Thống kê Real-time:** Dashboard hiển thị số liệu thống kê luồng ứng viên, lượt xem tin tuyển dụng (được tối ưu hóa bằng Redis Cache).

### 👨‍💻 Phân hệ Ứng viên (Mobile App)
- **Khám phá cơ hội:** Tìm kiếm việc làm với bộ lọc sâu về kỹ năng IT, địa điểm, mức lương.
- **Quản lý Profile & CV:** Tạo mới, cập nhật và lưu trữ nhiều phiên bản CV khác nhau.
- **Thông báo tức thời:** Nhận Push Notification ngay khi có kết quả ứng tuyển hoặc tin nhắn từ nhà tuyển dụng.

## 🏗️ Kiến trúc Hệ thống

Hệ thống được thiết kế theo mô hình **Microservices Architecture**, sử dụng Spring Cloud Gateway làm API Gateway định tuyến và Kafka để giao tiếp bất đồng bộ giữa các service.

```mermaid
graph TD
    %% Clients
    subgraph Frontend Clients
        Web[ReactJS Web App]
        Mob[Flutter Mobile App]
    end

    %% AI
    AI[AI Server: CV Scoring]

    %% Gateway Layer
    subgraph API Gateway Layer
        Gateway[Spring Cloud Gateway]
        Eureka[Eureka Discovery Service]
    end

    %% Microservices Layer
    subgraph Spring Boot Microservices
        Auth[Auth Service]
        User[User Service]
        Profile[Profile Service - CV]
        Job[Job Service]
        File[File Service]
        Chat[Chat Service - WebSocket]
        Notif[Notification Service - WebSocket]
        Stat[Statistic Service]
        
        Kafka{{Apache Kafka - Messaging & Async}}
        Redis[(Redis Cache)]
    end

    %% Databases Layer
    subgraph Data Layer
        SQL[(SQL Databases)]
        NoSQL[(NoSQL Databases)]
    end

    %% External
    subgraph External Services
        Supa[Supabase]
        Brevo[Brevo Email]
    end

    %% Connections
    Web & Mob -->|HTTPS/REST & WebSocket| Gateway
    Web & Mob -->|HTTPS/REST| AI
    
    Gateway --> Auth & User & Profile & Job & File & Chat & Notif & Stat
    Gateway -.-> Eureka
    
    %% Kafka Pub/Sub
    Auth & User & Profile & Job & File & Chat & Notif & Stat <-->|Pub/Sub| Kafka
    
    Stat <--> Redis
    Notif --> Brevo
    File --> Supa
    
    %% DB Connections (Simplified)
    Auth & User & Job & Profile --> SQL
    Chat & Stat --> NoSQL

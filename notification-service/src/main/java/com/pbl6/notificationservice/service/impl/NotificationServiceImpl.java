package com.pbl6.notificationservice.service.impl;

import com.pbl6.event.dto.ApplicationStatusChangedEvent;
import com.pbl6.event.dto.NotiEvent;
import com.pbl6.notificationservice.dto.response.NotificationResponse;
import com.pbl6.notificationservice.entity.Notification;
import com.pbl6.notificationservice.entity.enums.NotificationType;
import com.pbl6.notificationservice.repository.NotificationRepository;
import com.pbl6.notificationservice.service.NotificationService;
import lombok.AccessLevel;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.RequiredArgsConstructor;
import lombok.experimental.FieldDefaults;
import lombok.extern.slf4j.Slf4j;
import org.modelmapper.ModelMapper;
import org.springframework.kafka.annotation.KafkaListener;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Slf4j
@FieldDefaults(level = AccessLevel.PRIVATE, makeFinal = true)
public class NotificationServiceImpl implements NotificationService {
    NotificationRepository notificationRepository;
    SimpMessagingTemplate messagingTemplate;
    ModelMapper modelMapper;
    @KafkaListener(topics = "application_status_topic", groupId = "notification-group")
    public void listenApplicationStatus(ApplicationStatusChangedEvent event) {
        log.info("Nhận sự kiện Application Status: {}", event);

        // 1. "Chế biến" dữ liệu thô thành Title/Message
        NotificationContent content = buildContent(event);

        // 2. Map sang Entity Notification (để lưu DB MongoDB)
        Notification notification = Notification.builder()
                .recipientId(event.getApplicantId()) // Lấy từ event
                .title(content.getTitle())           // Lấy từ logic chế biến
                .message(content.getMessage())       // Lấy từ logic chế biến
                .type(NotificationType.JOB_APPLICATION)
                .isRead(false)
                .createdAt(LocalDateTime.now())
                .build();

        // 3. Lưu DB
        Notification savedNoti = notificationRepository.save(notification);

        // 4. Bắn Socket
        messagingTemplate.convertAndSend("/topic/user/" + event.getApplicantId() + "/notify", savedNoti);
    }
    private NotificationContent buildContent(ApplicationStatusChangedEvent event) {
        String job = event.getJobTitle();
        String company = event.getCompanyName();

        switch (event.getStatus()) {
            case "SUBMITTED":
                return new NotificationContent(
                        "Ứng tuyển thành công",
                        String.format("Hồ sơ ứng tuyển vị trí %s tại %s của bạn đã được gửi đi thành công.", job, company)
                );

            case "REVIEWED":
                return new NotificationContent(
                        "Hồ sơ đang được xem xét",
                        String.format("Tin vui! Nhà tuyển dụng tại %s đã xem hồ sơ %s của bạn.", company, job)
                );

            case "INTERVIEW":
                return new NotificationContent(
                        "Mời phỏng vấn!",
                        String.format("Chúc mừng! Bạn nhận được lời mời phỏng vấn cho vị trí %s tại %s. Hãy kiểm tra email để biết chi tiết.", job, company)
                );

            case "HIRED":
                return new NotificationContent(
                        "🎉 Chúc mừng bạn đã trúng tuyển!",
                        String.format("Tuyệt vời! Bạn đã được %s tuyển dụng cho vị trí %s. Hãy chuẩn bị cho hành trình mới nhé!", company, job)
                );

            case "REJECTED":
                return new NotificationContent(
                        "Cập nhật trạng thái hồ sơ",
                        String.format("Cảm ơn bạn đã quan tâm đến vị trí %s tại %s. Tuy nhiên hồ sơ của bạn chưa phù hợp vào lúc này.", job, company)
                );

            default:
                return new NotificationContent(
                        "Cập nhật hồ sơ",
                        "Trạng thái hồ sơ ứng tuyển của bạn đã thay đổi."
                );
        }
    }
    // --- CÁC HÀM HỖ TRỢ API ---

    // Lấy danh sách lịch sử
    public List<NotificationResponse> getNotifications() {
        UUID userId=getCurrentUserId();
        List<Notification> notifications=notificationRepository.findByRecipientIdOrderByCreatedAtDesc(String.valueOf(userId));
        return notifications.stream()
                .map(notification -> modelMapper.map(notification, NotificationResponse.class))
                .collect(Collectors.toList());
    }

    // Đánh dấu đã đọc
    public void markAsRead(String id) {
        notificationRepository.findById(id).ifPresent(noti -> {
            noti.setRead(true);
            notificationRepository.save(noti);
        });
    }

    // Đánh dấu tất cả là đã đọc
    public void markAllAsRead() {
        UUID userId=getCurrentUserId();
        List<Notification> notis = notificationRepository.findByRecipientIdOrderByCreatedAtDesc(String.valueOf(userId));
        notis.forEach(n -> n.setRead(true));
        notificationRepository.saveAll(notis);
    }
    private UUID getCurrentUserId() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        if (!(authentication.getPrincipal() instanceof Jwt jwt)) {
            throw new RuntimeException("Cannot get userId from token");
        }
        return UUID.fromString(jwt.getClaimAsString("userId"));
    }
    @Data
    @AllArgsConstructor
    private static class NotificationContent {
        private String title;
        private String message;
    }
}

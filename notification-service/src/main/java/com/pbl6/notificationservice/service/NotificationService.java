package com.pbl6.notificationservice.service;

import com.pbl6.event.dto.ApplicationStatusChangedEvent;
import com.pbl6.event.dto.NotiEvent;
import com.pbl6.notificationservice.dto.response.NotificationResponse;
import com.pbl6.notificationservice.entity.Notification;

import java.util.List;

public interface NotificationService {
    public void listenApplicationStatus(ApplicationStatusChangedEvent event);
    public List<NotificationResponse> getNotifications();
    public void markAsRead(String id);
    public void markAllAsRead();
}

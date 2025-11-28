package com.pbl6.event.dto;

import lombok.AccessLevel;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.experimental.FieldDefaults;

// Tại Notification Service
@Data
@NoArgsConstructor
@AllArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE)
public class ApplicationStatusChangedEvent {
    String applicationId;
    String applicantId;
    String status;
    String jobTitle;
    String companyName;
}
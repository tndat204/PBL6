package com.pbl6.jobservice.dto.response;

import com.pbl6.jobservice.entity.ReviewReport;
import lombok.*;
import lombok.experimental.FieldDefaults;

import java.time.LocalDateTime;
import java.util.UUID;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE)
public class ReportResponse {
    UUID id;
    UUID reviewId;
    UUID reporterId;
    ReviewReport.ReportReason reason;
    String description;
    ReviewReport.ReportStatus status;
    LocalDateTime createdAt;
}

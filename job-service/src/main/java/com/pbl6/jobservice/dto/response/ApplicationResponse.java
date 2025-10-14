package com.pbl6.jobservice.dto.response;

import lombok.*;
import lombok.experimental.FieldDefaults;

import java.time.LocalDateTime;
import java.util.UUID;
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE)
public class ApplicationResponse {
    UUID applicationId;
    UUID jobId;
    UUID applicantId;
    String status;
    String notes;
    String cvFileUrl;
    LocalDateTime appliedDate;
}

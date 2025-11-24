package com.pbl6.jobservice.dto.request;

import com.pbl6.jobservice.entity.ReviewReport;
import jakarta.validation.constraints.NotNull;
import lombok.*;
import lombok.experimental.FieldDefaults;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE)
public class ReportStatusRequest {
    @NotNull(message = "Status is required")
    ReviewReport.ReportStatus status;
}

package com.pbl6.jobservice.dto.response;

import com.pbl6.jobservice.entity.ReviewReport;
import lombok.*;
import lombok.experimental.FieldDefaults;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE)
public class ReasonResponse {
    ReviewReport.ReportReason key;
    String label;
    String description;
}

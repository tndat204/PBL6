package com.pbl6.jobservice.dto.request;

import com.pbl6.jobservice.entity.Job;
import lombok.*;
import lombok.experimental.FieldDefaults;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.Date;
import java.util.Set;
import java.util.UUID;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE)
public class CreateJobRequest {
    UUID companyId;
    String title;
    String description;
    Job.JobStatus status;
    BigDecimal salaryMin;
    BigDecimal salaryMax;
    Job.JobType jobType;
    Set<UUID> categoryIds;
    Set<UUID> skillIds;
    String location;
    Date expiryDate;
}

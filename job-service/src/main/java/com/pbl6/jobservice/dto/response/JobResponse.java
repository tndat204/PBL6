package com.pbl6.jobservice.dto.response;

import com.pbl6.jobservice.entity.Job;
import lombok.*;
import lombok.experimental.FieldDefaults;

import java.math.BigDecimal;
import java.util.Date;
import java.util.Set;
import java.util.UUID;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE)
public class JobResponse {
    UUID id;
    String companyId;
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
    UUID postedBy;
}

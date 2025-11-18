package com.pbl6.jobservice.dto.request;

import com.pbl6.jobservice.entity.Job;
import lombok.*;
import lombok.experimental.FieldDefaults;
import org.springframework.web.multipart.MultipartFile;

import java.math.BigDecimal;
import java.util.Date;
import java.util.Set;
import java.util.UUID;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE)
public class UpdateJobRequest {
    String title;
    String description;
    Job.JobStatus status;
    BigDecimal salaryMin;
    BigDecimal salaryMax;
    Job.JobType jobType;
    Job.ExperienceLevel experienceLevel;
    Integer requiredYearsOfExpMin;
    Integer requiredYearsOfExpMax;
    MultipartFile jdFile;
    Set<UUID> categoryIds;
    Set<UUID> skillIds;
    String location;
    Date expiryDate;
}

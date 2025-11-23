package com.pbl6.event.dto;

import lombok.AccessLevel;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.experimental.FieldDefaults;

import java.math.BigDecimal;
import java.util.Set;
import java.util.UUID;

@Data
@NoArgsConstructor
@AllArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE)
public class JobClosedEvent {
    String jobId;
    String experienceLevel;
    Set<UUID> skillIds;
    BigDecimal salaryMin;
    BigDecimal salaryMax;
    String location;
}

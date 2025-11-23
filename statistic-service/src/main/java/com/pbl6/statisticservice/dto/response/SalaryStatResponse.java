package com.pbl6.statisticservice.dto.response;

import lombok.*;
import lombok.experimental.FieldDefaults;

import java.io.Serializable;
import java.math.BigDecimal;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE)
public class SalaryStatResponse implements Serializable {
    static final long serialVersionUID = 1L;
    String experienceLevel;
    BigDecimal avgSalaryMin;
    BigDecimal avgSalaryMax;
    long jobCount;
}

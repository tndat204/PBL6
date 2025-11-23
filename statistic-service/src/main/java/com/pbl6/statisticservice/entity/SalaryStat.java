package com.pbl6.statisticservice.entity;

import lombok.Data;
import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.mapping.Document;
import org.springframework.data.mongodb.core.mapping.Field;
import org.springframework.data.mongodb.core.mapping.FieldType;

import java.math.BigDecimal;

@Data
@Document("salary_stats")
public class SalaryStat {

    @Id
    private String experienceLevel;
    @Field(targetType = FieldType.DECIMAL128)
    private BigDecimal totalSalaryMin = BigDecimal.ZERO;
    @Field(targetType = FieldType.DECIMAL128)
    private BigDecimal totalSalaryMax = BigDecimal.ZERO;

    private long jobCount = 0;
}
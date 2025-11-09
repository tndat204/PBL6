package com.pbl6.statisticservice.entity;

import lombok.Data;
import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.mapping.Document;

@Data
@Document("experience_level_stats") // Tên collection
public class ExperienceLevelStat {

    @Id
    private String level; // Chính là tên của ExperienceLevel (ví dụ: "JUNIOR", "SENIOR")

    private long count = 0; // Số lượng job đang active

    public ExperienceLevelStat(String level) {
        this.level = level;
    }
}
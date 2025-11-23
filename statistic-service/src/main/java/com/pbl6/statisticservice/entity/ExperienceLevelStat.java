package com.pbl6.statisticservice.entity;

import lombok.Data;
import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.mapping.Document;

@Data
@Document("experience_level_stats") // Tên collection
public class ExperienceLevelStat {

    @Id
    private String level;

    private long count = 0;

    public ExperienceLevelStat(String level) {
        this.level = level;
    }
}
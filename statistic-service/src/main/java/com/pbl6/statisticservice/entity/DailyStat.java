package com.pbl6.statisticservice.entity;

import lombok.Data;
import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.mapping.Document;

@Data
@Document("daily_stats")
public class DailyStat {

    @Id
    private String id;

    private long newUsers = 0;
    private long newJobs = 0;
    private long newApplications = 0;

    public DailyStat(String id) {
        this.id = id;
    }

    public DailyStat() {}
}
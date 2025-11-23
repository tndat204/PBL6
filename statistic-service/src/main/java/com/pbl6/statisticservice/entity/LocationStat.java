package com.pbl6.statisticservice.entity;

import lombok.Data;
import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.mapping.Document;

@Data
@Document("location_stats")
public class LocationStat {

    @Id
    private String location;

    private long jobCount = 0;

    public LocationStat(String location) {
        this.location = location;
    }

    public LocationStat() {}
}

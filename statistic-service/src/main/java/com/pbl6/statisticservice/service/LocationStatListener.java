package com.pbl6.statisticservice.service;

import com.pbl6.event.dto.JobClosedEvent;
import com.pbl6.event.dto.JobPostedEvent;
import com.pbl6.statisticservice.entity.LocationStat;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.mongodb.core.MongoTemplate;
import org.springframework.data.mongodb.core.query.Criteria;
import org.springframework.data.mongodb.core.query.Query;
import org.springframework.data.mongodb.core.query.Update;
import org.springframework.kafka.annotation.KafkaListener;
import org.springframework.stereotype.Service;

@Service
public class LocationStatListener {

    @Autowired
    private MongoTemplate mongoTemplate;

    /**
     * Hàm update chung
     */
    private void updateLocationStat(String rawLocation, int count) {
        if (rawLocation == null || rawLocation.isBlank()) return;

        // Chuẩn hóa: Cắt khoảng trắng đầu đuôi
        // (Tùy nghiệp vụ có muốn lowercase hay không, ở đây tôi giữ nguyên Case)
        String location = rawLocation.trim();

        Query query = new Query(Criteria.where("_id").is(location));
        Update update = new Update().inc("jobCount", count);

        mongoTemplate.upsert(query, update, LocationStat.class);
    }

    @KafkaListener(topics = "job_posted_topic", groupId = "statistic-location-group")
    public void handleJobPosted(JobPostedEvent event) {
        updateLocationStat(event.getLocation(), 1);
    }

    @KafkaListener(topics = "job_closed_topic", groupId = "statistic-location-group")
    public void handleJobClosed(JobClosedEvent event) {
        updateLocationStat(event.getLocation(), -1);
    }
}

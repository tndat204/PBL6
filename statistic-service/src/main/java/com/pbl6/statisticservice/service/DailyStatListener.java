package com.pbl6.statisticservice.service;

import com.pbl6.event.dto.*;
import com.pbl6.statisticservice.entity.DailyStat;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.mongodb.core.MongoTemplate;
import org.springframework.data.mongodb.core.query.Criteria;
import org.springframework.data.mongodb.core.query.Query;
import org.springframework.data.mongodb.core.query.Update;
import org.springframework.kafka.annotation.KafkaListener;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.time.ZoneId;

@Service
public class DailyStatListener {

    @Autowired
    private MongoTemplate mongoTemplate;

    private String getToday() {
        return LocalDate.now(ZoneId.of("Asia/Ho_Chi_Minh")).toString();
    }

    private void incrementDailyStat(String fieldName) {
        String today = getToday();

        Query query = new Query(Criteria.where("_id").is(today));
        Update update = new Update().inc(fieldName, 1);

        mongoTemplate.upsert(query, update, DailyStat.class);
    }


    @KafkaListener(topics = "user_registered_topic", groupId = "statistic-daily-group")
    public void handleUserRegistered(UserRegisteredEvent event) {
        incrementDailyStat("newUsers");
    }

    @KafkaListener(topics = "job_posted_topic", groupId = "statistic-daily-group")
    public void handleJobPosted(JobPostedEvent event) {
        incrementDailyStat("newJobs");
    }

    @KafkaListener(topics = "application_submitted_topic", groupId = "statistic-daily-group")
    public void handleApplicationSubmitted(ApplicationSubmittedEvent event) {
        incrementDailyStat("newApplications");
    }
}
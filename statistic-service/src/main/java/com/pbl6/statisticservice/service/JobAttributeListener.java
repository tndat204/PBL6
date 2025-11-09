package com.pbl6.statisticservice.service;

import com.pbl6.event.dto.JobClosedEvent;
import com.pbl6.event.dto.JobPostedEvent;
import com.pbl6.statisticservice.entity.ExperienceLevelStat;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.mongodb.core.MongoTemplate;
import org.springframework.data.mongodb.core.query.Criteria;
import org.springframework.data.mongodb.core.query.Query;
import org.springframework.data.mongodb.core.query.Update;
import org.springframework.kafka.annotation.KafkaListener;
import org.springframework.stereotype.Service;

@Service
public class JobAttributeListener {

    @Autowired
    private MongoTemplate mongoTemplate;

    /**
     * Hàm lõi: Tăng/giảm bộ đếm cho một cấp bậc
     */
    private void updateExperienceCounter(String level, long amount) {
        if (level == null || level.isEmpty()) {
            return; // Bỏ qua nếu event không có dữ liệu
        }

        Query query = new Query(Criteria.where("_id").is(level));
        Update update = new Update().inc("count", amount);

        // Dùng upsert để tự động tạo document nếu (ví dụ: "JUNIOR") chưa tồn tại
        mongoTemplate.upsert(query, update, ExperienceLevelStat.class);
    }

    /**
     * Lắng nghe sự kiện Job được đăng
     */
    @KafkaListener(topics = "job_posted_topic",
            groupId = "statistic-job-attribute-group") // Dùng group ID mới
    public void handleJobPosted(JobPostedEvent event) {
        // Tăng bộ đếm cho cấp bậc tương ứng
        updateExperienceCounter(event.getExperienceLevel(), 1);
    }

    /**
     * Lắng nghe sự kiện Job bị đóng
     */
    @KafkaListener(topics = "job_closed_topic",
            groupId = "statistic-job-attribute-group") // Dùng chung group ID
    public void handleJobClosed(JobClosedEvent event) {
        // Giảm bộ đếm cho cấp bậc tương ứng
        updateExperienceCounter(event.getExperienceLevel(), -1);
    }
}
package com.pbl6.statisticservice.service;

import com.pbl6.event.dto.JobClosedEvent;
import com.pbl6.event.dto.JobPostedEvent;
import com.pbl6.statisticservice.entity.SalaryStat;
import org.springframework.beans.factory.annotation.Autowired; // Nhớ import cái này
import org.springframework.data.mongodb.core.MongoTemplate;
import org.springframework.data.mongodb.core.query.Criteria;
import org.springframework.data.mongodb.core.query.Query;
import org.springframework.data.mongodb.core.query.Update;
import org.springframework.kafka.annotation.KafkaListener;
import org.springframework.stereotype.Service;
import org.bson.types.Decimal128;
import java.math.BigDecimal;

@Service
public class SalaryStatListener {

    @Autowired
    private MongoTemplate mongoTemplate;

    private void updateSalaryStat(String level, BigDecimal min, BigDecimal max, int sign) {
        if (level == null) return;

        Query query = new Query(Criteria.where("_id").is(level));

        BigDecimal minVal = min.multiply(BigDecimal.valueOf(sign));
        BigDecimal maxVal = max.multiply(BigDecimal.valueOf(sign));

        Update update = new Update()
                .inc("jobCount", sign)
                .inc("totalSalaryMin", new Decimal128(minVal))
                .inc("totalSalaryMax", new Decimal128(maxVal));

        mongoTemplate.upsert(query, update, SalaryStat.class);
    }

    @KafkaListener(topics = "job_posted_topic", groupId = "statistic-salary-group")
    public void handleJobPosted(JobPostedEvent event) {
        // <--- FIX 2: Bỏ qua job nếu lương là "Thỏa thuận" (null) để tránh lỗi
        if (event.getSalaryMin() == null || event.getSalaryMax() == null) {
            return;
        }

        updateSalaryStat(
                event.getExperienceLevel(),
                event.getSalaryMin(),
                event.getSalaryMax(),
                1 // Dấu dương
        );
    }

    @KafkaListener(topics = "job_closed_topic", groupId = "statistic-salary-group")
    public void handleJobClosed(JobClosedEvent event) {
        // <--- FIX 3: Cũng phải check null khi đóng job
        if (event.getSalaryMin() == null || event.getSalaryMax() == null) {
            return;
        }

        updateSalaryStat(
                event.getExperienceLevel(),
                event.getSalaryMin(),
                event.getSalaryMax(),
                -1 // Dấu âm
        );
    }
}
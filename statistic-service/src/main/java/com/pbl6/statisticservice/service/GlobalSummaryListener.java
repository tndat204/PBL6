package com.pbl6.statisticservice.service;

import com.pbl6.event.dto.*;
import com.pbl6.statisticservice.entity.GlobalSummary;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.mongodb.core.MongoTemplate;
import org.springframework.data.mongodb.core.query.Criteria;
import org.springframework.data.mongodb.core.query.Query;
import org.springframework.data.mongodb.core.query.Update;
import org.springframework.kafka.annotation.KafkaListener;
import org.springframework.stereotype.Service;

@Service
public class GlobalSummaryListener {

    // ID cố định cho document duy nhất của chúng ta
    private static final String SUMMARY_DOC_ID = "main_summary";

    @Autowired
    private MongoTemplate mongoTemplate;

    /**
     * Hàm lõi: Tăng (hoặc giảm) một trường trong document
     * @param fieldName Tên trường trong GlobalSummary (ví dụ: "totalUsers")
     * @param amount Số lượng muốn tăng (ví dụ: 1) hoặc giảm (ví dụ: -1)
     */
    private void incrementCounter(String fieldName, long amount) {
        // 1. Tìm document có _id = "main_summary"
        Query query = new Query(Criteria.where("_id").is(SUMMARY_DOC_ID));

        // 2. Định nghĩa hành động: Tăng ($inc) trường 'fieldName' lên 'amount'
        Update update = new Update().inc(fieldName, amount);

        // 3. Thực hiện UPSERT:
        // - Nếu document "main_summary" TỒN TẠI: Nó sẽ cập nhật (tăng) trường đó.
        // - Nếu document "main_summary" CHƯA TỒN TẠI: Nó sẽ TẠO MỚI
        //   document với id="main_summary" và set fieldName = amount.
        mongoTemplate.upsert(query, update, GlobalSummary.class);
    }

    //--- CÁC BỘ LẮNG NGHE KAFKA ---

    @KafkaListener(topics = "user_registered_topic",
            groupId = "statistic-summary-group")
    public void handleUserRegistered(UserRegisteredEvent event) {
        // Tăng tổng số user
        incrementCounter("total_users", 1);

        // Phân loại user dựa trên role
        if (event.getRoles().contains("APPLICANT")) {
            incrementCounter("total_applicants", 1);
        }
        if (event.getRoles().contains("RECRUITER")) {
            incrementCounter("total_recruiters", 1);
        }
        if (event.getRoles().contains("ADMIN")) {
            incrementCounter("total_admin", 1);
        }
    }

    @KafkaListener(topics = "company_registered_topic",
            groupId = "statistic-summary-group")
    public void handleCompanyRegistered(CompanyRegisteredEvent event) {
        // Tăng tổng số công ty đã đăng ký
        incrementCounter("total_companies", 1);
    }

    @KafkaListener(topics = "company_activated_topic",
            groupId = "statistic-summary-group")
    public void handleCompanyActivated(CompanyActivatedEvent event) {
        // Tăng tổng số công ty đã được duyệt
        incrementCounter("total_active_companies", 1);
    }

    @KafkaListener(topics = "job_posted_topic",
            groupId = "statistic-summary-group")
    public void handleJobPosted(JobPostedEvent event) {
        // Tăng số job đang hoạt động
        incrementCounter("total_active_jobs", 1);
    }

    @KafkaListener(topics = "job_closed_topic",
            groupId = "statistic-summary-group")
    public void handleJobClosed(JobClosedEvent event) {
        // Giảm số job đang hoạt động
        incrementCounter("total_active_jobs", -1);
    }

    @KafkaListener(topics = "application_submitted_topic",
            groupId = "statistic-summary-group")
    public void handleApplicationSubmitted(ApplicationSubmittedEvent event) {
        incrementCounter("total_applications", 1);
    }

    @KafkaListener(topics = "application_status_topic",
            groupId = "statistic-summary-group")
    public void handleApplicationStatusChanged(ApplicationStatusChangedEvent event) {
        // Chỉ tăng khi trạng thái là "HIRED"
        if ("HIRED".equals(event.getStatus())) {
            incrementCounter("total_jobs_hired", 1);
        }
    }

    @KafkaListener(topics = "company_deactivated_topic",
            groupId = "statistic-summary-group")
    public void handleCompanyDeactivated(CompanyDeactivatedEvent event) {
        // Giảm tổng số công ty đang hoạt động
        incrementCounter("total_active_companies", -1);
    }
}
package com.pbl6.statisticservice.entity;

import lombok.Data;
import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.mapping.Document;
import org.springframework.data.mongodb.core.mapping.Field;

@Data
@Document("global_summary")
public class GlobalSummary {

    @Id
    private String id;

    // --- User Stats ---
    @Field("total_users")
    private long totalUsers = 0;

    @Field("total_applicants")
    private long totalApplicants = 0;

    @Field("total_recruiters")
    private long totalRecruiters = 0;

    @Field("total_admin")
    private long totalAdmin = 0;

    // --- Company Stats ---
    @Field("total_companies")
    private long totalCompanies = 0;

    @Field("total_active_companies")
    private long totalActiveCompanies = 0;

    // --- Job & Application Stats ---
    @Field("total_active_jobs")
    private long totalActiveJobs = 0;

    @Field("total_applications")
    private long totalApplications = 0;

    @Field("total_jobs_hired")
    private long totalJobsHired = 0;


    public GlobalSummary(String id) {
        this.id = id;
    }

    public GlobalSummary() {}
}

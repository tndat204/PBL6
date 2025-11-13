package com.pbl6.statisticservice.dto.response;

import lombok.*;
import lombok.experimental.FieldDefaults;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE)
public class GlobalSummaryResponse {
    long totalUsers;
    long totalApplicants;
    long totalRecruiters;
    long totalAdmin;
    long totalCompanies;
    long totalActiveCompanies;
    long totalActiveJobs;
    long totalApplications;
    long totalJobsHired;
}

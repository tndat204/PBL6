package com.pbl6.statisticservice.service;

import com.pbl6.statisticservice.dto.response.ExperienceLevelStatResponse;
import com.pbl6.statisticservice.dto.response.GlobalSummaryResponse;

import java.util.List;

public interface StatisticService {
    public GlobalSummaryResponse getGlobalSummary();
    public List<ExperienceLevelStatResponse> getExperienceStatistics();
}

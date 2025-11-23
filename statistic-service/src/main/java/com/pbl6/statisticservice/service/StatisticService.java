package com.pbl6.statisticservice.service;

import com.pbl6.statisticservice.dto.response.*;
import com.pbl6.statisticservice.entity.DailyStat;

import java.util.List;

public interface StatisticService {
    public GlobalSummaryResponse getGlobalSummary();
    public List<ExperienceLevelStatResponse> getExperienceStatistics();
    public List<SkillStatResponse> getTopSkills(int limit);
    public List<SalaryStatResponse> getSalaryStatistics();
    public List<DailyStatResponse> getGrowthStats(int days);
    public List<LocationStatResponse> getLocationStats();
}

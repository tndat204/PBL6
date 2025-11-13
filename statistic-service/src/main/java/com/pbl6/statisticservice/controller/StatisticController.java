package com.pbl6.statisticservice.controller;

import com.pbl6.statisticservice.dto.response.APIResponse;
import com.pbl6.statisticservice.dto.response.ExperienceLevelStatResponse;
import com.pbl6.statisticservice.dto.response.GlobalSummaryResponse;
import com.pbl6.statisticservice.service.StatisticService;
import lombok.AccessLevel;
import lombok.experimental.FieldDefaults;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/api/statistics")
@FieldDefaults(level= AccessLevel.PRIVATE,makeFinal=true)
public class StatisticController {
    StatisticService statisticService;
    public StatisticController(StatisticService statisticService) {
        this.statisticService = statisticService;
    }
    @GetMapping("/summary")
    public APIResponse<GlobalSummaryResponse> getSummary() {
        return APIResponse.<GlobalSummaryResponse>builder()
                .code(200)
                .result(statisticService.getGlobalSummary())
                .build();
    }
    @GetMapping("/experience")
    public APIResponse<List<ExperienceLevelStatResponse>> getExperienceStats() {
        return APIResponse.<List<ExperienceLevelStatResponse>>builder()
                .code(200)
                .result(statisticService.getExperienceStatistics())
                .build();
    }
}

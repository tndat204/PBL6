package com.pbl6.statisticservice.service.impl;

import com.pbl6.statisticservice.dto.response.ExperienceLevelStatResponse;
import com.pbl6.statisticservice.dto.response.GlobalSummaryResponse;
import com.pbl6.statisticservice.entity.ExperienceLevelStat;
import com.pbl6.statisticservice.entity.GlobalSummary;
import com.pbl6.statisticservice.repository.ExperienceLevelStatRepository;
import com.pbl6.statisticservice.repository.GlobalSummaryRepository;
import com.pbl6.statisticservice.service.StatisticService;
import lombok.AccessLevel;
import lombok.RequiredArgsConstructor;
import lombok.experimental.FieldDefaults;
import lombok.extern.slf4j.Slf4j;
import org.modelmapper.ModelMapper;
import org.springframework.cache.annotation.Cacheable;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.stream.Collectors;

@Service
@FieldDefaults(level = AccessLevel.PRIVATE, makeFinal = true)
@RequiredArgsConstructor
@Slf4j
public class StatisticServiceImpl implements StatisticService {
    GlobalSummaryRepository globalSummaryRepository;
    ExperienceLevelStatRepository experienceLevelStatRepository;
    ModelMapper modelMapper;
    String SUMMARY_DOC_ID = "main_summary";
    @PreAuthorize("hasRole('ADMIN')")
    @Cacheable(value = "stat_global_summary_dto")
    public GlobalSummaryResponse getGlobalSummary() {
        GlobalSummary globalSummary = globalSummaryRepository.findById(SUMMARY_DOC_ID)
                .orElse(new GlobalSummary(SUMMARY_DOC_ID));
        return modelMapper.map(globalSummary, GlobalSummaryResponse.class);
    }

    @PreAuthorize("hasRole('ADMIN')")
    @Cacheable(value = "stat_experience_levels")
    public List<ExperienceLevelStatResponse> getExperienceStatistics() {
        List<ExperienceLevelStat> experienceLevelStats = experienceLevelStatRepository.findAllByOrderByCountDesc();

        return experienceLevelStats.stream()
                .map(entity -> modelMapper.map(entity, ExperienceLevelStatResponse.class))
                .collect(Collectors.toList());
    }
}

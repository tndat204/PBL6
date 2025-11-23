package com.pbl6.statisticservice.service.impl;

import com.pbl6.statisticservice.dto.response.*;
import com.pbl6.statisticservice.entity.*;
import com.pbl6.statisticservice.repository.*;
import com.pbl6.statisticservice.service.StatisticService;
import lombok.AccessLevel;
import lombok.RequiredArgsConstructor;
import lombok.experimental.FieldDefaults;
import lombok.extern.slf4j.Slf4j;
import org.modelmapper.ModelMapper;
import org.springframework.cache.annotation.Cacheable;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDate;
import java.time.ZoneId;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.function.Function;
import java.util.stream.Collectors;

@Service
@FieldDefaults(level = AccessLevel.PRIVATE, makeFinal = true)
@RequiredArgsConstructor
@Slf4j
public class StatisticServiceImpl implements StatisticService {
    GlobalSummaryRepository globalSummaryRepository;
    ExperienceLevelStatRepository experienceLevelStatRepository;
    SkillStatRepository skillStatRepository;
    SalaryStatRepository  salaryStatRepository;
    DailyStatRepository dailyStatRepository;
    LocationStatRepository locationStatRepository;
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

    @Cacheable(value = "stat_top_skills", key = "#limit")
    public List<SkillStatResponse> getTopSkills(int limit) {
        Pageable pageable = PageRequest.of(0, limit);

        List<SkillStat> entities = skillStatRepository.findAllByOrderByJobCountDesc(pageable);

        return entities.stream()
                .map(entity -> modelMapper.map(entity, SkillStatResponse.class))
                .collect(Collectors.toList());
    }

    @Cacheable(value = "stat_salary_by_level")
    public List<SalaryStatResponse> getSalaryStatistics() {
        List<SalaryStat> entities = salaryStatRepository.findAll();

        return entities.stream().map(entity -> {
            SalaryStatResponse dto = new SalaryStatResponse();
            dto.setExperienceLevel(entity.getExperienceLevel());
            dto.setJobCount(entity.getJobCount());

            if (entity.getJobCount() > 0) {
                BigDecimal count = BigDecimal.valueOf(entity.getJobCount());

                // Làm tròn 0 chữ số thập phân (RoundingMode.HALF_UP)
                dto.setAvgSalaryMin(entity.getTotalSalaryMin().divide(count, 0, RoundingMode.HALF_UP));
                dto.setAvgSalaryMax(entity.getTotalSalaryMax().divide(count, 0, RoundingMode.HALF_UP));
            } else {
                dto.setAvgSalaryMin(BigDecimal.ZERO);
                dto.setAvgSalaryMax(BigDecimal.ZERO);
            }
            return dto;
        }).collect(Collectors.toList());
    }

    @PreAuthorize("hasRole('ADMIN')")
    @Cacheable(value = "stat_growth", key = "#days")
    public List<DailyStatResponse> getGrowthStats(int days) {
        LocalDate end = LocalDate.now(ZoneId.of("Asia/Ho_Chi_Minh"));
        LocalDate start = end.minusDays(days - 1);
        List<DailyStat> rawStats = dailyStatRepository.findByDateBetween(start.toString(), end.toString());
        Map<String, DailyStat> statMap = rawStats.stream()
                .collect(Collectors.toMap(DailyStat::getId, Function.identity()));

        List<DailyStatResponse> responseList = new ArrayList<>();
        LocalDate current = start;

        while (!current.isAfter(end)) {
            String dateKey = current.toString();
            DailyStat stat = statMap.getOrDefault(dateKey, new DailyStat(dateKey));
            DailyStatResponse dto = new DailyStatResponse();
            dto.setId(stat.getId());
            dto.setNewUsers(stat.getNewUsers());
            dto.setNewJobs(stat.getNewJobs());
            dto.setNewApplications(stat.getNewApplications());
            responseList.add(dto);
            current = current.plusDays(1);
        }
        return responseList;
    }

    @PreAuthorize("hasRole('ADMIN')")
    @Cacheable(value = "stat_locations")
    public List<LocationStatResponse> getLocationStats() {
        List<LocationStat> result=locationStatRepository.findAllByOrderByJobCountDesc();
        return result.stream()
                .map(entity -> modelMapper.map(entity, LocationStatResponse.class))
                .collect(Collectors.toList());
    }

}

package com.pbl6.statisticservice.repository;

import com.pbl6.statisticservice.entity.ExperienceLevelStat;
import org.springframework.data.mongodb.repository.MongoRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface ExperienceLevelStatRepository extends MongoRepository<ExperienceLevelStat, String> {
    List<ExperienceLevelStat> findAllByOrderByCountDesc();
}

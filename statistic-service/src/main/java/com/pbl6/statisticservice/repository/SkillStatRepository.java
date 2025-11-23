package com.pbl6.statisticservice.repository;

import com.pbl6.statisticservice.entity.SkillStat;
import org.springframework.data.domain.Pageable;
import org.springframework.data.mongodb.repository.MongoRepository;
import org.springframework.stereotype.Repository;
import java.util.List;

@Repository
public interface SkillStatRepository extends MongoRepository<SkillStat, String> {

    List<SkillStat> findAllByOrderByJobCountDesc(Pageable pageable);
}
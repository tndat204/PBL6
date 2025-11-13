package com.pbl6.statisticservice.repository;

import com.pbl6.statisticservice.entity.GlobalSummary;
import org.springframework.data.mongodb.repository.MongoRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface GlobalSummaryRepository extends MongoRepository<GlobalSummary, String> {
}

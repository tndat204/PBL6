package com.pbl6.statisticservice.repository;

import com.pbl6.statisticservice.entity.SalaryStat;
import org.springframework.data.mongodb.repository.MongoRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface SalaryStatRepository extends MongoRepository<SalaryStat, String> {
}

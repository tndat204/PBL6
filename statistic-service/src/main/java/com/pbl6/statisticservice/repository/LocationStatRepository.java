package com.pbl6.statisticservice.repository;

import com.pbl6.statisticservice.entity.LocationStat;
import org.springframework.data.mongodb.repository.MongoRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface LocationStatRepository extends MongoRepository<LocationStat, String> {

    List<LocationStat> findAllByOrderByJobCountDesc();
}

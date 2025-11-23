package com.pbl6.statisticservice.repository;

import com.pbl6.statisticservice.entity.DailyStat;
import org.springframework.data.mongodb.repository.MongoRepository;
import org.springframework.data.mongodb.repository.Query;
import org.springframework.stereotype.Repository;
import java.util.List;

@Repository
public interface DailyStatRepository extends MongoRepository<DailyStat, String> {

    @Query("{ '_id' : { $gte: ?0, $lte: ?1 } }")
    List<DailyStat> findByDateBetween(String from, String to);
}

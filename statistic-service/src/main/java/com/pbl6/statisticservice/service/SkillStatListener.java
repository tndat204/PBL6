package com.pbl6.statisticservice.service;

import com.pbl6.event.dto.JobPostedEvent;
import com.pbl6.statisticservice.entity.SkillStat;
import lombok.AccessLevel;
import lombok.RequiredArgsConstructor;
import lombok.experimental.FieldDefaults;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.mongodb.core.MongoTemplate;
import org.springframework.data.mongodb.core.query.Criteria;
import org.springframework.kafka.annotation.KafkaListener;
import org.springframework.stereotype.Service;
import org.springframework.data.mongodb.core.query.Query;
import org.springframework.data.mongodb.core.query.Update;
import java.util.Set;

@Service
@Slf4j
@RequiredArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE, makeFinal = true)
public class SkillStatListener {
    SkillNameResolver skillNameResolver;
    MongoTemplate mongoTemplate;

    @KafkaListener(topics = "job_posted_topic", groupId = "statistic-skill-group")
    public void handleJobPosted(JobPostedEvent event) {
        Set<String> skillNames = skillNameResolver.resolveSkillNames(event.getSkillIds());

        if (skillNames.isEmpty()) return;

        for (String name : skillNames) {
            String normalizedSkill = name.trim().toLowerCase();
            Query query = new Query(Criteria.where("_id").is(normalizedSkill));
            Update update = new Update().inc("jobCount", 1);

            mongoTemplate.upsert(query, update, SkillStat.class);
        }
    }
}

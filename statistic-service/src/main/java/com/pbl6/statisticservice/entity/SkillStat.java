package com.pbl6.statisticservice.entity;

import lombok.Data;
import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.mapping.Document;

@Data
@Document("skill_stats")
public class SkillStat {
    @Id
    private String skillName;

    private long jobCount;

    public SkillStat(String skillName) {
        this.skillName = skillName;
    }

    public SkillStat() {}
}

package com.pbl6.profileservice.dto.response;

import com.pbl6.profileservice.entity.SkillLevel;
import lombok.*;
import lombok.experimental.FieldDefaults;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE)
public class ProfileSkillResponse {
    SkillResponse skill;
    Integer experienceYears;
    SkillLevel level;
    Boolean isPrimary;
}

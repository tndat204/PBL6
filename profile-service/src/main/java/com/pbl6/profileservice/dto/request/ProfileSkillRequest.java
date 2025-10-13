package com.pbl6.profileservice.dto.request;

import com.pbl6.profileservice.entity.SkillLevel;
import lombok.*;
import lombok.experimental.FieldDefaults;

import java.util.UUID;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE)
public class ProfileSkillRequest {
    UUID skillId;
    Integer experienceYears;
    SkillLevel level;
    Boolean isPrimary;
}

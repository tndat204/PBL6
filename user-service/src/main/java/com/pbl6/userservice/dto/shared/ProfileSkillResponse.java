package com.pbl6.userservice.dto.shared;

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

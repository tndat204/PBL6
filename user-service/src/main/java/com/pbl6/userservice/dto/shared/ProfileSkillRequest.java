package com.pbl6.userservice.dto.shared;

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

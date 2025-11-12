package com.pbl6.userservice.dto.shared;

import lombok.*;
import lombok.experimental.FieldDefaults;

import java.util.Set;
import java.util.UUID;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE)
public class ProfileResponse {
    UUID profileId;
    UUID userId;
    String headline;
    String summary;
    String cvFile;
    String linkedinUrl;
    String portfolioUrl;
    Double desiredSalary;
    Boolean isActive;
    Set<ProfileSkillResponse> skills;
}

package com.pbl6.profileservice.dto.request;

import lombok.*;
import lombok.experimental.FieldDefaults;

import java.util.Set;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE)
public class ProfileRequest {
    String headline;
    String summary;
    String cvFile;
    String linkedinUrl;
    String portfolioUrl;
    Double desiredSalary;
    Set<ProfileSkillRequest> skills;
}

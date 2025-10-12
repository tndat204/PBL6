package com.pbl6.profileservice.dto.response;

import com.pbl6.profileservice.entity.Skill;
import lombok.*;
import lombok.experimental.FieldDefaults;

import java.util.List;
import java.util.UUID;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE)
public class CategoryResponse {
    UUID id;
    String name;
    List<SkillResponse> skills;
}

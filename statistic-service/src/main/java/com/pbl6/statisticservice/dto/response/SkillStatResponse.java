package com.pbl6.statisticservice.dto.response;

import lombok.*;
import lombok.experimental.FieldDefaults;

import java.io.Serializable;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE)
public class SkillStatResponse implements Serializable {
    static final long serialVersionUID = 1L;
    String skillName;
    long jobCount;
}

package com.pbl6.profileservice.entity;

import jakarta.persistence.Embeddable;
import lombok.Getter;
import lombok.Setter;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;
import lombok.EqualsAndHashCode;
import lombok.experimental.FieldDefaults;
import java.io.Serializable;
import java.util.UUID;
import lombok.AccessLevel;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@EqualsAndHashCode // quan trọng cho việc so sánh đối tượng khóa
@FieldDefaults(level = AccessLevel.PRIVATE)
@Embeddable
public class ProfileSkillId implements Serializable {

    private UUID skillId;
    private UUID profileId;
}

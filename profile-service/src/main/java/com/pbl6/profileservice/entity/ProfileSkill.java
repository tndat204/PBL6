package com.pbl6.profileservice.entity;

import com.fasterxml.jackson.annotation.JsonBackReference;
import jakarta.persistence.*;
import lombok.experimental.FieldDefaults;
import java.io.Serializable;

import lombok.Getter;
import lombok.Setter;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;
import lombok.AccessLevel;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Entity
@FieldDefaults(level = AccessLevel.PRIVATE)
@Table(name = "profile_skills")
public class ProfileSkill implements Serializable {

    @EmbeddedId
    ProfileSkillId id;

    Integer experienceYears;

    @Enumerated(EnumType.STRING)
    SkillLevel level;

    Boolean isPrimary;

    @ManyToOne(fetch = FetchType.LAZY)
    @MapsId("profileId") // Vẫn ánh xạ tới trường profileId trong ProfileSkillId
    @JoinColumn(name = "profile_id", referencedColumnName = "id") // Thay đổi tham chiếu đến id của Profile
    @JsonBackReference("profile-skills")
    Profile profile;

    @ManyToOne(fetch = FetchType.LAZY)
    @MapsId("skillId")
    @JoinColumn(name = "skill_id", referencedColumnName = "id")
    @JsonBackReference("skill-profiles")
    Skill skill;
}
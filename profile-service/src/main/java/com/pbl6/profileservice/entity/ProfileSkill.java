package com.pbl6.profileservice.entity;

import com.fasterxml.jackson.annotation.JsonBackReference;
import jakarta.persistence.*;
import lombok.*;
import lombok.experimental.FieldDefaults;
import java.io.Serializable;
import java.util.UUID;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Entity
@FieldDefaults(level = AccessLevel.PRIVATE)
@Table(name = "profile_skills")
@IdClass(ProfileSkill.class)
public class ProfileSkill implements Serializable {

    @Id
    @Column(columnDefinition = "uuid", nullable = false)
    UUID skillId;

    @Id
    @Column(columnDefinition = "uuid", nullable = false)
    UUID profileId;

    Integer experienceYears;

    @Enumerated(EnumType.STRING)
    SkillLevel level;

    Boolean isPrimary;

    @ManyToOne
    @JoinColumn(name = "skillId", insertable = false, updatable = false)
    @JsonBackReference("skill-profiles")
    Skill skill;

    @ManyToOne
    @JoinColumn(name = "profileId", insertable = false, updatable = false)
    @JsonBackReference("profile-skills")
    Profile profile;
}
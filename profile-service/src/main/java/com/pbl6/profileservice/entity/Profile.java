package com.pbl6.profileservice.entity;

import com.fasterxml.jackson.annotation.JsonManagedReference;
import jakarta.persistence.*;
import lombok.AccessLevel;
import lombok.*;
import lombok.experimental.FieldDefaults;

import java.util.Set;
import java.util.UUID;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Entity
@FieldDefaults(level = AccessLevel.PRIVATE)
@Table(name = "profiles")
public class Profile {
    @Id
    @GeneratedValue
    @Column(columnDefinition = "uuid")
    UUID profileId;

    @Column(columnDefinition = "uuid", unique = true, nullable = false)
    UUID userId;

    String headline;

    String summary;

    String cvFile;

    String linkedinUrl;

    String portfolioUrl;

    Double desiredSalary;

    Boolean isActive;

    @OneToMany(mappedBy = "profile", cascade = CascadeType.ALL, orphanRemoval = true)
    @JsonManagedReference("profile-skills")
    Set<ProfileSkill> skills;

}
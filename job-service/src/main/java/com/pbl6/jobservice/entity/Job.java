package com.pbl6.jobservice.entity;

import com.fasterxml.jackson.annotation.JsonIgnore;
import com.fasterxml.jackson.annotation.JsonManagedReference;
import jakarta.persistence.*;
import lombok.*;
import lombok.experimental.FieldDefaults;

import java.math.BigDecimal;
import java.util.Date;
import java.util.HashSet;
import java.util.Set;
import java.util.UUID;
@Entity
@Table(name = "jobs")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
@FieldDefaults(level = AccessLevel.PRIVATE)
public class Job extends Base{
    @Id
    @GeneratedValue
    @Column(columnDefinition = "uuid")
    UUID id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "company_id", nullable = false)
    @JsonIgnore
    Company company;

    @Column(columnDefinition = "uuid")
    UUID postedBy;

    @Column(nullable = false)
    String title;

    @Column(nullable = false, columnDefinition = "TEXT")
    String description;

    @Enumerated(EnumType.STRING)
    @Column(length = 20, nullable = false)
    @Builder.Default
    JobStatus status = JobStatus.ACTIVE;

    @Column(nullable = false)
    String location;

    BigDecimal salaryMin;
    BigDecimal salaryMax;

    Date expiryDate;

    @Enumerated(EnumType.STRING)
    @Column(length = 20)
    JobType jobType;

    @Enumerated(EnumType.STRING)
    @Column(length = 20, nullable = false)
    ExperienceLevel experienceLevel;

    Integer requiredYearsOfExpMin;
    Integer requiredYearsOfExpMax;

    @Column(nullable = false)
    @Builder.Default
    Integer viewCount = 0;

    @Column(nullable = false)
    @Builder.Default
    Integer applicationCount = 0;

    @OneToMany(mappedBy = "job", cascade = CascadeType.ALL, orphanRemoval = true)
    @JsonManagedReference
    @Builder.Default
    Set<JobCategory> categories = new HashSet<>();

    @OneToMany(mappedBy = "job", cascade = CascadeType.ALL, orphanRemoval = true)
    @JsonManagedReference
    @Builder.Default
    Set<JobSkill> skills = new HashSet<>();


    public enum JobStatus { ACTIVE, INACTIVE, CLOSED }
    public enum JobType { FULL_TIME, PART_TIME, CONTRACT, REMOTE }
    public enum ExperienceLevel {
        INTERN, FRESHER, JUNIOR, SENIOR, PRINCIPAL, MANAGER
    }
}


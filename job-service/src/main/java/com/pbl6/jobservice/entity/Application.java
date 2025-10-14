package com.pbl6.jobservice.entity;
import jakarta.persistence.*;
import lombok.*;
import lombok.experimental.FieldDefaults;

import java.time.LocalDateTime;
import java.util.UUID;
@Entity
@Table(name = "applications")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
@FieldDefaults(level = AccessLevel.PRIVATE)
public class Application extends Base{

    @Id
    @GeneratedValue
    @Column(columnDefinition = "uuid")
    UUID applicationId;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "job_id", nullable = false)
    Job job;

    @Column(nullable = false, columnDefinition = "uuid")
    UUID applicantId;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 20)
    Status status = Status.SUBMITTED;

    @Column(columnDefinition = "TEXT")
    String notes;

    @Column(nullable = false)
    LocalDateTime appliedDate;

    String cvFileUrl;

    public enum Status {
        SUBMITTED, REVIEWED, INTERVIEW, HIRED, REJECTED
    }
}


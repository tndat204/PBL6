package com.pbl6.jobservice.entity;
import jakarta.persistence.*;
import lombok.*;
import lombok.experimental.FieldDefaults;

import java.util.UUID;

@Entity
@Table(name = "company_reviews")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
@FieldDefaults(level = AccessLevel.PRIVATE)
public class CompanyReview extends Base{

    @Id
    @GeneratedValue
    @Column(columnDefinition = "uuid")
    UUID reviewId;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "company_id", nullable = false)
    Company company;

    @Column(nullable = false, columnDefinition = "uuid")
    UUID reviewerId;

    @Column(nullable = false)
    String title;

    @Column(columnDefinition = "TEXT")
    String comment;

    @Column(nullable = false)
    Double rating;

    @Enumerated(EnumType.STRING)
    @Column(length = 20)
    Status status = Status.ACTIVE;

    public enum Status {
        ACTIVE, INACTIVE
    }
}


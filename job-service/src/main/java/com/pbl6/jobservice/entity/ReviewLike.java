package com.pbl6.jobservice.entity;

import jakarta.persistence.*;
import lombok.*;
import lombok.experimental.FieldDefaults;

import java.time.LocalDateTime;
import java.util.UUID;

@Entity
@Table(name = "review_likes", uniqueConstraints = {
        @UniqueConstraint(columnNames = {"review_id", "user_id"})
})
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
@FieldDefaults(level = AccessLevel.PRIVATE)
public class ReviewLike {

    @Id
    @GeneratedValue
    @Column(columnDefinition = "uuid")
    UUID id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "review_id", nullable = false)
    CompanyReview companyReview;

    @Column(name = "user_id", nullable = false, columnDefinition = "uuid")
    UUID userId;

    @Column(nullable = false)
    LocalDateTime likedAt;

    @PrePersist
    public void prePersist() {
        this.likedAt = LocalDateTime.now();
    }
}
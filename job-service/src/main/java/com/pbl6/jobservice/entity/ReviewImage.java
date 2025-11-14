package com.pbl6.jobservice.entity;

import jakarta.persistence.*;
import lombok.*;
import lombok.experimental.FieldDefaults;
import java.util.UUID;

@Entity
@Table(name = "review_images")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
@FieldDefaults(level = AccessLevel.PRIVATE)
public class ReviewImage extends Base {

    @Id
    @GeneratedValue
    @Column(columnDefinition = "uuid")
    UUID id;

    @Column(nullable = false, columnDefinition = "TEXT")
    String imageUrl;

    // Quan hệ N-1: Nhiều ảnh thuộc về 1 review
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "review_id", nullable = false)
    @ToString.Exclude // Tránh vòng lặp vô hạn khi in log
    @EqualsAndHashCode.Exclude
    CompanyReview companyReview;
}
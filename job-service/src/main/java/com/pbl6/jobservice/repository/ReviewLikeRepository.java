package com.pbl6.jobservice.repository;

import com.pbl6.jobservice.entity.ReviewLike;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;
import java.util.Optional;
import java.util.Set;
import java.util.UUID;

public interface ReviewLikeRepository extends JpaRepository<ReviewLike, UUID> {
    Optional<ReviewLike> findByCompanyReview_ReviewIdAndUserId(UUID reviewId, UUID userId);

    boolean existsByCompanyReview_ReviewIdAndUserId(UUID reviewId, UUID userId);

    @Query("SELECT rl.companyReview.reviewId FROM ReviewLike rl " +
            "WHERE rl.userId = :userId AND rl.companyReview.reviewId IN :reviewIds")
    Set<UUID> findLikedReviewIdsByUserIdAndReviewIds(@Param("userId") UUID userId,
                                                     @Param("reviewIds") List<UUID> reviewIds);
}
package com.pbl6.jobservice.repository;

import com.pbl6.jobservice.entity.CompanyReview;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.UUID;

@Repository
public interface CompanyReviewRepository extends JpaRepository<CompanyReview, UUID> {

    @Modifying
    @Query("UPDATE CompanyReview r SET r.likeCount = r.likeCount + 1 WHERE r.reviewId = :id")
    int incrementLikeCount(@Param("id") UUID id);

    Page<CompanyReview> findByCompanyIdAndStatus(UUID companyId,
                                                 CompanyReview.Status status,
                                                 Pageable pageable);
}

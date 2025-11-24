package com.pbl6.jobservice.repository;


import com.pbl6.jobservice.entity.ReviewReport;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.UUID;

public interface ReviewReportRepository extends JpaRepository<ReviewReport, UUID> {
    boolean existsByCompanyReview_ReviewIdAndReporterId(UUID reviewId, UUID reporterId);
    Page<ReviewReport> findByStatus(ReviewReport.ReportStatus status, Pageable pageable);
}
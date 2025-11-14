package com.pbl6.jobservice.service;

import com.pbl6.jobservice.dto.request.ReviewRequest;
import com.pbl6.jobservice.dto.request.ReviewUpdateRequest;
import com.pbl6.jobservice.dto.response.ReviewResponse;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import java.util.UUID;

public interface CompanyReviewService {
    public ReviewResponse createReview(ReviewRequest request);
    public ReviewResponse getReviewById(UUID reviewId);
    public Page<ReviewResponse> getReviewsByCompany(UUID companyId, Pageable pageable);
    public ReviewResponse updateReview(UUID reviewId,ReviewUpdateRequest request);
    public void deleteReview(UUID reviewId);
    public ReviewResponse toggleLike(UUID reviewId);
}

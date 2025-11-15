package com.pbl6.jobservice.service.impl;

import com.pbl6.jobservice.client.FileClient;
import com.pbl6.jobservice.client.UserClient;
import com.pbl6.jobservice.dto.request.ReviewRequest;
import com.pbl6.jobservice.dto.request.ReviewUpdateRequest;
import com.pbl6.jobservice.dto.response.ReviewResponse;
import com.pbl6.jobservice.dto.response.ReviewerInfo;
import com.pbl6.jobservice.dto.response.ReviewerInfoResponse;
import com.pbl6.jobservice.entity.Company;
import com.pbl6.jobservice.entity.CompanyReview;
import com.pbl6.jobservice.entity.ReviewImage;
import com.pbl6.jobservice.entity.ReviewLike;
import com.pbl6.jobservice.exception.AppException;
import com.pbl6.jobservice.exception.ErrorCode;
import com.pbl6.jobservice.repository.CompanyRepository;
import com.pbl6.jobservice.repository.CompanyReviewRepository;
import com.pbl6.jobservice.repository.ReviewLikeRepository;
import com.pbl6.jobservice.service.CompanyReviewService;
import jakarta.transaction.Transactional;
import lombok.AccessLevel;
import lombok.RequiredArgsConstructor;
import lombok.experimental.FieldDefaults;
import lombok.extern.slf4j.Slf4j;
import org.modelmapper.ModelMapper;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;
import java.util.Set;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
@Slf4j
@RequiredArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE, makeFinal = true)
public class CompanyReviewServiceImpl implements CompanyReviewService {
    CompanyReviewRepository companyReviewRepository;
    ReviewLikeRepository reviewLikeRepository;
    ModelMapper modelMapper;
    FileClient fileClient;
    CompanyRepository companyRepository;
    UserClient userClient;

    @Override
    public ReviewResponse createReview(ReviewRequest request) {
        Company company = companyRepository.findById(request.getCompanyId())
                .orElseThrow(() -> new AppException(ErrorCode.COMPANY_NOT_FOUND));

        CompanyReview review = modelMapper.map(request, CompanyReview.class);
        review.setCompany(company);
        review.setStatus(CompanyReview.Status.ACTIVE);
        review.setLikeCount(0);
        review.setReviewerId(getCurrentUserId());

        if (request.getImages() != null && !request.getImages().isEmpty()) {
            Set<ReviewImage> reviewImages = request.getImages().stream()
                    .map(file -> {
                        String url = fileClient.uploadFile(file,"comment_image").getResult(); // Upload & lấy link
                        return ReviewImage.builder()
                                .imageUrl(url)
                                .companyReview(review)
                                .build();
                    }).collect(Collectors.toSet());
            review.setImages(reviewImages);
        }

        CompanyReview savedReview =companyReviewRepository.save(review);
        return mapToResponse(savedReview);
    }

    @Override
    public ReviewResponse getReviewById(UUID reviewId) {
        CompanyReview review = companyReviewRepository.findById(reviewId)
                .orElseThrow(() -> new AppException(ErrorCode.REVIEW_NOT_FOUND));
        return mapToResponse(review);
    }

    @Override
    public Page<ReviewResponse> getReviewsByCompany(UUID companyId, Pageable pageable) {

        Page<CompanyReview> reviewPage = companyReviewRepository.findByCompanyIdAndStatus(
                companyId,
                CompanyReview.Status.ACTIVE,
                pageable
        );

        if (reviewPage.isEmpty()) {
            return reviewPage.map(this::mapToResponse);
        }

        UUID currentUserId = getCurrentUserId();

        // ----------- Tối ưu check liked 1 lần -----------
        Set<UUID> likedReviewIds = new java.util.HashSet<>();

        if (currentUserId != null) {
            List<UUID> reviewIdsOnPage = reviewPage.getContent().stream()
                    .map(CompanyReview::getReviewId)
                    .toList();

            likedReviewIds = reviewLikeRepository
                    .findLikedReviewIdsByUserIdAndReviewIds(currentUserId, reviewIdsOnPage);
        }

        Set<UUID> finalLikedReviewIds = likedReviewIds;

        // ----------- Map sang DTO bằng mapToResponse -----------
        return reviewPage.map(review -> {
            ReviewResponse res = mapToResponse(review);

            // Ghi đè lại isLiked để không bị query DB N lần
            if (currentUserId != null) {
                res.setLiked(finalLikedReviewIds.contains(review.getReviewId()));
            } else {
                res.setLiked(false);
            }

            return res;
        });
    }


    @Transactional
    public ReviewResponse updateReview(UUID reviewId,ReviewUpdateRequest request) {
        CompanyReview review = companyReviewRepository.findById(reviewId)
                .orElseThrow(() -> new AppException(ErrorCode.REVIEW_NOT_FOUND));

        if (!review.getReviewerId().equals(getCurrentUserId())) {
            throw new AppException(ErrorCode.NOT_ALLOW_TO_UPDATE_REVIEW);
        }

        if (request.getTitle() != null) review.setTitle(request.getTitle());
        if (request.getComment() != null) review.setComment(request.getComment());
        if (request.getRating() != null) review.setRating(request.getRating());

        if (request.getNewImages() != null && !request.getNewImages().isEmpty()) {

            Set<ReviewImage> newImageEntities = request.getNewImages().stream()
                    .map(file -> {
                        String url = fileClient.uploadFile(file,"comment_image").getResult();
                        return ReviewImage.builder()
                                .imageUrl(url)
                                .companyReview(review)
                                .build();
                    })
                    .collect(Collectors.toSet());

            if (review.getImages() == null) {
                review.setImages(newImageEntities);
            } else {
                review.getImages().clear();
                review.getImages().addAll(newImageEntities);
            }
            review.setUpdatedAt(java.time.LocalDateTime.now());
        }
        return mapToResponse(companyReviewRepository.save(review));
    }

    @Override
    public void deleteReview(UUID reviewId) {
        CompanyReview review = companyReviewRepository.findById(reviewId)
                .orElseThrow(() -> new AppException(ErrorCode.REVIEW_NOT_FOUND));

        if (!review.getReviewerId().equals(getCurrentUserId())) {
            throw new RuntimeException("Unauthorized");
        }

        review.setStatus(CompanyReview.Status.INACTIVE); // Soft delete
        companyReviewRepository.save(review);
    }

    @Transactional
    public ReviewResponse toggleLike(UUID reviewId) {
        CompanyReview review = companyReviewRepository.findById(reviewId)
                .orElseThrow(() -> new AppException(ErrorCode.REVIEW_NOT_FOUND));

        Optional<ReviewLike> existingLike = reviewLikeRepository.findByCompanyReview_ReviewIdAndUserId(reviewId, getCurrentUserId());

        if (existingLike.isPresent()) {
            reviewLikeRepository.delete(existingLike.get());

            review.setLikeCount(Math.max(0, review.getLikeCount() - 1));
        } else {
            ReviewLike newLike = ReviewLike.builder()
                    .companyReview(review)
                    .userId(getCurrentUserId())
                    .build();
            reviewLikeRepository.save(newLike);

            review.setLikeCount(review.getLikeCount() + 1);
        }

        CompanyReview savedReview = companyReviewRepository.save(review);

        ReviewResponse response = mapToResponse(savedReview);

        response.setLiked(existingLike.isEmpty());

        return response;
    }

    private UUID getCurrentUserId() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();

        if (authentication == null || !authentication.isAuthenticated()) {
            return null;
        }

        Object principal = authentication.getPrincipal();

        // Nếu không phải JWT -> nghĩa là user chưa đăng nhập -> trả null
        if (!(principal instanceof Jwt jwt)) {
            return null;
        }

        String id = jwt.getClaimAsString("userId");
        return id != null ? UUID.fromString(id) : null;
    }

    private ReviewResponse mapToResponse(CompanyReview entity) {
        ReviewResponse response = modelMapper.map(entity, ReviewResponse.class);
        ReviewerInfoResponse reviewInfoResponse = userClient.getReviewerById(String.valueOf(entity.getReviewerId())).getResult();
        ReviewerInfo reviewerInfo =ReviewerInfo.builder()
                .reviewerId(entity.getReviewerId())
                .reviewerName(reviewInfoResponse.getFullName())
                .reviewerAvatar(reviewInfoResponse.getAvatarUrl())
                .build();
        List<String> urls = entity.getImages() == null ? List.of() :
                entity.getImages().stream()
                        .map(ReviewImage::getImageUrl)
                        .collect(Collectors.toList());
        response.setImageUrls(urls);
        response.setCompanyId(entity.getCompany().getId());
        getCurrentUserId();
        boolean isLiked = reviewLikeRepository.existsByCompanyReview_ReviewIdAndUserId(entity.getReviewId(), getCurrentUserId());
        response.setLiked(isLiked);
        response.setReviewerInfo(reviewerInfo);
        response.setCreatedAt(entity.getCreatedAt());
        response.setUpdatedAt(entity.getUpdatedAt());
        return response;
    }
}

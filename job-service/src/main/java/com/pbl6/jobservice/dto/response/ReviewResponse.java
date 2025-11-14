package com.pbl6.jobservice.dto.response;

import lombok.*;
import lombok.experimental.FieldDefaults;

import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE)
public class ReviewResponse {
    UUID reviewId;
    UUID companyId;
    String title;
    String comment;
    Double rating;
    long likeCount;
    String status;
    boolean isLiked;
    List<String> imageUrls;
    ReviewerInfo reviewerInfo;
    LocalDateTime createdAt;
    LocalDateTime updatedAt;
}

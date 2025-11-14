package com.pbl6.jobservice.dto.response;

import lombok.*;
import lombok.experimental.FieldDefaults;

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
    UUID reviewerId;
    String title;
    String comment;
    Double rating;
    long likeCount;
    String status;
    boolean isLiked;
    List<String> imageUrls;
}

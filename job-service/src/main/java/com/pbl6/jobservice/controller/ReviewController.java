package com.pbl6.jobservice.controller;

import com.pbl6.jobservice.dto.request.ReportRequest;
import com.pbl6.jobservice.dto.request.ReportStatusRequest;
import com.pbl6.jobservice.dto.request.ReviewRequest;
import com.pbl6.jobservice.dto.request.ReviewUpdateRequest;
import com.pbl6.jobservice.dto.response.APIResponse;
import com.pbl6.jobservice.dto.response.ReasonResponse;
import com.pbl6.jobservice.dto.response.ReportResponse;
import com.pbl6.jobservice.dto.response.ReviewResponse;
import com.pbl6.jobservice.entity.ReviewReport;
import com.pbl6.jobservice.service.CompanyReviewService;
import com.pbl6.jobservice.service.ReviewReportService;
import jakarta.validation.Valid;
import lombok.AccessLevel;
import lombok.experimental.FieldDefaults;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/reviews")
@FieldDefaults(level= AccessLevel.PRIVATE,makeFinal=true)
public class ReviewController {
    CompanyReviewService companyReviewService;
    ReviewReportService reviewReportService;
    public ReviewController(CompanyReviewService companyReviewService, ReviewReportService reviewReportService) {
        this.companyReviewService = companyReviewService;
        this.reviewReportService = reviewReportService;
    }
    @PostMapping(consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public APIResponse<ReviewResponse> createReview(
            @ModelAttribute ReviewRequest request){

        return APIResponse.<ReviewResponse>builder()
                .code(200)
                .result(companyReviewService.createReview(request))
                .build();
    }

    @PutMapping(value = "/{reviewId}", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public APIResponse<ReviewResponse> updateReview(
            @PathVariable UUID reviewId,
            @ModelAttribute ReviewUpdateRequest request) {
        return APIResponse.<ReviewResponse>builder()
                .code(200)
                .result(companyReviewService.updateReview(reviewId,request))
                .build();
    }

    @DeleteMapping("/{reviewId}")
    public APIResponse<String> deleteReview(@PathVariable UUID reviewId) {
        companyReviewService.deleteReview(reviewId);
        return APIResponse.<String>builder()
                .code(200)
                .result("Deleted successfully")
                .build();
    }

    @GetMapping("/{reviewId}")
    public APIResponse<ReviewResponse> getReview(@PathVariable UUID reviewId) {
        return APIResponse.<ReviewResponse>builder()
                .code(200)
                .result(companyReviewService.getReviewById(reviewId))
                .build();
    }
    @GetMapping("/company/{companyId}")
    public APIResponse<Page<ReviewResponse>> getReviews(
            @PathVariable UUID companyId,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size) {

        Pageable pageable = PageRequest.of(page, size, Sort.by("createdAt").descending());
        return APIResponse.<Page<ReviewResponse>>builder()
                .code(200)
                .result(companyReviewService.getReviewsByCompany(companyId,pageable))
                .build();
    }
    @PostMapping("/{reviewId}/toggle-like")
    public APIResponse<ReviewResponse> toggleLike(@PathVariable UUID reviewId) {

        return APIResponse.<ReviewResponse>builder()
                .code(200)
                .result(companyReviewService.toggleLike(reviewId))
                .build();
    }
    @PostMapping("/reports/{reviewId}")
    public APIResponse<ReportResponse> createReport(@PathVariable UUID reviewId, @RequestBody ReportRequest request){
        return APIResponse.<ReportResponse>builder()
                .code(200)
                .result(reviewReportService.createReport(reviewId,request))
                .build();
    }
    @GetMapping("/report-reasons")
    public APIResponse<List<ReasonResponse>> getAllReasons(){
        return APIResponse.<List<ReasonResponse>>builder()
                .code(200)
                .result(reviewReportService.getAllReportReasons())
                .build();
    }
    @GetMapping("/reports")
    public APIResponse<Page<ReportResponse>> getAllReports(@RequestParam(required = false) ReviewReport.ReportStatus status,
                                                           @RequestParam(defaultValue = "0") int page,
                                                           @RequestParam(defaultValue = "10") int size){
        Pageable pageable = PageRequest.of(page, size, Sort.by("createdAt").descending());
        return APIResponse.<Page<ReportResponse>>builder()
                .code(200)
                .result(reviewReportService.getAllReports(status, pageable))
                .build();
    }

    @PutMapping("/reports/{reportId}/process")
    public APIResponse<String> processReport(@PathVariable UUID reportId,
                                             @RequestBody @Valid ReportStatusRequest request){
        reviewReportService.processReport(reportId,request);
        return APIResponse.<String>builder()
                .code(200)
                .result("Process successfully")
                .build();
    }
}

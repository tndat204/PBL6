package com.pbl6.jobservice.service.impl;

import com.pbl6.jobservice.dto.request.ReportRequest;
import com.pbl6.jobservice.dto.request.ReportStatusRequest;
import com.pbl6.jobservice.dto.response.ReasonResponse;
import com.pbl6.jobservice.dto.response.ReportResponse;
import com.pbl6.jobservice.dto.response.ReviewResponse;
import com.pbl6.jobservice.entity.CompanyReview;
import com.pbl6.jobservice.entity.ReviewReport;
import com.pbl6.jobservice.exception.AppException;
import com.pbl6.jobservice.exception.ErrorCode;
import com.pbl6.jobservice.repository.CompanyReviewRepository;
import com.pbl6.jobservice.repository.ReviewReportRepository;
import com.pbl6.jobservice.service.ReviewReportService;
import jakarta.transaction.Transactional;
import lombok.AccessLevel;
import lombok.RequiredArgsConstructor;
import lombok.experimental.FieldDefaults;
import lombok.extern.slf4j.Slf4j;
import org.modelmapper.ModelMapper;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

@Service
@Slf4j
@RequiredArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE, makeFinal = true)
public class ReviewReportServiceImpl implements ReviewReportService {
    ReviewReportRepository reviewReportRepository;
    ModelMapper modelMapper;
    CompanyReviewRepository companyReviewRepository;

    @Transactional
    public ReportResponse createReport(UUID reviewId, ReportRequest request) {
        CompanyReview review = companyReviewRepository.findById(reviewId)
                .orElseThrow(() -> new AppException(ErrorCode.REVIEW_NOT_FOUND));

        UUID reporterId=getCurrentUserId();
        if (review.getReviewerId().equals(reporterId)) {
            throw new AppException(ErrorCode.REVIEW_SELF_REPORT_NOT_ALLOWED);
        }
        if (reviewReportRepository.existsByCompanyReview_ReviewIdAndReporterId(reviewId, reporterId)) {
            throw new AppException(ErrorCode.REVIEW_ALREADY_REPORTED);
        }
        if (request.getReason() == ReviewReport.ReportReason.OTHER &&
                (request.getDescription() == null || request.getDescription().trim().isEmpty())) {
            throw new AppException(ErrorCode.REVIEW_REPORT_OTHER_DETAIL_REQUIRED);
        }
        ReviewReport report = ReviewReport.builder()
                .companyReview(review)
                .reporterId(reporterId)
                .reason(request.getReason())
                .description(request.getDescription()) // Có thể null
                .status(ReviewReport.ReportStatus.PENDING)
                .build();

        ReviewReport saveReport=reviewReportRepository.save(report);

        return ReportResponse.builder()
                .id(saveReport.getId())
                .reviewId(reviewId)
                .reporterId(reporterId)
                .reason(saveReport.getReason())
                .description(saveReport.getDescription())
                .status(saveReport.getStatus())
                .build();
    }


    public List<ReasonResponse> getAllReportReasons() {
        List<ReasonResponse> reasons = new ArrayList<>();

        for (ReviewReport.ReportReason reason : ReviewReport.ReportReason.values()) {
            reasons.add(mapEnumToResponse(reason));
        }
        return reasons;
    }

    @PreAuthorize("hasRole('ADMIN')")
    public void processReport(UUID reportId, ReportStatusRequest request) {
        ReviewReport report = reviewReportRepository.findById(reportId)
                .orElseThrow(() -> new AppException(ErrorCode.REPORT_NOT_FOUND));

        if (request.getStatus() == ReviewReport.ReportStatus.PENDING) {
            throw new AppException(ErrorCode.REPORT_STATUS_REVERT_NOT_ALLOWED);
        }

        report.setStatus(request.getStatus());

        CompanyReview review = report.getCompanyReview();

        if (request.getStatus() == ReviewReport.ReportStatus.APPROVED) {
            review.setStatus(CompanyReview.Status.INACTIVE);
            companyReviewRepository.save(review);
        } else if (request.getStatus() == ReviewReport.ReportStatus.REJECTED) {
            review.setStatus(CompanyReview.Status.ACTIVE);
            companyReviewRepository.save(review);
        }

        reviewReportRepository.save(report);
    }


    private ReasonResponse mapEnumToResponse(ReviewReport.ReportReason reason) {
        String label;
        String desc;

        switch (reason) {
            case SPAM:
                label = "Spam hoặc quảng cáo";
                desc = "Nội dung rác, quảng cáo bán hàng, link không liên quan.";
                break;
            case SCAM_OR_FRAUD:
                label = "Lừa đảo hoặc gian lận";
                desc = "Quảng cáo đa cấp, yêu cầu nộp tiền, hoặc lừa đảo.";
                break;
            case INAPPROPRIATE_CONTENT:
                label = "Nội dung không phù hợp";
                desc = "Hình ảnh/ngôn từ khiêu dâm, bạo lực hoặc phản cảm.";
                break;
            case HATE_SPEECH:
                label = "Ngôn từ thù ghét";
                desc = "Phân biệt chủng tộc, tôn giáo, giới tính, vùng miền.";
                break;
            case HARASSMENT:
                label = "Quấy rối hoặc công kích";
                desc = "Tấn công, xúc phạm cá nhân cụ thể (đồng nghiệp, HR, sếp).";
                break;
            case FAKE_INFORMATION:
                label = "Thông tin sai sự thật";
                desc = "Bịa đặt thông tin sai lệch về công ty hoặc chính sách.";
                break;
            case CONFLICT_OF_INTEREST:
                label = "Xung đột lợi ích";
                desc = "HR tự khen công ty (Seeding) hoặc đối thủ dìm hàng.";
                break;
            case PRIVACY_VIOLATION:
                label = "Xâm phạm quyền riêng tư";
                desc = "Công khai SĐT, địa chỉ, Facebook cá nhân của người khác.";
                break;
            case SHARING_CONFIDENTIAL_INFO:
                label = "Lộ bí mật công ty";
                desc = "Tiết lộ source code, tài liệu nội bộ, bảng lương bảo mật.";
                break;
            case IRRELEVANT_CONTENT:
                label = "Không liên quan";
                desc = "Nội dung không liên quan đến trải nghiệm làm việc.";
                break;
            case OTHER:
                label = "Lý do khác";
                desc = "Vui lòng nhập mô tả chi tiết.";
                break;
            default:
                label = "Lý do báo cáo";
                desc = "";
        }

        return ReasonResponse.builder()
                .key(reason)
                .label(label)
                .description(desc)
                .build();
    }
    @PreAuthorize("hasRole('ADMIN')")
    public Page<ReportResponse> getAllReports(ReviewReport.ReportStatus status, Pageable pageable) {
        Page<ReviewReport> reportPage;

        if (status != null) {
            reportPage = reviewReportRepository.findByStatus(status, pageable);
        } else {
            reportPage = reviewReportRepository.findAll(pageable);
        }
        return reportPage.map(report -> {
            ReportResponse response = modelMapper.map(report, ReportResponse.class);

            if (report.getCompanyReview() != null) {
                response.setReviewId(report.getCompanyReview().getReviewId());
            }
            if (report.getDescription() != null && !report.getDescription().isEmpty()) {
                response.setDescription(report.getDescription());
            } else {
                response.setDescription(getDefaultDescription(report.getReason()));
            }
            return response;
        });
    }

    private String getDefaultDescription(ReviewReport.ReportReason reason) {
        if (reason == null) return "";

        switch (reason) {
            case SPAM:
                return "Spam, nội dung rác, quảng cáo bán hàng hoặc link không liên quan.";

            case SCAM_OR_FRAUD:
                return "Lừa đảo, đa cấp biến tướng, dụ dỗ đầu tư hoặc chứa link độc hại.";

            case INAPPROPRIATE_CONTENT:
                return "Nội dung khiêu dâm, bạo lực, hình ảnh hoặc ngôn từ phản cảm.";

            case HATE_SPEECH:
                return "Ngôn từ thù ghét, phân biệt chủng tộc, tôn giáo, giới tính hoặc vùng miền.";

            case HARASSMENT:
                return "Quấy rối, đe dọa, bắt nạt hoặc công kích một cá nhân cụ thể.";

            case FAKE_INFORMATION:
                return "Thông tin sai sự thật, bịa đặt vô căn cứ về công ty hoặc chính sách.";

            case CONFLICT_OF_INTEREST:
                return "Xung đột lợi ích (Nhân viên tự khen công ty hoặc đối thủ cạnh tranh cố tình dìm hàng).";

            case PRIVACY_VIOLATION:
                return "Xâm phạm quyền riêng tư (Công khai SĐT, địa chỉ nhà, Facebook cá nhân của người khác).";

            case SHARING_CONFIDENTIAL_INFO:
                return "Tiết lộ bí mật công ty (Lộ source code, tài liệu nội bộ, quy trình kinh doanh, mức lương bảo mật).";

            case IRRELEVANT_CONTENT:
                return "Nội dung không liên quan đến trải nghiệm làm việc hoặc phỏng vấn.";

            case OTHER:
                return "Lý do khác (Người dùng không nhập chi tiết).";

            default:
                return "Vi phạm tiêu chuẩn cộng đồng.";
        }
    }
    private UUID getCurrentUserId() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        if (!(authentication.getPrincipal() instanceof Jwt jwt)) {
            throw new RuntimeException("Cannot get userId from token");
        }
        return UUID.fromString(jwt.getClaimAsString("userId"));
    }
}

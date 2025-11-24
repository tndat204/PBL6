package com.pbl6.jobservice.service;

import com.pbl6.jobservice.dto.request.ReportRequest;
import com.pbl6.jobservice.dto.request.ReportStatusRequest;
import com.pbl6.jobservice.dto.response.ReasonResponse;
import com.pbl6.jobservice.dto.response.ReportResponse;
import com.pbl6.jobservice.entity.ReviewReport;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;

import java.util.List;
import java.util.UUID;

public interface ReviewReportService {
    public ReportResponse createReport(UUID reviewId, ReportRequest request);
    public Page<ReportResponse> getAllReports(ReviewReport.ReportStatus status, Pageable pageable);
    public List<ReasonResponse> getAllReportReasons();
    public void processReport(UUID reportId, ReportStatusRequest request);
}

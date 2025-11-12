package com.pbl6.jobservice.service;

import com.pbl6.jobservice.dto.request.ApplicationRequest;
import com.pbl6.jobservice.dto.response.ApplicationResponse;
import com.pbl6.jobservice.entity.Application;

import java.util.List;
import java.util.UUID;

public interface ApplicationService {
    ApplicationResponse createApplication(ApplicationRequest request);
    List<ApplicationResponse> getApplicationsByJobId(String jobId);
    ApplicationResponse getApplicationById(String id);
    ApplicationResponse updateStatus(UUID applicationId, String status);
    List<ApplicationResponse> getMyApplications();
}

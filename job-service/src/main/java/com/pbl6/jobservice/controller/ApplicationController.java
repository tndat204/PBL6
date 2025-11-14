package com.pbl6.jobservice.controller;

import com.pbl6.jobservice.dto.request.ApplicationRequest;
import com.pbl6.jobservice.dto.response.APIResponse;
import com.pbl6.jobservice.dto.response.ApplicationResponse;
import com.pbl6.jobservice.service.ApplicationService;
import lombok.AccessLevel;
import lombok.experimental.FieldDefaults;
import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/applications")
@FieldDefaults(level= AccessLevel.PRIVATE,makeFinal=true)
public class ApplicationController {
    ApplicationService applicationService;
    public ApplicationController(final ApplicationService applicationService) {
        this.applicationService = applicationService;
    }

    @PostMapping(consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public APIResponse<ApplicationResponse> createApplication(@ModelAttribute ApplicationRequest applicationRequest) {
        return APIResponse.<ApplicationResponse>builder()
                .code(200)
                .result(applicationService.createApplication(applicationRequest))
                .build();
    }
    @GetMapping("/job/{jobId}")
    public APIResponse<List<ApplicationResponse>> getApplicationsByJobId(@PathVariable String jobId) {
        return APIResponse.<List<ApplicationResponse>>builder()
                .code(200)
                .result(applicationService.getApplicationsByJobId(jobId))
                .build();
    }
    @GetMapping("/{id}")
    public APIResponse<ApplicationResponse> getApplicationId(@PathVariable String id) {
        return APIResponse.<ApplicationResponse>builder()
                .code(200)
                .result(applicationService.getApplicationById(id))
                .build();
    }
    @PutMapping("/{id}/status")
    public APIResponse<ApplicationResponse> updateApplicationStatus(@PathVariable String id, @RequestParam String newStatus) {
        return APIResponse.<ApplicationResponse>builder()
                .code(200)
                .result(applicationService.updateStatus(UUID.fromString(id),newStatus))
                .build();
    }
    @GetMapping("/me")
    public APIResponse<List<ApplicationResponse>> getMyApplications() {
        return APIResponse.<List<ApplicationResponse>>builder()
                .code(200)
                .result(applicationService.getMyApplications())
                .build();
    }
}

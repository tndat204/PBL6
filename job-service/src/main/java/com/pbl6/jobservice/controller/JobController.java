package com.pbl6.jobservice.controller;

import com.pbl6.jobservice.dto.request.CreateJobRequest;
import com.pbl6.jobservice.dto.request.UpdateJobRequest;
import com.pbl6.jobservice.dto.response.APIResponse;
import com.pbl6.jobservice.dto.response.JobResponse;
import com.pbl6.jobservice.entity.Job;
import com.pbl6.jobservice.service.JobService;
import lombok.AccessLevel;
import lombok.experimental.FieldDefaults;
import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/jobs")
@FieldDefaults(level= AccessLevel.PRIVATE,makeFinal=true)
public class JobController {

    JobService jobService;

    public JobController(JobService jobService) {
        this.jobService = jobService;
    }

    @PostMapping(consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public APIResponse<JobResponse> createJob(@ModelAttribute CreateJobRequest request){
        return APIResponse.<JobResponse>builder()
                .code(200)
                .result(jobService.createJob(request))
                .build();
    }
    @GetMapping("/{id}")
    public APIResponse<JobResponse> getJob(@PathVariable String id){
        return APIResponse.<JobResponse>builder()
                .code(200)
                .result(jobService.getJobById(id))
                .build();
    }
    @GetMapping
    public APIResponse<List<JobResponse>> getAllJobs( @RequestParam(value = "companyId", required = false) String companyId,
                                                      @RequestParam(value = "status", required = false) Job.JobStatus status){
        return APIResponse.<List<JobResponse>>builder()
                .code(200)
                .result(jobService.getAllJobs(companyId,status))
                .build();
    }
    @PutMapping("/{id}")
    public APIResponse<JobResponse> updateJob(
            @PathVariable String id,
            @RequestBody UpdateJobRequest request) {
        return APIResponse.<JobResponse>builder()
                .code(200)
                .result(jobService.updateJob(id, request))
                .build();
    }
    @DeleteMapping("/{id}")
    public APIResponse<String> deleteJob(@PathVariable String id){
        jobService.deleteJobById(id);
        return APIResponse.<String>builder()
                .code(200)
                .result("Job deleted successfully")
                .build();
    }
}

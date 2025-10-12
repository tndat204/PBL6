package com.pbl6.jobservice.service;

import com.pbl6.jobservice.dto.request.CreateJobRequest;
import com.pbl6.jobservice.dto.request.UpdateJobRequest;
import com.pbl6.jobservice.dto.response.JobResponse;
import com.pbl6.jobservice.entity.Job;

import java.util.List;

public interface JobService {
    public JobResponse createJob(CreateJobRequest request);
    public JobResponse getJobById(String id);
    public List<JobResponse> getAllJobs(String companyId, Job.JobStatus jobStatus);
    public JobResponse updateJob(String jobId,UpdateJobRequest request);
    public void  deleteJobById(String id);
}

package com.pbl6.jobservice.service.impl;

import com.pbl6.jobservice.dto.request.CreateJobRequest;
import com.pbl6.jobservice.dto.request.UpdateJobRequest;
import com.pbl6.jobservice.dto.response.JobResponse;
import com.pbl6.jobservice.entity.*;
import com.pbl6.jobservice.exception.AppException;
import com.pbl6.jobservice.exception.ErrorCode;
import com.pbl6.jobservice.repository.*;
import com.pbl6.jobservice.service.JobService;
import jakarta.transaction.Transactional;
import lombok.AccessLevel;
import lombok.RequiredArgsConstructor;
import lombok.experimental.FieldDefaults;
import lombok.extern.slf4j.Slf4j;
import org.modelmapper.Conditions;
import org.modelmapper.ModelMapper;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.stereotype.Service;

import java.util.*;
import java.util.stream.Collectors;

@Service
@Slf4j
@RequiredArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE, makeFinal = true)
public class JobServiceImpl implements JobService {
    JobRepository jobRepository;
    JobCategoryRepository jobCategoryRepository;
    JobSkillRepository jobSkillRepository;
    CompanyRepository companyRepository;
    CompanyUserRepository companyUserRepository;
    ModelMapper modelMapper;

    @Transactional
    public JobResponse createJob(CreateJobRequest request) {
        Company company = companyRepository.findById(request.getCompanyId())
                .orElseThrow(() -> new AppException(ErrorCode.COMPANY_NOT_FOUND));
        if(!company.isActive()) {
            throw new AppException(ErrorCode.COMPANY_NOT_ACTIVE);
        }

        UUID postedBy=getCurrentUserId();
        boolean allowed = companyUserRepository.existsByCompanyIdAndUserIdAndStatusInAndRoleIn(
                company.getId(),
                postedBy,
                List.of(CompanyUser.Status.ACTIVE),
                List.of(CompanyUser.Role.RECRUITER)
        );
        if (!allowed) {
            throw new AppException(ErrorCode.NOT_ALLOW_TO_POST);
        }

        Job job = Job.builder()
                .company(company)
                .postedBy(postedBy)
                .title(request.getTitle())
                .description(request.getDescription())
                .status(request.getStatus() != null ? request.getStatus() : Job.JobStatus.ACTIVE)
                .location(request.getLocation())
                .salaryMin(request.getSalaryMin())
                .salaryMax(request.getSalaryMax())
                .jobType(request.getJobType())
                .experienceLevel(request.getExperienceLevel())
                .requiredYearsOfExpMax(request.getRequiredYearsOfExpMax())
                .requiredYearsOfExpMin(request.getRequiredYearsOfExpMin())
                .expiryDate(request.getExpiryDate())
                .build();

        job = jobRepository.save(job);

        if (request.getCategoryIds() != null && !request.getCategoryIds().isEmpty()) {
            for (UUID categoryId : request.getCategoryIds()) {
                JobCategory jobCategory = JobCategory.builder()
                        .job(job)
                        .categoryId(categoryId)
                        .build();
                job.getCategories().add(jobCategory);
            }
        }

        if (request.getSkillIds() != null && !request.getSkillIds().isEmpty()) {
            for (UUID skillId : request.getSkillIds()) {
                JobSkill jobSkill = JobSkill.builder()
                        .job(job)
                        .skillId(skillId)
                        .build();
                job.getSkills().add(jobSkill);
            }
        }

        JobResponse response = modelMapper.map(job, JobResponse.class);

        if (job.getCategories() != null) {
            Set<UUID> categoryIds = job.getCategories().stream()
                    .map(JobCategory::getCategoryId)
                    .collect(Collectors.toSet());
            response.setCategoryIds(categoryIds);
        }

        if (job.getSkills() != null) {
            Set<UUID> skillIds = job.getSkills().stream()
                    .map(JobSkill::getSkillId)
                    .collect(Collectors.toSet());
            response.setSkillIds(skillIds);
        }

        response.setCompanyId(String.valueOf(job.getCompany().getId()));
        return response;
    }

    @Override
    public JobResponse getJobById(String id) {
        Job job = jobRepository.findById(UUID.fromString(id))
                .orElseThrow(() -> new AppException(ErrorCode.JOB_NOT_FOUND));

        JobResponse response = modelMapper.map(job, JobResponse.class);
        response.setCategoryIds(job.getCategories().stream()
                .map(JobCategory::getCategoryId)
                .collect(Collectors.toSet()));
        response.setSkillIds(job.getSkills().stream()
                .map(JobSkill::getSkillId)
                .collect(Collectors.toSet()));

        return response;
    }

    @Override
    public List<JobResponse> getAllJobs(String companyId, Job.JobStatus jobStatus) {
        List<Job> jobs = jobRepository.findAll();

        if (companyId != null) {
            jobs = jobs.stream()
                    .filter(j -> j.getCompany().getId().equals(UUID.fromString(companyId)))
                    .collect(Collectors.toList());
        }
        if (jobStatus != null) {
            jobs = jobs.stream()
                    .filter(j -> j.getStatus() == jobStatus)
                    .collect(Collectors.toList());
        }

        return jobs.stream().map(job -> {
            JobResponse response = modelMapper.map(job, JobResponse.class);
            response.setCategoryIds(job.getCategories().stream()
                    .map(JobCategory::getCategoryId)
                    .collect(Collectors.toSet()));
            response.setSkillIds(job.getSkills().stream()
                    .map(JobSkill::getSkillId)
                    .collect(Collectors.toSet()));
            return response;
        }).collect(Collectors.toList());
    }

    @Transactional
    public JobResponse updateJob(String jobId, UpdateJobRequest request) {
        UUID userId=getCurrentUserId();

        // Lấy job
        Job job = jobRepository.findById(UUID.fromString(jobId))
                .orElseThrow(() -> new AppException(ErrorCode.JOB_NOT_FOUND));

        boolean allowed = companyUserRepository.existsByCompanyIdAndUserIdAndStatusInAndRoleIn(
                job.getCompany().getId(),
                userId,
                List.of(CompanyUser.Status.ACTIVE),
                List.of(CompanyUser.Role.RECRUITER)
        );

        if (!allowed) {
            throw new AppException(ErrorCode.NOT_ALLOW_TO_UPDATE);
        }

        // Cấu hình ModelMapper skip null
        ModelMapper mapper = new ModelMapper();
        mapper.getConfiguration().setPropertyCondition(Conditions.isNotNull());

        // Map request -> entity
        mapper.map(request, job);

        // Nếu update category

        if (request.getCategoryIds() != null) {
            job.getCategories().clear();
            request.getCategoryIds().forEach(catId -> {
                JobCategory jc = JobCategory.builder()
                        .job(job)
                        .categoryId(catId)
                        .build();
                job.getCategories().add(jc);
            });
        }


        // Nếu update skill
        if (request.getSkillIds() != null) {
            job.getSkills().clear();
            request.getSkillIds().forEach(skillId -> {
                JobSkill js = JobSkill.builder()
                        .job(job)
                        .skillId(skillId)
                        .build();
                job.getSkills().add(js);
            });
        }

        // Lưu job
        Job updatedJob = jobRepository.save(job);

        // Map entity -> response
        JobResponse response = mapper.map(updatedJob, JobResponse.class);
        response.setCategoryIds(updatedJob.getCategories().stream()
                .map(JobCategory::getCategoryId)
                .collect(Collectors.toSet()));
        response.setSkillIds(updatedJob.getSkills().stream()
                .map(JobSkill::getSkillId)
                .collect(Collectors.toSet()));

        return response;
    }

    @Override
    public void deleteJobById(String id) {
        UUID userId=getCurrentUserId();

        Job job = jobRepository.findById(UUID.fromString(id))
                .orElseThrow(() -> new AppException(ErrorCode.JOB_NOT_FOUND));

        boolean allowed = companyUserRepository.existsByCompanyIdAndUserIdAndStatusInAndRoleIn(
                job.getCompany().getId(),
                userId,
                List.of(CompanyUser.Status.ACTIVE),
                List.of(CompanyUser.Role.RECRUITER)
        );

        if (!allowed) {
            throw new AppException(ErrorCode.NOT_ALLOW_TO_DELETE);
        }

        jobCategoryRepository.deleteAll(job.getCategories());
        jobSkillRepository.deleteAll(job.getSkills());

        jobRepository.delete(job);
    }
    private UUID getCurrentUserId() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        if (!(authentication.getPrincipal() instanceof Jwt jwt)) {
            throw new RuntimeException("Cannot get userId from token");
        }
        return UUID.fromString(jwt.getClaimAsString("userId"));
    }
}

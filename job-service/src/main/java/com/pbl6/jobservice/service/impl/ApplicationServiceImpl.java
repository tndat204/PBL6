package com.pbl6.jobservice.service.impl;

import com.pbl6.event.dto.ApplicationStatusChangedEvent;
import com.pbl6.event.dto.ApplicationSubmittedEvent;
import com.pbl6.jobservice.client.ProfileClient;
import com.pbl6.jobservice.client.UserClient;
import com.pbl6.jobservice.dto.request.ApplicationRequest;
import com.pbl6.jobservice.dto.response.ApplicantInfo;
import com.pbl6.jobservice.dto.response.ApplicationResponse;
import com.pbl6.jobservice.dto.response.UserResponse;
import com.pbl6.jobservice.entity.Application;
import com.pbl6.jobservice.entity.Company;
import com.pbl6.jobservice.entity.CompanyUser;
import com.pbl6.jobservice.entity.Job;
import com.pbl6.jobservice.exception.AppException;
import com.pbl6.jobservice.exception.ErrorCode;
import com.pbl6.jobservice.repository.ApplicationRepository;
import com.pbl6.jobservice.repository.CompanyRepository;
import com.pbl6.jobservice.repository.CompanyUserRepository;
import com.pbl6.jobservice.repository.JobRepository;
import com.pbl6.jobservice.service.ApplicationService;
import lombok.AccessLevel;
import lombok.RequiredArgsConstructor;
import lombok.experimental.FieldDefaults;
import lombok.extern.slf4j.Slf4j;
import org.modelmapper.ModelMapper;
import org.springframework.kafka.core.KafkaTemplate;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
@Slf4j
@RequiredArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE, makeFinal = true)
public class ApplicationServiceImpl implements ApplicationService {
    ApplicationRepository applicationRepository;
    CompanyUserRepository companyUserRepository;
    CompanyRepository companyRepository;
    ModelMapper modelMapper;
    JobRepository jobRepository;
    ProfileClient profileClient;
    UserClient userClient;
    KafkaTemplate<String, Object> kafkaTemplate;
    static String APP_SUBMITTED_TOPIC = "application_submitted_topic";
    static String APP_STATUS_TOPIC = "application_status_topic";
    @Override
    public ApplicationResponse createApplication(ApplicationRequest request) {
        Job job = jobRepository.findById(request.getJobId())
                .orElseThrow(() -> new AppException(ErrorCode.JOB_NOT_FOUND));
        Application application = modelMapper.map(request, Application.class);
        application.setJob(job);
        application.setAppliedDate(LocalDateTime.now());
        application.setApplicantId(getCurrentUserId());
        application.setStatus(Application.Status.SUBMITTED);
        if(request.getCvUrl()!=null) {
            application.setCvFileUrl(request.getCvUrl());
        }
        else{
            application.setCvFileUrl(profileClient.getCv().getResult());
        }
        Application savedApplication = applicationRepository.save(application);
        ApplicationSubmittedEvent event = new ApplicationSubmittedEvent(
                savedApplication.getApplicationId().toString(),
                savedApplication.getJob().getId().toString()
        );

        // 3. Bắn event "Nộp CV mới"
        kafkaTemplate.send(APP_SUBMITTED_TOPIC, savedApplication.getApplicationId().toString(), event);
        ApplicationResponse response = modelMapper.map(savedApplication, ApplicationResponse.class);
        response.setApplicantInfo(getMyInfo());
        return response;
    }

    @Override
    public List<ApplicationResponse> getApplicationsByJobId(String jobId) {
        Company company=jobRepository.findCompanyByJobId(UUID.fromString(jobId));
        boolean allowed = companyUserRepository.existsByCompanyIdAndUserIdAndStatusInAndRoleIn(
                company.getId(),
                getCurrentUserId(),
                List.of(CompanyUser.Status.ACTIVE),
                List.of(CompanyUser.Role.RECRUITER)
        );
        if(!allowed) {
            throw new AppException(ErrorCode.USER_NOT_ASSOCIATED_WITH_COMPANY);
        }
        List<Application> applications = applicationRepository.findByJobId(UUID.fromString(jobId));

        return applications.stream()
                .map(application -> {
                    ApplicationResponse response = modelMapper.map(application, ApplicationResponse.class);
                    response.setApplicantInfo(getApplicantInfo(application.getApplicantId()));
                    return response;
                })
                .collect(Collectors.toList());
    }

    @Override
    public ApplicationResponse getApplicationById(String id) {
        Application application = applicationRepository.findById(UUID.fromString(id))
                .orElseThrow(() -> new AppException(ErrorCode.APPLICATION_NOT_FOUND));
        Company company = application.getJob().getCompany();
        boolean allowed = companyUserRepository.existsByCompanyIdAndUserIdAndStatusInAndRoleIn(
                company.getId(),
                getCurrentUserId(),
                List.of(CompanyUser.Status.ACTIVE),
                List.of(CompanyUser.Role.RECRUITER)
        );
        if(!allowed) {
            throw new AppException(ErrorCode.USER_NOT_ASSOCIATED_WITH_COMPANY);
        }
        ApplicationResponse response = modelMapper.map(application, ApplicationResponse.class);
        response.setApplicantInfo(getApplicantInfo(application.getApplicantId()));
        return response;
    }

    @Override
    public ApplicationResponse updateStatus(UUID applicationId, String newStatus) {
        UUID recruiter=getCurrentUserId();
        Optional<Company> optionalCompany=applicationRepository.findCompanyByApplicationId(applicationId);
        Company company=optionalCompany.orElseThrow(() -> new AppException(ErrorCode.COMPANY_NOT_FOUND));
        boolean allowed = companyUserRepository.existsByCompanyIdAndUserIdAndStatusInAndRoleIn(
                company.getId(),
                recruiter,
                List.of(CompanyUser.Status.ACTIVE),
                List.of(CompanyUser.Role.RECRUITER)
        );
        if(!allowed) {
            throw new AppException(ErrorCode.NOT_ALLOW_TO_UPDATE);
        }
        Application application = applicationRepository.findById(applicationId)
                .orElseThrow(() -> new AppException(ErrorCode.APPLICATION_NOT_FOUND));

        Application.Status status = Application.Status.valueOf(newStatus.toUpperCase());
        application.setStatus(status);

        Application updatedApplication = applicationRepository.save(application);
        ApplicationStatusChangedEvent event = new ApplicationStatusChangedEvent(
                updatedApplication.getApplicationId().toString(),
                updatedApplication.getStatus().toString() // Gửi tên của Enum (ví dụ: "HIRED")
        );

        // 3. Bắn event "Thay đổi trạng thái"
        kafkaTemplate.send(APP_STATUS_TOPIC, updatedApplication.getApplicationId().toString(), event);
        ApplicationResponse response = modelMapper.map(updatedApplication, ApplicationResponse.class);
        response.setApplicantInfo(getApplicantInfo(updatedApplication.getApplicantId()));
        return response;
    }

    @Override
    public List<ApplicationResponse> getMyApplications() {
        UUID applicantId = getCurrentUserId();
        List<Application> applications = applicationRepository.findByApplicantId(applicantId);

        return applications.stream()
                .map(application -> {
                    ApplicationResponse response = modelMapper.map(application, ApplicationResponse.class);
                    response.setApplicantInfo(getMyInfo());
                    return response;
                })
                .collect(Collectors.toList());
    }

    private UUID getCurrentUserId() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        if (!(authentication.getPrincipal() instanceof Jwt jwt)) {
            throw new RuntimeException("Cannot get userId from token");
        }
        return UUID.fromString(jwt.getClaimAsString("userId"));
    }
    private ApplicantInfo getApplicantInfo(UUID applicantId) {
        UserResponse userResponse=userClient.getUserById(String.valueOf(applicantId)).getResult();
        return ApplicantInfo.builder()
                .fullName(userResponse.getFullName())
                .email(userResponse.getEmail())
                .phone(userResponse.getPhone())
                .address(userResponse.getAddress())
                .avatarUrl(userResponse.getAvatarUrl())
                .build();
    }
    private ApplicantInfo getMyInfo() {
        UserResponse userResponse=userClient.getMyInfo().getResult();
        return ApplicantInfo.builder()
                .fullName(userResponse.getFullName())
                .email(userResponse.getEmail())
                .phone(userResponse.getPhone())
                .address(userResponse.getAddress())
                .avatarUrl(userResponse.getAvatarUrl())
                .build();
    }
}

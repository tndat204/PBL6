package com.pbl6.jobservice.service.impl;

import com.pbl6.event.dto.CompanyActivatedEvent;
import com.pbl6.event.dto.CompanyDeactivatedEvent;
import com.pbl6.event.dto.CompanyRegisteredEvent;
import com.pbl6.jobservice.client.FileClient;
import com.pbl6.jobservice.dto.request.CreateCompanyRequest;
import com.pbl6.jobservice.dto.request.UpdateCompanyRequest;
import com.pbl6.jobservice.dto.response.CompanyResponse;
import com.pbl6.jobservice.entity.Company;
import com.pbl6.jobservice.entity.CompanyUser;
import com.pbl6.jobservice.exception.AppException;
import com.pbl6.jobservice.exception.ErrorCode;
import com.pbl6.jobservice.repository.CompanyRepository;
import com.pbl6.jobservice.repository.CompanyUserRepository;
import com.pbl6.jobservice.repository.JobRepository;
import com.pbl6.jobservice.service.CompanyService;
import jakarta.transaction.Transactional;
import lombok.AccessLevel;
import lombok.RequiredArgsConstructor;
import lombok.experimental.FieldDefaults;
import lombok.extern.slf4j.Slf4j;
import org.modelmapper.Conditions;
import org.modelmapper.ModelMapper;
import org.springframework.kafka.core.KafkaTemplate;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;
import java.util.UUID;

@Service
@Slf4j
@RequiredArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE, makeFinal = true)
public class CompanyServiceImpl implements CompanyService {
    CompanyRepository companyRepository;
    ModelMapper modelMapper;
    CompanyUserRepository  companyUserRepository;
    JobRepository   jobRepository;
    FileClient fileClient;
    KafkaTemplate<String, Object> kafkaTemplate;
    static String COMPANY_REGISTERED_TOPIC = "company_registered_topic";
    static String COMPANY_ACTIVATED_TOPIC = "company_activated_topic";
    static String COMPANY_DEACTIVATED_TOPIC = "company_deactivated_topic";
    @Override
    public CompanyResponse createCompany(CreateCompanyRequest request) {
        // Map request sang entity
        Company company = modelMapper.map(request, Company.class);

        // Lấy công ty nếu đã tồn tại, hoặc tạo mới
        Company savedCompany = companyRepository.findByTaxCode(company.getTaxCode());
        if (savedCompany == null) {
            savedCompany = companyRepository.save(company);
            CompanyRegisteredEvent event = new CompanyRegisteredEvent(
                    savedCompany.getId().toString(),
                    savedCompany.getName()
            );

            // 3. Bắn event "Đăng ký mới"
            kafkaTemplate.send(COMPANY_REGISTERED_TOPIC, savedCompany.getId().toString(), event);
        }

        CompanyUser companyUser = CompanyUser.builder()
                .company(savedCompany)
                .userId(request.getOwnerID())
                .role(CompanyUser.Role.RECRUITER)
                .status(CompanyUser.Status.INACTIVE)
                .build();

        companyUserRepository.save(companyUser);


        return modelMapper.map(savedCompany, CompanyResponse.class);
    }


    @Transactional
    public CompanyResponse updateCompany(String id, UpdateCompanyRequest request) {
        UUID userId = getCurrentUserId();

        Company company = companyRepository.findById(UUID.fromString(id))
                .orElseThrow(() -> new AppException(ErrorCode.COMPANY_NOT_FOUND));

        // Chỉ owner mới update được
        boolean isOwner = companyUserRepository.existsByCompanyIdAndUserIdAndStatusInAndRoleIn(
                company.getId(),
                userId,
                List.of(CompanyUser.Status.ACTIVE),
                List.of(CompanyUser.Role.RECRUITER, CompanyUser.Role.RECRUITER)
        );

        if (!isOwner) {
            throw new RuntimeException("User is not allowed to update this company");
        }

        ModelMapper mapper = new ModelMapper();
        mapper.getConfiguration().setPropertyCondition(Conditions.isNotNull());

        // Map request -> entity
        mapper.map(request,company);

        Company updated = companyRepository.save(company);
        return modelMapper.map(updated, CompanyResponse.class);
    }

    @Override
    public CompanyResponse getCompanyById(String id) {
        Company company = companyRepository.findById(UUID.fromString(id))
                .orElseThrow(() -> new AppException(ErrorCode.COMPANY_NOT_FOUND));
        return modelMapper.map(company, CompanyResponse.class);
    }

    @Override
    public List<CompanyResponse> getAllCompanies() {
        return companyRepository.findAll().stream()
                .map(c -> modelMapper.map(c, CompanyResponse.class))
                .toList();
    }

    @Transactional
    public void deleteCompanyById(String id) {
        UUID userId = getCurrentUserId();

        Company company = companyRepository.findById(UUID.fromString(id))
                .orElseThrow(() -> new AppException(ErrorCode.COMPANY_NOT_FOUND));

        boolean isOwner = companyUserRepository.existsByCompanyIdAndUserIdAndStatusInAndRoleIn(
                company.getId(),
                userId,
                List.of(CompanyUser.Status.ACTIVE),
                List.of(CompanyUser.Role.RECRUITER)
        );

        if (!isOwner) {
            throw new RuntimeException("User is not allowed to delete this company");
        }
        if (companyUserRepository.existsByCompanyId(UUID.fromString(id))) {
            companyUserRepository.deleteByCompanyId(UUID.fromString(id));
        }
        if (jobRepository.existsByCompanyId(UUID.fromString(id))) {
            jobRepository.deleteByCompanyId(UUID.fromString(id));
        }
        companyRepository.delete(company);
    }

    @PreAuthorize("hasRole('ADMIN')")
    public void activateCompanyById(String id) {
        Company company = companyRepository.findById(UUID.fromString(id))
                .orElseThrow(() -> new AppException(ErrorCode.COMPANY_NOT_FOUND));
        company.setActive(true);
        companyRepository.save(company);
        CompanyActivatedEvent event = new CompanyActivatedEvent(
                company.getId().toString()
        );

        // 3. Bắn event "Đã kích hoạt"
        kafkaTemplate.send(COMPANY_ACTIVATED_TOPIC, company.getId().toString(), event);
    }

    @PreAuthorize("hasRole('ADMIN')")
    public void deactivateCompanyById(String id) {
        Company company = companyRepository.findById(UUID.fromString(id))
                .orElseThrow(() -> new AppException(ErrorCode.COMPANY_NOT_FOUND));
        company.setActive(false);
        companyRepository.save(company);
        CompanyDeactivatedEvent event = new CompanyDeactivatedEvent(
                company.getId().toString()
        );

        // 3. Bắn event "Đã BỎ kích hoạt"
        kafkaTemplate.send(COMPANY_DEACTIVATED_TOPIC, company.getId().toString(), event);
    }

    @Override
    public String uploadLogo(MultipartFile file,String companyId) {
        UUID userId = getCurrentUserId();

        Company company = companyRepository.findById(UUID.fromString(companyId))
                .orElseThrow(() -> new AppException(ErrorCode.COMPANY_NOT_FOUND));

        boolean isOwner = companyUserRepository.existsByCompanyIdAndUserIdAndStatusInAndRoleIn(
                company.getId(),
                userId,
                List.of(CompanyUser.Status.ACTIVE),
                List.of(CompanyUser.Role.RECRUITER)
        );

        if (!isOwner) {
            throw new AppException(ErrorCode.NOT_ALLOW_TO_UPLOAD_LOGO);
        }
        String url=fileClient.uploadFile(file,"company_logo").getResult();
        company.setLogoUrl(url);
        companyRepository.save(company);
        return url;
    }

    @Override
    public CompanyResponse getMyCompany(){
        UUID userId = getCurrentUserId();
        CompanyUser companyUser = companyUserRepository
                .findByUserIdAndStatus(userId, CompanyUser.Status.ACTIVE)
                .orElseThrow(() -> new AppException(ErrorCode.USER_NOT_ASSOCIATED_WITH_COMPANY));
        Company company = companyUser.getCompany();
        return modelMapper.map(company, CompanyResponse.class);
    }

    @PreAuthorize("hasRole('ADMIN')")
    public void toggleUserStatus(String companyId, String userId) {
        UUID companyUUID = UUID.fromString(companyId);
        UUID userUUID = UUID.fromString(userId);

        Company company = companyRepository.findById(companyUUID)
                .orElseThrow(() -> new AppException(ErrorCode.COMPANY_NOT_FOUND));

        CompanyUser companyUser = companyUserRepository.findByCompanyIdAndUserId(companyUUID, userUUID)
                .orElseThrow(() -> new AppException(ErrorCode.USER_NOT_FOUND_IN_COMPANY));

        if (companyUser.getStatus() == CompanyUser.Status.ACTIVE) {
            companyUser.setStatus(CompanyUser.Status.INACTIVE);
        } else {
            companyUser.setStatus(CompanyUser.Status.ACTIVE);
        }

        companyUserRepository.save(companyUser);
    }


    private UUID getCurrentUserId() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        if (!(authentication.getPrincipal() instanceof Jwt jwt)) {
            throw new RuntimeException("Cannot get userId from token");
        }
        return UUID.fromString(jwt.getClaimAsString("userId"));
    }
}

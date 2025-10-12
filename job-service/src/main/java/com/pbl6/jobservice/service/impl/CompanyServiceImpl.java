package com.pbl6.jobservice.service.impl;

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
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.stereotype.Service;

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
    @Override
    public CompanyResponse createCompany(CreateCompanyRequest request) {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();

        if (!(authentication.getPrincipal() instanceof Jwt jwt)) {
            throw new RuntimeException("Cannot get userId from token");
        }
        UUID ownerId= UUID.fromString(jwt.getClaimAsString("userId"));
        Company company = modelMapper.map(request, Company.class);
        company.setOwnerId(ownerId);

        Company saved = companyRepository.save(company);
        CompanyUser companyUser = CompanyUser.builder()
                .company(saved)
                .userId(ownerId)
                .role(CompanyUser.Role.OWNER)
                .status(CompanyUser.Status.ACTIVE)
                .build();

        companyUserRepository.save(companyUser);
        return modelMapper.map(saved, CompanyResponse.class);

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
                List.of(CompanyUser.Role.OWNER, CompanyUser.Role.RECRUITER)
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

        // Chỉ owner mới xóa được
        boolean isOwner = companyUserRepository.existsByCompanyIdAndUserIdAndStatusInAndRoleIn(
                company.getId(),
                userId,
                List.of(CompanyUser.Status.ACTIVE),
                List.of(CompanyUser.Role.OWNER, CompanyUser.Role.RECRUITER)
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

    private UUID getCurrentUserId() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        if (!(authentication.getPrincipal() instanceof Jwt jwt)) {
            throw new RuntimeException("Cannot get userId from token");
        }
        return UUID.fromString(jwt.getClaimAsString("userId"));
    }
}

package com.pbl6.jobservice.repository;

import com.pbl6.jobservice.entity.CompanyUser;
import jakarta.transaction.Transactional;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.stereotype.Repository;

import java.util.Collection;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface CompanyUserRepository extends JpaRepository<CompanyUser, UUID> {
    boolean existsByCompanyIdAndUserIdAndStatusInAndRoleIn(
            UUID companyId, UUID userId,
            Collection<CompanyUser.Status> status,
            Collection<CompanyUser.Role> roles
    );
    boolean existsByCompanyId(UUID companyId);
    @Transactional
    @Modifying
    void deleteByCompanyId(UUID companyId);

    Optional<CompanyUser> findByUserIdAndStatus(UUID userId, CompanyUser.Status status);

    Optional<CompanyUser> findByCompanyIdAndUserId(UUID companyId, UUID userId);
}

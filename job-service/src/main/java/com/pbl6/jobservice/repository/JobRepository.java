package com.pbl6.jobservice.repository;

import com.pbl6.jobservice.entity.Job;
import jakarta.transaction.Transactional;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.stereotype.Repository;

import java.util.UUID;

@Repository
public interface JobRepository extends JpaRepository<Job, UUID> {
    boolean existsByCompanyId(UUID companyId);

    @Transactional
    @Modifying
    void deleteByCompanyId(UUID companyId);
}

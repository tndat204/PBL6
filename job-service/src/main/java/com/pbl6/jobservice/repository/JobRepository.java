package com.pbl6.jobservice.repository;

import com.pbl6.jobservice.entity.Company;
import com.pbl6.jobservice.entity.Job;
import jakarta.transaction.Transactional;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.UUID;

@Repository
public interface JobRepository extends JpaRepository<Job, UUID> {
    boolean existsByCompanyId(UUID companyId);

    @Transactional
    @Modifying
    void deleteByCompanyId(UUID companyId);

    @Query("SELECT j.company FROM Job j WHERE j.id = :jobId")
    Company findCompanyByJobId(@Param("jobId") UUID jobId);
}

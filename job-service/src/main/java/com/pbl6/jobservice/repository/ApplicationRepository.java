package com.pbl6.jobservice.repository;

import com.pbl6.jobservice.entity.Application;
import com.pbl6.jobservice.entity.Company;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface ApplicationRepository  extends JpaRepository<Application, UUID> {
    List<Application> findByJobId(UUID jobId);
    @Query("SELECT c FROM Application a JOIN a.job j JOIN j.company c WHERE a.applicationId = :applicationId")
    Optional<Company> findCompanyByApplicationId(@Param("applicationId") UUID applicationId);
}

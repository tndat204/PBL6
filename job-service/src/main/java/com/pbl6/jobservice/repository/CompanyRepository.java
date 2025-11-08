package com.pbl6.jobservice.repository;

import com.pbl6.jobservice.entity.Company;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.UUID;

@Repository
public interface CompanyRepository extends JpaRepository<Company, UUID> {
    boolean existsByTaxCode(String taxCode);
    Company findByTaxCode(String taxCode);
}

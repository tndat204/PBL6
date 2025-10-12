package com.pbl6.jobservice.repository;

import com.pbl6.jobservice.entity.JobCategory;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.UUID;
@Repository
public interface JobCategoryRepository extends JpaRepository<JobCategory, UUID> {
}

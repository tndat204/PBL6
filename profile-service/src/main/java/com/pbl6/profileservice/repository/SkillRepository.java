package com.pbl6.profileservice.repository;

import com.pbl6.profileservice.entity.Skill;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.UUID;

public interface SkillRepository extends JpaRepository<Skill, UUID> {
    public List<Skill> findByCategoryId(UUID category_id);
}

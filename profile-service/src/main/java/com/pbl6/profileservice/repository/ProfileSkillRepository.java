package com.pbl6.profileservice.repository;

import com.pbl6.profileservice.entity.ProfileSkill;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.UUID;

public interface ProfileSkillRepository extends JpaRepository<ProfileSkill, UUID> {
}

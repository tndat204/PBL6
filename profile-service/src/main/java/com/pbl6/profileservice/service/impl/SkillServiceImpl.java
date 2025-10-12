package com.pbl6.profileservice.service.impl;

import com.pbl6.profileservice.dto.request.SkillRequest;
import com.pbl6.profileservice.dto.response.SkillResponse;
import com.pbl6.profileservice.entity.Skill;
import com.pbl6.profileservice.exception.AppException;
import com.pbl6.profileservice.exception.ErrorCode;
import com.pbl6.profileservice.repository.SkillRepository;
import com.pbl6.profileservice.service.SkillService;
import lombok.AccessLevel;
import lombok.RequiredArgsConstructor;
import lombok.experimental.FieldDefaults;
import lombok.extern.slf4j.Slf4j;
import org.modelmapper.ModelMapper;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
@Slf4j
@RequiredArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE, makeFinal = true)
public class SkillServiceImpl implements SkillService {
    SkillRepository skillRepository;
    ModelMapper modelMapper;

    @PreAuthorize("hasRole('ADMIN')")
    public SkillResponse createSkill(SkillRequest skillRequest) {
        Skill skill=modelMapper.map(skillRequest, Skill.class);
        Skill savedSkill=skillRepository.save(skill);
        return  modelMapper.map(savedSkill, SkillResponse.class);
    }

    @PreAuthorize("hasRole('ADMIN')")
    public SkillResponse updateSkill(String id, SkillRequest skillRequest) {
        Skill skill=skillRepository.findById(UUID.fromString(id))
                .orElseThrow(()->new AppException(ErrorCode.SKILL_NOT_FOUND));
        skill.setName(skillRequest.getName());
        Skill savedSkill=skillRepository.save(skill);
        return modelMapper.map(savedSkill, SkillResponse.class);
    }

    @PreAuthorize("hasRole('ADMIN')")
    public SkillResponse getSkillById(String id) {
        Skill skill=skillRepository.findById(UUID.fromString(id))
                .orElseThrow(()->new AppException(ErrorCode.SKILL_NOT_FOUND));
        return modelMapper.map(skill, SkillResponse.class);
    }

    @PreAuthorize("hasRole('ADMIN')")
    public List<SkillResponse> getAllSkills(String categoryId) {
        List<Skill> skills;

        if (categoryId != null) {
            // Lấy tất cả skills theo categoryId
            skills = skillRepository.findByCategoryId(UUID.fromString(categoryId));
        } else {
            // Lấy tất cả skills
            skills = skillRepository.findAll();
        }

        return skills.stream()
                .map(skill -> modelMapper.map(skill, SkillResponse.class))
                .collect(Collectors.toList());
    }

    @PreAuthorize("hasRole('ADMIN')")
    public void deleteSkill(String id) {
        Skill skill=skillRepository.findById(UUID.fromString(id))
                .orElseThrow(()->new AppException(ErrorCode.SKILL_NOT_FOUND));
        skillRepository.delete(skill);
    }
}

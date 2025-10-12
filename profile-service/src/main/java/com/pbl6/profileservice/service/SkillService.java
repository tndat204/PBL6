package com.pbl6.profileservice.service;

import com.pbl6.profileservice.dto.request.SkillRequest;
import com.pbl6.profileservice.dto.response.SkillResponse;

import java.util.List;

public interface SkillService {
    public SkillResponse createSkill(SkillRequest skillRequest);
    public SkillResponse updateSkill(String id,SkillRequest skillRequest);
    public SkillResponse getSkillById(String id);
    public List<SkillResponse> getAllSkills(String categoryId);
    public void deleteSkill(String id);
}

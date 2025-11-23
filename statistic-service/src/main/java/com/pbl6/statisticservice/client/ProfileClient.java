package com.pbl6.statisticservice.client;

import com.pbl6.statisticservice.dto.response.APIResponse;
import com.pbl6.statisticservice.dto.response.SkillResponse;
import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;

@FeignClient(
        name = "profile-service",
        path = "/api/skills"
)
public interface ProfileClient {
    @GetMapping("/{id}")
    public APIResponse<SkillResponse> getSkill(@PathVariable String id);
}

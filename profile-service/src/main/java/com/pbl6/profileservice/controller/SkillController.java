package com.pbl6.profileservice.controller;

import com.pbl6.profileservice.dto.request.SkillRequest;
import com.pbl6.profileservice.dto.response.APIResponse;
import com.pbl6.profileservice.dto.response.SkillResponse;
import com.pbl6.profileservice.service.SkillService;
import lombok.AccessLevel;
import lombok.experimental.FieldDefaults;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/skills")
@FieldDefaults(level= AccessLevel.PRIVATE,makeFinal=true)
public class SkillController {
    SkillService skillService;
    public SkillController(SkillService skillService) {
        this.skillService = skillService;
    }
    @PostMapping
    public APIResponse<SkillResponse> createSkill(@RequestBody SkillRequest skillRequest){
        return APIResponse.<SkillResponse>builder()
                .code(200)
                .result(skillService.createSkill(skillRequest))
                .build();
    }
    @GetMapping("/{id}")
    public APIResponse<SkillResponse> getSkill(@PathVariable String id){
        return APIResponse.<SkillResponse>builder()
                .code(200)
                .result(skillService.getSkillById(id))
                .build();
    }
    @GetMapping
    public APIResponse<List<SkillResponse>> getAllSkills(@RequestParam(required = false) String categoryId){
        return APIResponse.<List<SkillResponse>>builder()
                .code(200)
                .result(skillService.getAllSkills(categoryId))
                .build();
    }
    @PutMapping("/{id}")
    public APIResponse<SkillResponse> updateSkill(@PathVariable String id, @RequestBody SkillRequest skillRequest){
        return APIResponse.<SkillResponse>builder()
                .code(200)
                .result(skillService.updateSkill(id, skillRequest))
                .build();
    }
    @DeleteMapping("/{id}")
    public APIResponse<String> deleteSkill(@PathVariable String id){
        skillService.deleteSkill(id);
        return APIResponse.<String>builder()
                .code(200)
                .result("Skill deleted successfully")
                .build();
    }
}

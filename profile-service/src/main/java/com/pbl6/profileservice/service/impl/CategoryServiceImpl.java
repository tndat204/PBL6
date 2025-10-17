package com.pbl6.profileservice.service.impl;

import com.pbl6.profileservice.dto.request.CategoryRequest;
import com.pbl6.profileservice.dto.request.SkillRequest;
import com.pbl6.profileservice.dto.response.CategoryResponse;
import com.pbl6.profileservice.dto.response.SkillResponse;
import com.pbl6.profileservice.entity.Category;
import com.pbl6.profileservice.entity.Skill;
import com.pbl6.profileservice.exception.AppException;
import com.pbl6.profileservice.exception.ErrorCode;
import com.pbl6.profileservice.repository.CategoryRepository;
import com.pbl6.profileservice.repository.SkillRepository;
import com.pbl6.profileservice.service.CategoryService;
import jakarta.transaction.Transactional;
import lombok.AccessLevel;
import lombok.RequiredArgsConstructor;
import lombok.experimental.FieldDefaults;
import lombok.extern.slf4j.Slf4j;
import org.modelmapper.ModelMapper;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.stereotype.Service;

import java.util.HashSet;
import java.util.List;
import java.util.Set;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
@Slf4j
@RequiredArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE, makeFinal = true)
public class CategoryServiceImpl implements CategoryService {
    CategoryRepository categoryRepository;
    ModelMapper modelMapper;
    SkillRepository skillRepository;

    @PreAuthorize("hasRole('ADMIN')")
    public CategoryResponse createCategory(CategoryRequest categoryRequest) {
        Category category = new Category();
        category.setName(categoryRequest.getName());

        if(categoryRequest.getSkillIds() != null && !categoryRequest.getSkillIds().isEmpty()) {
            Set<Skill> skills = categoryRequest.getSkillIds().stream()
                    .map(skillId -> skillRepository.findById(skillId)
                            .orElseThrow(() -> new AppException(ErrorCode.SKILL_NOT_FOUND)))
                    .collect(Collectors.toSet());
            category.setSkills(skills);
            // gán ngược lại category cho skill nếu cần
            skills.forEach(skill -> skill.setCategory(category));
        }

        Category savedCategory = categoryRepository.save(category);
        return modelMapper.map(savedCategory, CategoryResponse.class);
    }

    @Override
    public CategoryResponse getCategoryById(String id) {
        Category category = categoryRepository.findById(UUID.fromString(id))
                .orElseThrow(() -> new AppException(ErrorCode.CATEGORY_NOT_FOUND));

        return modelMapper.map(category, CategoryResponse.class);
    }

    public List<CategoryResponse> getCategory() {
        List<Category> categories = categoryRepository.findAll();

        return categories.stream()
                .map(category -> {
                    CategoryResponse response = modelMapper.map(category, CategoryResponse.class);
                    if (category.getSkills() != null) {
                        List<SkillResponse> skillResponses = category.getSkills().stream()
                                .map(skill -> modelMapper.map(skill, SkillResponse.class))
                                .collect(Collectors.toList());
                        response.setSkills(skillResponses);
                    }
                    return response;
                })
                .collect(Collectors.toList());
    }

    @PreAuthorize("hasRole('ADMIN')")
    @Transactional
    public CategoryResponse updateCategory(String id, CategoryRequest categoryRequest) {
        Category category = categoryRepository.findById(UUID.fromString(id))
                .orElseThrow(() -> new AppException(ErrorCode.CATEGORY_NOT_FOUND));

        // Cập nhật tên category
        category.setName(categoryRequest.getName());

        if (categoryRequest.getSkillIds() != null && !categoryRequest.getSkillIds().isEmpty()) {
            // Lấy danh sách skill mới
            Set<Skill> newSkills = categoryRequest.getSkillIds().stream()
                    .map(skillId -> skillRepository.findById(skillId)
                            .orElseThrow(() -> new AppException(ErrorCode.SKILL_NOT_FOUND)))
                    .collect(Collectors.toSet());

            // Xóa category khỏi các skill cũ không còn trong danh sách mới
            category.getSkills().stream()
                    .filter(skill -> !newSkills.contains(skill))
                    .forEach(skill -> skill.setCategory(null));

            // Cập nhật skills mới
            category.setSkills(newSkills);
            newSkills.forEach(skill -> skill.setCategory(category));
        }

        Category savedCategory = categoryRepository.save(category);

        // Mapping sang DTO bằng ModelMapper
        return modelMapper.map(savedCategory, CategoryResponse.class);
    }



    @PreAuthorize("hasRole('ADMIN')")
    public void deleteCategory(String id) {
        Category category = categoryRepository.findById(UUID.fromString(id))
                .orElseThrow(() -> new AppException(ErrorCode.CATEGORY_NOT_FOUND));
        categoryRepository.delete(category);
    }
}


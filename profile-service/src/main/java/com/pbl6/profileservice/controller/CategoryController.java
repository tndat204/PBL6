package com.pbl6.profileservice.controller;

import com.pbl6.profileservice.dto.request.CategoryRequest;
import com.pbl6.profileservice.dto.response.APIResponse;
import com.pbl6.profileservice.dto.response.CategoryResponse;
import com.pbl6.profileservice.service.CategoryService;
import lombok.AccessLevel;
import lombok.experimental.FieldDefaults;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/categories")
@FieldDefaults(level= AccessLevel.PRIVATE,makeFinal=true)
public class CategoryController {
    CategoryService categoryService;

    public CategoryController(CategoryService categoryService) {
        this.categoryService = categoryService;
    }

    @PostMapping
    public APIResponse<CategoryResponse> createCategory(@RequestBody CategoryRequest categoryRequest) {
        return APIResponse.<CategoryResponse>builder()
                .code(200)
                .result(categoryService.createCategory(categoryRequest))
                .build();
    }

    @GetMapping("/{id}")
    public APIResponse<CategoryResponse> getCategory(@PathVariable String id) {
        return APIResponse.<CategoryResponse>builder()
                .code(200)
                .result(categoryService.getCategoryById(id))
                .build();
    }

    @GetMapping
    public APIResponse<List<CategoryResponse>> getAllCategories() {
        return APIResponse.<List<CategoryResponse>>builder()
                .code(200)
                .result(categoryService.getCategory())
                .build();
    }

    @PutMapping("/{id}")
    public APIResponse<CategoryResponse> updateCategory(@PathVariable String id, @RequestBody CategoryRequest categoryRequest) {
        return APIResponse.<CategoryResponse>builder()
                .code(200)
                .result(categoryService.updateCategory(id, categoryRequest))
                .build();
    }

    @DeleteMapping("/{id}")
    public APIResponse<String> deleteCategory(@PathVariable String id) {
        categoryService.deleteCategory(id);
        return APIResponse.<String>builder()
                .code(200)
                .result("Category deleted successfully")
                .build();
    }
}

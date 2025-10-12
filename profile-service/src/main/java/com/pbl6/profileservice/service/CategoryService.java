package com.pbl6.profileservice.service;

import com.pbl6.profileservice.dto.request.CategoryRequest;
import com.pbl6.profileservice.dto.response.CategoryResponse;

import java.util.List;

public interface CategoryService {
    public CategoryResponse createCategory(CategoryRequest categoryRequest);
    public CategoryResponse getCategoryById(String id);
    public List<CategoryResponse> getCategory();
    public CategoryResponse updateCategory(String id,CategoryRequest categoryRequest);
    public void deleteCategory(String id);
}

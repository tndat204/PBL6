package com.pbl6.profileservice.service;

import com.pbl6.profileservice.dto.request.ProfileRequest;
import com.pbl6.profileservice.dto.response.ProfileResponse;

public interface ProfileService {
    public ProfileResponse createProfile(ProfileRequest profileRequest);
    public ProfileResponse updateMyProfile(ProfileRequest profileRequest);
    public ProfileResponse getMyProfile();
    public ProfileResponse getProfileByUserId(String userId);
    public void toggleActive();

}

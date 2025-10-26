package com.pbl6.profileservice.controller;

import com.pbl6.profileservice.dto.request.ProfileRequest;
import com.pbl6.profileservice.dto.response.APIResponse;
import com.pbl6.profileservice.dto.response.ProfileResponse;
import com.pbl6.profileservice.service.ProfileService;
import lombok.AccessLevel;
import lombok.experimental.FieldDefaults;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

@RestController
@RequestMapping("/api/profiles")
@FieldDefaults(level= AccessLevel.PRIVATE,makeFinal=true)
public class ProfileController {
    ProfileService profileService;
    public ProfileController(ProfileService profileService) {
        this.profileService = profileService;
    }

    @PostMapping
    public APIResponse<ProfileResponse> createProfile(@RequestBody ProfileRequest profileRequest) {
        return APIResponse.<ProfileResponse>builder()
                .code(200)
                .result(profileService.createProfile(profileRequest))
                .build();
    }

    @GetMapping("/me")
    public APIResponse<ProfileResponse> getMyProfile() {
        return APIResponse.<ProfileResponse>builder()
                .code(200)
                .result(profileService.getMyProfile())
                .build();
    }

    @GetMapping("/{userId}")
    public APIResponse<ProfileResponse> getProfileByUserId(@PathVariable String userId) {
        return APIResponse.<ProfileResponse>builder()
                .code(200)
                .result(profileService.getProfileByUserId(userId))
                .build();
    }
    @GetMapping("/me/cv")
    public APIResponse<String> getCv()
    {
        return APIResponse.<String>builder()
                .code(200)
                .result(profileService.getCv())
                .build();
    }

    @PutMapping("/me")
    public APIResponse<ProfileResponse> updateProfile(@RequestBody ProfileRequest profileRequest) {
        return APIResponse.<ProfileResponse>builder()
                .code(200)
                .result(profileService.updateMyProfile(profileRequest))
                .build();
    }

    @PutMapping("/me/status")
    public APIResponse<String> toggleStatus()
    {
        profileService.toggleActive();
        return APIResponse.<String>builder()
                .code(200)
                .result("Toggle status successfully")
                .build();
    }
    @PutMapping("/me/cv")
    public APIResponse<String>  uploadCV(@RequestParam("file") MultipartFile file)
    {
        return APIResponse.<String>builder()
                .code(200)
                .result(profileService.uploadCv(file))
                .build();
    }
}

package com.pbl6.profileservice.service.impl;

import com.pbl6.profileservice.client.FileClient;
import com.pbl6.profileservice.dto.request.ProfileRequest;
import com.pbl6.profileservice.dto.response.ProfileResponse;
import com.pbl6.profileservice.entity.Profile;
import com.pbl6.profileservice.entity.ProfileSkill;
import com.pbl6.profileservice.entity.ProfileSkillId;
import com.pbl6.profileservice.entity.Skill;
import com.pbl6.profileservice.exception.AppException;
import com.pbl6.profileservice.exception.ErrorCode;
import com.pbl6.profileservice.repository.ProfileRepository;
import com.pbl6.profileservice.repository.ProfileSkillRepository;
import com.pbl6.profileservice.repository.SkillRepository;
import com.pbl6.profileservice.service.ProfileService;
import jakarta.transaction.Transactional;
import lombok.AccessLevel;
import lombok.RequiredArgsConstructor;
import lombok.experimental.FieldDefaults;
import lombok.extern.slf4j.Slf4j;
import org.modelmapper.Conditions;
import org.modelmapper.ModelMapper;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.util.HashSet;
import java.util.Set;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
@Slf4j
@RequiredArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE, makeFinal = true)
public class ProfileServiceImpl implements ProfileService {
    ProfileRepository profileRepository;
    ModelMapper modelMapper;
    SkillRepository skillRepository;
    FileClient fileClient;
    ProfileSkillRepository profileSkillRepository;

    @Transactional
    public ProfileResponse createProfile(ProfileRequest profileRequest) {
        Profile profile = modelMapper.map(profileRequest, Profile.class);
        profile.setUserId(profileRequest.getUserId());
        profile.setIsActive(true);

        if (profileRequest.getSkills() != null) {
            Set<ProfileSkill> profileSkills = profileRequest.getSkills().stream()
                    .map(skillDto -> {
                        Skill skill = skillRepository.findById(skillDto.getSkillId())
                                .orElseThrow(() -> new AppException(ErrorCode.SKILL_NOT_FOUND));

                        // Khởi tạo và thiết lập ProfileSkill thủ công để xử lý khóa chính kép
                        ProfileSkill profileSkill = new ProfileSkill();
                        ProfileSkillId profileSkillId = new ProfileSkillId();
                        profileSkillId.setSkillId(skill.getId());
                        // Profile ID sẽ được thiết lập sau khi profile được lưu

                        profileSkill.setId(profileSkillId);
                        profileSkill.setExperienceYears(skillDto.getExperienceYears());
                        profileSkill.setLevel(skillDto.getLevel());
                        profileSkill.setIsPrimary(skillDto.getIsPrimary());

                        profileSkill.setSkill(skill);
                        profileSkill.setProfile(profile);

                        return profileSkill;
                    })
                    .collect(Collectors.toSet());
            profile.setSkills(profileSkills);
        }

        Profile savedProfile = profileRepository.save(profile);
        return modelMapper.map(savedProfile, ProfileResponse.class);
    }

    @Transactional
    public ProfileResponse updateMyProfile(ProfileRequest profileRequest) {
        UUID userId = getCurrentUserId();
        Profile profile = profileRepository.findByUserId(userId)
                .orElseThrow(() -> new AppException(ErrorCode.PROFILE_NOT_FOUND));

        // Kiểm tra và cập nhật từng trường một cách an toàn
        if (profileRequest.getHeadline() != null) {
            profile.setHeadline(profileRequest.getHeadline());
        }
        if (profileRequest.getSummary() != null) {
            profile.setSummary(profileRequest.getSummary());
        }
        if (profileRequest.getCvFile() != null) {
            profile.setCvFile(profileRequest.getCvFile());
        }
        if (profileRequest.getLinkedinUrl() != null) {
            profile.setLinkedinUrl(profileRequest.getLinkedinUrl());
        }
        if (profileRequest.getPortfolioUrl() != null) {
            profile.setPortfolioUrl(profileRequest.getPortfolioUrl());
        }
        if (profileRequest.getDesiredSalary() != null) {
            profile.setDesiredSalary(profileRequest.getDesiredSalary());
        }

        if (profileRequest.getSkills() != null) {
            if (profile.getSkills() != null) {
                profile.getSkills().clear();
                profileRepository.saveAndFlush(profile);
            } else {
                profile.setSkills(new HashSet<>());
            }

            Set<ProfileSkill> newSkills = profileRequest.getSkills().stream()
                    .map(skillDto -> {
                        Skill skill = skillRepository.findById(skillDto.getSkillId())
                                .orElseThrow(() -> new AppException(ErrorCode.SKILL_NOT_FOUND));

                        ProfileSkill profileSkill = new ProfileSkill();
                        ProfileSkillId profileSkillId = new ProfileSkillId();
                        profileSkillId.setSkillId(skill.getId());
                        profileSkillId.setProfileId(profile.getId());

                        profileSkill.setId(profileSkillId);
                        profileSkill.setExperienceYears(skillDto.getExperienceYears());
                        profileSkill.setLevel(skillDto.getLevel());
                        profileSkill.setIsPrimary(skillDto.getIsPrimary());

                        profileSkill.setProfile(profile);
                        profileSkill.setSkill(skill);

                        return profileSkill;
                    })
                    .collect(Collectors.toSet());

            profile.getSkills().addAll(newSkills);
        }
        // Nếu profileRequest.getSkills() là null, phần này sẽ bị bỏ qua và giữ nguyên skills cũ.

        Profile updatedProfile = profileRepository.save(profile);
        return modelMapper.map(updatedProfile, ProfileResponse.class);
    }

    @Override
    public ProfileResponse getMyProfile() {
        UUID userId = getCurrentUserId();
        // Sửa lỗi: dùng findByUserId thay cho findById
        Profile profile = profileRepository.findByUserId(userId)
                .orElseThrow(() -> new AppException(ErrorCode.PROFILE_NOT_FOUND));
        return modelMapper.map(profile, ProfileResponse.class);
    }

    @Override
    public ProfileResponse getProfileByUserId(String userId) {
        Profile profile = profileRepository.findByUserId(UUID.fromString(userId))
                .orElseThrow(() -> new AppException(ErrorCode.PROFILE_NOT_FOUND));
        if(profile.getIsActive()){
            return modelMapper.map(profile, ProfileResponse.class);
        }
        return new ProfileResponse();
    }

    @Override
    public void toggleActive() {
        UUID userId = getCurrentUserId();
        Profile profile = profileRepository.findByUserId(userId)
                .orElseThrow(() -> new AppException(ErrorCode.PROFILE_NOT_FOUND));
        profile.setIsActive(!profile.getIsActive());
        profileRepository.save(profile);
    }

    @Override
    public String uploadCv(MultipartFile file) {
        UUID userId = getCurrentUserId();
        Profile profile = profileRepository.findByUserId(userId)
                .orElseThrow(() -> new AppException(ErrorCode.PROFILE_NOT_FOUND));
        String urlFile=fileClient.uploadFile(file,"cvs").getResult();
        profile.setCvFile(urlFile);
        profileRepository.save(profile);
        return urlFile;

    }

    @Override
    public String getCv() {
        UUID userId = getCurrentUserId();
        Profile profile = profileRepository.findByUserId(userId)
                .orElseThrow(() -> new AppException(ErrorCode.PROFILE_NOT_FOUND));
        return profile.getCvFile();
    }

    private UUID getCurrentUserId() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        if (!(authentication.getPrincipal() instanceof Jwt jwt)) {
            throw new RuntimeException("Cannot get userId from token");
        }
        return UUID.fromString(jwt.getClaimAsString("userId"));
    }
}
package com.pbl6.statisticservice.service;

import com.pbl6.statisticservice.client.ProfileClient;
import com.pbl6.statisticservice.dto.response.SkillResponse;
import lombok.AccessLevel;
import lombok.RequiredArgsConstructor;
import lombok.experimental.FieldDefaults;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.stereotype.Service;

import java.time.Duration;
import java.util.*;
import java.util.concurrent.ConcurrentHashMap;

@Service
@Slf4j
@RequiredArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE, makeFinal = true)
public class SkillNameResolver {

    StringRedisTemplate redisTemplate; // Dùng StringRedisTemplate cho gọn

    ProfileClient profileClient;
    public Set<String> resolveSkillNames(Set<UUID> skillIds) {
        if (skillIds == null || skillIds.isEmpty()) return new HashSet<>();

        Set<String> skillNames = ConcurrentHashMap.newKeySet(); // Thread-safe Set
        List<UUID> missingIds = new ArrayList<>();

        // --- 1. KIỂM TRA REDIS ---
        for (UUID id : skillIds) {
            String key = "skill:name:" + id.toString();
            String cachedName = redisTemplate.opsForValue().get(key);

            if (cachedName != null) {
                skillNames.add(cachedName);
            } else {
                missingIds.add(id);
            }
        }

        // --- 2. GỌI PROFILE SERVICE (CHO CÁC ID BỊ THIẾU) ---
        if (!missingIds.isEmpty()) {
            // Sử dụng parallelStream để bắn nhiều request cùng lúc -> Nhanh hơn vòng lặp thường
            missingIds.parallelStream().forEach(id -> {
                try {
                    // Gọi Feign Client lấy từng cái
                    SkillResponse skill = profileClient.getSkill(String.valueOf(id)).getResult();

                    if (skill != null) {
                        skillNames.add(skill.getName());
                        // Lưu ngay vào Redis để lần sau không phải gọi nữa
                        saveSkillNameToRedis(skill.getId(), skill.getName());
                    }
                } catch (Exception e) {
                    // Nếu lỗi (ví dụ skill bị xóa bên kia), log lại và bỏ qua để không chết luồng
                    log.error("Error fetching skill id: " + id, e);
                }
            });
        }

        return skillNames;
    }

    private void saveSkillNameToRedis(UUID id, String name) {
        // Cache vĩnh viễn hoặc 7 ngày tùy bạn
        redisTemplate.opsForValue().set("skill:name:" + id.toString(), name, Duration.ofDays(7));
    }
}

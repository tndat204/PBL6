package com.pbl6.fileservice.service.impl;
import com.pbl6.fileservice.service.FileService;
import lombok.AccessLevel;
import lombok.RequiredArgsConstructor;
import lombok.experimental.FieldDefaults;
import lombok.experimental.NonFinal;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpMethod;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.http.HttpHeaders;

import java.io.IOException;
import java.util.UUID;

@Service
@FieldDefaults(level = AccessLevel.PRIVATE, makeFinal = true)
@RequiredArgsConstructor
@Slf4j
public class FileServiceImpl implements FileService {

    @Value("${supabase.project_url}")
    @NonFinal
    String PROJECT_URL;
    @NonFinal
    @Value("${supabase.secrey_key}")
    String SERVICE_ROLE_KEY;
    @NonFinal
    @Value("${supabase.bucket_name}")
    String BUCKET_NAME;

    @Override
    public String uploadFile(MultipartFile file, String folderName) throws IOException {
        RestTemplate restTemplate = new RestTemplate();

        String fileName = folderName + "/" + UUID.randomUUID() + "_" + file.getOriginalFilename();
        String uploadUrl = PROJECT_URL + "/storage/v1/object/" + BUCKET_NAME + "/" + fileName;

        HttpHeaders headers = new HttpHeaders();
        headers.add("apikey", SERVICE_ROLE_KEY);  // Đổi key
        headers.add("Authorization", "Bearer " + SERVICE_ROLE_KEY);  // Đổi key
        headers.add("Content-Type", file.getContentType());

        HttpEntity<byte[]> requestEntity = new HttpEntity<>(file.getBytes(), headers);

        restTemplate.exchange(uploadUrl, HttpMethod.POST, requestEntity, String.class);

        return PROJECT_URL + "/storage/v1/object/public/" + BUCKET_NAME + "/" + fileName;
    }
}

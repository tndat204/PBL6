package com.pbl6.profileservice.client;

import com.pbl6.profileservice.configuration.AuthenticationRequestInterceptor;
import com.pbl6.profileservice.configuration.FeignMultipartConfig;
import com.pbl6.profileservice.dto.response.APIResponse;
import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestPart;
import org.springframework.web.multipart.MultipartFile;

@FeignClient(
        name = "file-service",
        path = "/api/file",
        configuration = {AuthenticationRequestInterceptor.class, FeignMultipartConfig.class}
)
public interface FileClient {

    @PostMapping(value = "/upload", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    APIResponse<String> uploadFile(
            @RequestPart("file") MultipartFile file,
            @RequestPart("folder") String folderName
    );
}

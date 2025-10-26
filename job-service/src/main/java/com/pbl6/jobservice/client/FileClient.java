package com.pbl6.jobservice.client;

import com.pbl6.jobservice.configuration.AuthenticationRequestInterceptor;
import com.pbl6.jobservice.configuration.FeignMultipartConfig;
import com.pbl6.jobservice.dto.response.APIResponse;
import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestPart;
import org.springframework.web.multipart.MultipartFile;

@FeignClient(
        name = "file-service",
        path = "/api/files",
        configuration = {AuthenticationRequestInterceptor.class, FeignMultipartConfig.class}
)
public interface FileClient {

    @PostMapping(consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    APIResponse<String> uploadFile(
            @RequestPart("file") MultipartFile file,
            @RequestPart("folder") String folderName
    );
}

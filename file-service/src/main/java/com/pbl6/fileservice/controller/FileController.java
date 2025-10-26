package com.pbl6.fileservice.controller;

import com.pbl6.fileservice.dto.response.APIResponse;
import com.pbl6.fileservice.service.FileService;
import lombok.AccessLevel;
import lombok.experimental.FieldDefaults;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;

@RestController
@RequestMapping("/api/files")
@FieldDefaults(level= AccessLevel.PRIVATE,makeFinal=true)
public class FileController {
    FileService fileService;
    public FileController(FileService fileService) {
        this.fileService = fileService;
    }
    @PostMapping
    APIResponse<String> uploadFile(@RequestParam("file") MultipartFile file,
                                   @RequestParam(value = "folder", defaultValue = "uploads") String folderName) throws IOException {
        return APIResponse.<String>builder()
                .code(200)
                .result(fileService.uploadFile(file,folderName))
                .build();
    }
}

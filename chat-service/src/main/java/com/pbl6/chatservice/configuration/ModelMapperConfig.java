package com.pbl6.chatservice.configuration;

import org.modelmapper.ModelMapper;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class ModelMapperConfig {

    @Bean
    public ModelMapper modelMapper() {
        ModelMapper modelMapper = new ModelMapper();
        // Tùy chỉnh cấu hình nếu cần, ví dụ:
        modelMapper.getConfiguration().setSkipNullEnabled(true);
        return modelMapper;
    }
}
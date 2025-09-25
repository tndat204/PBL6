package com.pbl6.authservice.client;

import com.pbl6.authservice.dto.request.ExchangeTokenRequest;
import com.pbl6.authservice.dto.response.ExchangeTokenResponse;
import feign.QueryMap;
import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.PostMapping;

@FeignClient(name = "google-service", url = "https://oauth2.googleapis.com")
public interface GoogleClient {
    @PostMapping(value = "/token", produces = MediaType.APPLICATION_FORM_URLENCODED_VALUE)
    ExchangeTokenResponse exchangeToken(@QueryMap ExchangeTokenRequest request);
}
package com.pbl6.gatewayservice.dto;

import lombok.*;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class IntrospectRequest {
    private String token;
}

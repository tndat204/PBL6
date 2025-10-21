package com.pbl6.userservice.dto.response;

import lombok.*;
import lombok.experimental.FieldDefaults;

import java.util.UUID;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE)
public class CompanyResponse {
    UUID id;
    String name;
    String taxCode;
    String address;
    String phone;
    String email;
    String description;
    boolean active;
    String logoUrl;
}

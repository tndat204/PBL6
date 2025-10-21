package com.pbl6.userservice.dto.request;

import lombok.*;
import lombok.experimental.FieldDefaults;

import java.util.UUID;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE)
public class CreateCompanyRequest {
    String name;
    UUID ownerID;
    String taxCode;
    String address;
    String phone;
    String email;
    String description;
}

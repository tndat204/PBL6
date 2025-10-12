package com.pbl6.jobservice.dto.request;

import lombok.*;
import lombok.experimental.FieldDefaults;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE)
public class CreateCompanyRequest {
    String name;
    String taxCode;
    String address;
    String phone;
    String email;
    String description;
}

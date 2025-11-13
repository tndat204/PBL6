package com.pbl6.jobservice.dto.response;

import lombok.*;
import lombok.experimental.FieldDefaults;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE)
public class ApplicantInfo {
    String fullName;
    String avatarUrl;
    String email;
    String phone;
    String address;
}

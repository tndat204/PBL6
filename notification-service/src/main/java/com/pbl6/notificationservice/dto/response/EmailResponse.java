package com.pbl6.notificationservice.dto.response;

import com.pbl6.notificationservice.dto.request.Recipient;
import com.pbl6.notificationservice.dto.request.Sender;
import lombok.*;
import lombok.experimental.FieldDefaults;

import java.util.List;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
@FieldDefaults(level = AccessLevel.PRIVATE)
public class EmailResponse {
    String messageId;
}

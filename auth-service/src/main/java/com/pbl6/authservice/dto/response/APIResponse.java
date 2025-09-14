package com.pbl6.authservice.dto.response;

import com.fasterxml.jackson.annotation.JsonInclude;
import lombok.*;
import lombok.experimental.FieldDefaults;

@Builder
@NoArgsConstructor
@AllArgsConstructor
@JsonInclude(JsonInclude.Include.NON_NULL)
@FieldDefaults(level = AccessLevel.PRIVATE)
public class APIResponse<T> {
    @Setter
    @Getter
    int code;
    @Setter
    @Getter
    String message;
    @Setter
    @Getter
    T result;
}

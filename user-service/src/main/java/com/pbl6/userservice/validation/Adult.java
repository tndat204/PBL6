package com.pbl6.userservice.validation;

import jakarta.validation.Constraint;
import jakarta.validation.Payload;
import java.lang.annotation.*;

@Documented
@Constraint(validatedBy = AdultValidator.class)
@Target({ ElementType.FIELD })
@Retention(RetentionPolicy.RUNTIME)
public @interface Adult {
    String message() default "Tuổi phải từ 18 trở lên và ngày sinh không được ở tương lai";
    Class<?>[] groups() default {};
    Class<? extends Payload>[] payload() default {};
}

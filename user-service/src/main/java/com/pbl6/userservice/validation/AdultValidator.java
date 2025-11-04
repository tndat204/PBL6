package com.pbl6.userservice.validation;

import jakarta.validation.ConstraintValidator;
import jakarta.validation.ConstraintValidatorContext;

import java.time.LocalDate;
import java.time.Period;
import java.time.ZoneId;
import java.util.Date;

public class AdultValidator implements ConstraintValidator<Adult, Date> {

    @Override
    public boolean isValid(Date birthDate, ConstraintValidatorContext context) {
        if (birthDate == null) return false;

        LocalDate date = birthDate.toInstant().atZone(ZoneId.systemDefault()).toLocalDate();
        LocalDate today = LocalDate.now();

        if (date.isAfter(today)) {
            context.disableDefaultConstraintViolation();
            context.buildConstraintViolationWithTemplate("Ngày sinh không được ở tương lai")
                    .addConstraintViolation();
            return false;
        }

        int age = Period.between(date, today).getYears();
        if (age < 18) {
            context.disableDefaultConstraintViolation();
            context.buildConstraintViolationWithTemplate("Tuổi phải từ 18 trở lên")
                    .addConstraintViolation();
            return false;
        }

        return true;
    }
}


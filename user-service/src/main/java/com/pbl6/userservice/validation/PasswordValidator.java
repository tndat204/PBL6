package com.pbl6.userservice.validation;

import jakarta.validation.ConstraintValidator;
import jakarta.validation.ConstraintValidatorContext;

public class PasswordValidator implements ConstraintValidator<ValidPassword, String> {

    @Override
    public boolean isValid(String password, ConstraintValidatorContext context) {
        if (password == null) return false;

        if (password.length() < 8) {
            context.disableDefaultConstraintViolation();
            context.buildConstraintViolationWithTemplate("Mật khẩu phải có ít nhất 8 ký tự")
                    .addConstraintViolation();
            return false;
        }

        if (!password.matches(".*[A-Z].*")) {
            context.disableDefaultConstraintViolation();
            context.buildConstraintViolationWithTemplate("Mật khẩu phải chứa ít nhất 1 chữ hoa")
                    .addConstraintViolation();
            return false;
        }

        if (!password.matches(".*[a-z].*")) {
            context.disableDefaultConstraintViolation();
            context.buildConstraintViolationWithTemplate("Mật khẩu phải chứa ít nhất 1 chữ thường")
                    .addConstraintViolation();
            return false;
        }

        if (!password.matches(".*\\d.*")) {
            context.disableDefaultConstraintViolation();
            context.buildConstraintViolationWithTemplate("Mật khẩu phải chứa ít nhất 1 chữ số")
                    .addConstraintViolation();
            return false;
        }

        if (!password.matches(".*[@$!%*?&].*")) {
            context.disableDefaultConstraintViolation();
            context.buildConstraintViolationWithTemplate("Mật khẩu phải chứa ít nhất 1 ký tự đặc biệt (@$!%*?&)")
                    .addConstraintViolation();
            return false;
        }

        return true;
    }
}

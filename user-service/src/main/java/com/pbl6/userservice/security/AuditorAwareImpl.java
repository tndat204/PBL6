package com.pbl6.userservice.security;

import java.util.Optional;

import org.springframework.data.domain.AuditorAware;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Component;

@Component
public class AuditorAwareImpl implements AuditorAware<String> {

    @Override
    public Optional<String> getCurrentAuditor() {
        return Optional.ofNullable(SecurityContextHolder.getContext().getAuthentication())
                .map(authentication -> {
                    if (authentication.isAuthenticated() && !"anonymousUser".equals(authentication.getName())) {
                        return authentication.getName();
                    }
                    return null;
                });
    }

}

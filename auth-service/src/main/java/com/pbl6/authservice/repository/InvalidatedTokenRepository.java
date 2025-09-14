package com.pbl6.authservice.repository;

import com.pbl6.authservice.entity.InvalidatedToken;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.UUID;


@Repository
public interface InvalidatedTokenRepository extends JpaRepository<InvalidatedToken, UUID> {}

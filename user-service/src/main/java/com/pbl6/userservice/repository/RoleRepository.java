package com.pbl6.userservice.repository;

import com.pbl6.userservice.entity.Role;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.Optional;
import java.util.UUID;

@Repository
public interface RoleRepository extends JpaRepository<Role, UUID> {
    Optional<Role> findByName(String name);
    boolean existsByName(String name);

    @Query("SELECT COUNT(r) FROM Role r JOIN r.permissions p WHERE p.id = :permissionId")
    long countRolesWithPermission(@Param("permissionId") UUID permissionId);
}

package com.pbl6.userservice.entity;

import jakarta.persistence.*;
import lombok.AccessLevel;
import lombok.Data;
import lombok.experimental.FieldDefaults;
import java.util.UUID;

@Data
@Entity
@FieldDefaults(level = AccessLevel.PRIVATE)
@Table(name = "permissions")
public class Permission extends Base {
    @Id
    @GeneratedValue
    @Column(columnDefinition = "uuid")
    UUID id;

    @Column(unique = true, nullable = false)
    String name;
}
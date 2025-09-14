package com.pbl6.userservice.entity;

import jakarta.persistence.*;
import lombok.AccessLevel;
import lombok.Data;
import lombok.experimental.FieldDefaults;


import java.util.Date;
import java.util.HashSet;
import java.util.Set;
import java.util.UUID;
@Data
@Entity
@FieldDefaults(level = AccessLevel.PRIVATE)
@Table(name = "users")
public class User extends Base {
    @Id
    @GeneratedValue
    @Column(columnDefinition = "uuid")
    UUID id;

    @Column(unique = true,nullable = false)
    String username;

    @Column(nullable = false)
    String password;

    @Column(unique = true,nullable = false)
    String email;

    @Column(nullable = false)
    String phone;

    @Column(nullable = false)
    String address;

    @Column(nullable = false)
    Date birthDate;

    @Column(nullable = false)
    boolean isEnabled=true;

    @ManyToMany(fetch = FetchType.EAGER)
    @JoinTable(
        name = "user_roles",
        joinColumns = @JoinColumn(name = "user_id"),
        inverseJoinColumns = @JoinColumn(name = "role_id")
    )
    Set<Role> roles = new HashSet<>();


}

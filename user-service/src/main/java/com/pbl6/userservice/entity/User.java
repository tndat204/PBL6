package com.pbl6.userservice.entity;

import jakarta.persistence.*;
import lombok.*;
import lombok.experimental.FieldDefaults;


import java.util.Date;
import java.util.HashSet;
import java.util.Set;
import java.util.UUID;
@Entity
@FieldDefaults(level = AccessLevel.PRIVATE)
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
@Table(name = "users")
public class User extends Base {
    @Id
    @GeneratedValue
    @Column(columnDefinition = "uuid")
    UUID id;

    @Column(unique = true,nullable = false)
    String username;

    @Column(nullable = false)
    String fullName;

    @Column
    String avatarUrl;

    @Column(nullable = false)
    String password;

    @Column(unique = true,nullable = false)
    String email;

    @Column
    String phone;

    @Column
    String address;

    @Column
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

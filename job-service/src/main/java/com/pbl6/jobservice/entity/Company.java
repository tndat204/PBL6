package com.pbl6.jobservice.entity;
import jakarta.persistence.*;
import lombok.AccessLevel;
import lombok.Data;
import lombok.experimental.FieldDefaults;

import java.util.Set;
import java.util.UUID;
@Entity
@FieldDefaults(level = AccessLevel.PRIVATE)
@Data
@Table(name = "companies")
public class Company extends Base {
    @Id
    @GeneratedValue
    @Column(columnDefinition = "uuid")
    UUID id;

    @Column(columnDefinition = "uuid",nullable = false)
    UUID ownerId;

    @Column(nullable = false)
    String name;

    @Column
    String taxCode;

    @Column
    String address;

    @Column
    String phone;

    @Column
    String email;

    @Column(nullable = false)
    boolean active=false;

    @Column
    String logoUrl;

    @Column
    String description;

    @OneToMany(mappedBy = "company", cascade = CascadeType.ALL, orphanRemoval = true)
    Set<CompanyUser> companyUsers;

}

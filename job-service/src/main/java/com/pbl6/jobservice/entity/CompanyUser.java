package com.pbl6.jobservice.entity;

import jakarta.persistence.*;
import lombok.*;
import lombok.experimental.FieldDefaults;

import java.time.LocalDate;
import java.util.UUID;

@Entity
@Table(name = "company_users")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
@FieldDefaults(level = AccessLevel.PRIVATE)
public class CompanyUser extends Base {

    @Id
    @GeneratedValue
    @Column(columnDefinition = "uuid")
    UUID id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "company_id", nullable = false)
    Company company;

    @Column(nullable = false, columnDefinition = "uuid")
    UUID userId;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 20)
    Role role;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 20)
    Status status;

    public enum Role {
        OWNER, RECRUITER, VIEWER
    }

    public enum Status {
        ACTIVE, INACTIVE
    }
}

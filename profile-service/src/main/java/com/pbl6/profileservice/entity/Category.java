package com.pbl6.profileservice.entity;

import jakarta.persistence.*;
import lombok.*;
import lombok.experimental.FieldDefaults;

import java.util.Set;
import java.util.UUID;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Entity
@FieldDefaults(level = AccessLevel.PRIVATE)
@Table(name = "categories")
public class Category extends Base {
    @Id
    @GeneratedValue
    @Column(columnDefinition = "uuid")
    UUID id;
    @Column(unique = true,nullable = false)
    String name;
    @OneToMany(mappedBy = "category", cascade = CascadeType.ALL, fetch = FetchType.LAZY)
    Set<Skill> skills;
}

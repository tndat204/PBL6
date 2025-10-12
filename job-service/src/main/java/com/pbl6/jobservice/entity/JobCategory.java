package com.pbl6.jobservice.entity;

import com.fasterxml.jackson.annotation.JsonBackReference;
import com.fasterxml.jackson.annotation.JsonIgnore;
import jakarta.persistence.*;
import lombok.*;
import lombok.experimental.FieldDefaults;

import java.util.UUID;

@Entity
@Table(name = "job_category", uniqueConstraints = {
        @UniqueConstraint(columnNames = {"job_id", "category_id"})
})
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
@FieldDefaults(level = AccessLevel.PRIVATE)
@ToString(exclude = "job") // Ngăn toString() gọi job
@EqualsAndHashCode(exclude = "job")
public class JobCategory extends Base{

    @Id
    @GeneratedValue
    @Column(columnDefinition = "uuid")
    UUID id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "job_id", nullable = false)
    @JsonBackReference
    Job job;

    @Column(nullable = false, columnDefinition = "uuid")
    UUID categoryId;
}



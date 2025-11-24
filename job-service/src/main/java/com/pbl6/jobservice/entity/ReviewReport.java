package com.pbl6.jobservice.entity;

import jakarta.persistence.*;
import lombok.*;
import lombok.experimental.FieldDefaults;

import java.util.UUID;

@Entity
@Table(name = "review_reports", uniqueConstraints = {
        @UniqueConstraint(columnNames = {"review_id", "reporter_id"})
})
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
@FieldDefaults(level = AccessLevel.PRIVATE)
public class ReviewReport extends Base { // Base chứa createdDate

    @Id
    @GeneratedValue
    @Column(columnDefinition = "uuid")
    UUID id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "review_id", nullable = false)
    CompanyReview companyReview;

    @Column(nullable = false, columnDefinition = "uuid")
    UUID reporterId;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    ReportReason reason;

    @Column(columnDefinition = "TEXT")
    String description; // Chi tiết thêm (VD: "Dòng thứ 2 chửi bậy...")

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    @Builder.Default
    ReportStatus status = ReportStatus.PENDING;

    public enum ReportStatus {
        PENDING,    // Đang chờ admin xử lý
        APPROVED,   // Admin chấp nhận báo cáo -> Xóa/Ẩn review
        REJECTED    // Admin từ chối báo cáo -> Review vẫn hiện
    }

    public enum ReportReason {
        // 1. Nhóm rác và lừa đảo
        SPAM,                   // Spam, nội dung rác, quảng cáo không liên quan
        SCAM_OR_FRAUD,          // Lừa đảo, dụ dỗ đầu tư, link độc hại

        // 2. Nhóm nội dung độc hại
        INAPPROPRIATE_CONTENT,  // Nội dung khiêu dâm, bạo lực, phản cảm
        HATE_SPEECH,            // Ngôn từ thù ghét (phân biệt chủng tộc, tôn giáo, giới tính...)
        HARASSMENT,             // Quấy rối, đe dọa hoặc bắt nạt cá nhân cụ thể

        // 3. Nhóm tính xác thực (Quan trọng cho Review Công ty)
        FAKE_INFORMATION,       // Thông tin sai lệch, không đúng sự thật
        CONFLICT_OF_INTEREST,   // Xung đột lợi ích (HR tự khen công ty, đối thủ chơi xấu)

        // 4. Nhóm quyền riêng tư & Bảo mật
        PRIVACY_VIOLATION,      // Lộ thông tin cá nhân (SĐT, địa chỉ nhà riêng của nhân viên khác)
        SHARING_CONFIDENTIAL_INFO, // Tiết lộ bí mật kinh doanh, công nghệ nội bộ, lương thưởng bảo mật

        // 5. Khác
        IRRELEVANT_CONTENT,     // Nội dung không liên quan đến trải nghiệm làm việc/công ty
        OTHER                   // Lý do khác
    }
}
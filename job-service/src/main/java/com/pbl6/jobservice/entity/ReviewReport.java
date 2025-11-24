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
        SPAM("Spam hoặc quảng cáo", "Nội dung rác, quảng cáo bán hàng, link không liên quan."),

        SCAM_OR_FRAUD("Lừa đảo hoặc gian lận", "Quảng cáo đa cấp, yêu cầu nộp tiền, hoặc lừa đảo."),

        INAPPROPRIATE_CONTENT("Nội dung không phù hợp", "Hình ảnh/ngôn từ khiêu dâm, bạo lực hoặc phản cảm."),

        HATE_SPEECH("Ngôn từ thù ghét", "Phân biệt chủng tộc, tôn giáo, giới tính, vùng miền."),

        HARASSMENT("Quấy rối hoặc công kích", "Tấn công, xúc phạm cá nhân cụ thể (đồng nghiệp, HR, sếp)."),

        FAKE_INFORMATION("Thông tin sai sự thật", "Bịa đặt thông tin sai lệch về công ty hoặc chính sách."),

        CONFLICT_OF_INTEREST("Xung đột lợi ích", "HR tự khen công ty (Seeding) hoặc đối thủ dìm hàng."),

        PRIVACY_VIOLATION("Xâm phạm quyền riêng tư", "Công khai SĐT, địa chỉ, Facebook cá nhân của người khác."),

        SHARING_CONFIDENTIAL_INFO("Lộ bí mật công ty", "Tiết lộ source code, tài liệu nội bộ, bảng lương bảo mật."),

        IRRELEVANT_CONTENT("Không liên quan", "Nội dung không liên quan đến trải nghiệm làm việc."),

        OTHER("Lý do khác", "Người dùng tự nhập mô tả chi tiết.");

        ReportReason(String label, String defaultDescription) {
        }
    }
}
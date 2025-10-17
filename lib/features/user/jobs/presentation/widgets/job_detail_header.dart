import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pbl6/core/constants/api_constants.dart';

import '../../domain/entities/job.dart';

class JobDetailHeader extends StatelessWidget {
  final Job job;
  const JobDetailHeader({super.key, required this.job});

  String _formatCurrency(int value) {
    final format = NumberFormat("#,##0", "vi_VN");
    return format.format(value);
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    // Logic xử lý imageUrl khớp với JobCard
    final baseUrl = ApiConstants.baseUrl;
    final imageUrl = job.logoUrl != null && job.logoUrl!.isNotEmpty
        ? (job.logoUrl!.startsWith('http')
            ? job.logoUrl!
            : '$baseUrl${job.logoUrl}')
        : null;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// --- Logo + Title (Đã khớp hoàn toàn với JobCard) ---
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Logo (52x52 và borderRadius 8)
              if (imageUrl != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    imageUrl,
                    width: 52, // Kích thước 52 khớp JobCard
                    height: 52,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.image_not_supported, size: 40),
                  ),
                )
              else
                Container(
                  width: 52, // Kích thước 52 khớp JobCard
                  height: 52,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.grey.shade200,
                  ),
                  child: const Icon(Icons.business_outlined,
                      color: Colors.grey, size: 30),
                ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Tiêu đề công việc
                    Text(
                      job.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    // Tên công ty (Đã được bổ sung và style khớp với JobCard)
                    if (job.companyName != null && job.companyName!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          job.companyName!,
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.grey.shade500,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // --- Các thẻ location + type ---
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildTag(Icons.location_on_outlined, job.location),
              _buildTag(
                  Icons.work_outline, job.jobType.name.replaceAll('_', ' ')),
            ],
          ),
          const SizedBox(height: 14),

          Divider(color: Colors.grey.shade200, height: 1, thickness: 1),
          const SizedBox(height: 14),

          // --- Mức lương (Đã đổi màu về Colors.green như JobCard) ---
          Row(
            children: [
              const Icon(Icons.payments_outlined,
                  size: 20, color: Colors.black87),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${_formatCurrency(job.salaryMin)} - ${_formatCurrency(job.salaryMax)} VND',
                  style: const TextStyle(
                    fontSize: 15,
                    color: Colors.green, // ✅ Đã đổi thành màu xanh lá cây
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // --- Ngày hết hạn ---
          Row(
            children: [
              Icon(Icons.calendar_today_outlined,
                  size: 16, color: Colors.grey.shade600),
              const SizedBox(width: 6),
              Text(
                'Hết hạn: ',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                ),
              ),
              Text(
                _formatDate(job.expiryDate),
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.black87, // Màu chữ tối
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Khôi phục style _buildTag khớp JobCard
  Widget _buildTag(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.grey.shade700),
          const SizedBox(width: 5),
          Text(
            text,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade800,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
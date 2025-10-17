import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart'; // 💡 Cần import GoRouter
import 'package:intl/intl.dart';
import 'package:pbl6/core/constants/api_constants.dart';

import '../../domain/entities/job.dart';

class JobCard extends StatelessWidget {
  final Job job;

  // ❌ Loại bỏ final VoidCallback? onTap;

  const JobCard({super.key, required this.job}); // ❌ Loại bỏ onTap khỏi constructor

  String _formatCurrency(int value) {
    final format = NumberFormat("#,##0", "vi_VN");
    return format.format(value);
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    // 💡 Logic xử lý imageUrl đã được khôi phục
    final baseUrl = ApiConstants.baseUrl; 
    final imageUrl = job.logoUrl != null && job.logoUrl!.isNotEmpty
        ? (job.logoUrl!.startsWith('http')
            ? job.logoUrl!
            : '$baseUrl${job.logoUrl}')
        : null;

    return InkWell(
      // 💡 Thêm logic go_router chuyển trang vào onTap
      onTap: () {
        context.push('/user/jobs/${job.id}');
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// --- Logo + Title ---
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 💡 Khôi phục logic hiển thị Image/Placeholder
                  if (imageUrl != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        imageUrl,
                        width: 52,
                        height: 52,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.image_not_supported, size: 40),
                      ),
                    )
                  else
                    Container(
                      width: 52,
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
                        // 💡 Tiêu đề công việc
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
                        // 💡 Tên công ty
                        if (job.companyName != null &&
                            job.companyName!.isNotEmpty)
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

              const SizedBox(height: 14),
              Divider(color: Colors.grey.shade200, height: 1, thickness: 1),
              const SizedBox(height: 12),

              /// --- Location & Type Pills ---
              // 💡 Khôi phục sử dụng Wrap
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: [
                  _buildTag(Icons.location_on_outlined, job.location),
                  _buildTag(Icons.work_outline,
                      job.jobType.name.replaceAll('_', ' ')),
                ],
              ),

              const SizedBox(height: 14),

              /// --- Salary ---
              Row(
                children: [
                  const Icon(Icons.payments_outlined,
                      size: 18, color: Colors.black87),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${_formatCurrency(job.salaryMin)} - ${_formatCurrency(job.salaryMax)} VND',
                      style: const TextStyle(
                        fontSize: 15,
                        color: Colors.green, // 💡 Màu xanh lá cây
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              /// --- Expiry Date ---
              Row(
                children: [
                  Icon(Icons.calendar_today_outlined,
                      size: 15, color: Colors.grey.shade600),
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
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade800,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// --- Widget pill tag (bo góc, có icon) ---
  // 💡 Khôi phục style cho _buildTag
  Widget _buildTag(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), // 💡 Padding ban đầu
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(20), // 💡 Corner radius ban đầu
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min, // 💡 mainAxisSize.min
        children: [
          Icon(icon, size: 14, color: Colors.grey.shade700),
          const SizedBox(width: 5), // 💡 SizedBox width ban đầu
          Text(
            text,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade800,
              fontWeight: FontWeight.w500, // 💡 FontWeight ban đầu
            ),
          ),
        ],
      ),
    );
  }
}
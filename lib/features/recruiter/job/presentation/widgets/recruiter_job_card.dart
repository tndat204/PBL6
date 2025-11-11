import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart'; // Import GoRouter
import 'package:intl/intl.dart';
import 'package:motion_toast/motion_toast.dart';
import 'package:pbl6/core/constants/api_constants.dart';
import 'package:pbl6/core/theme/app_pallete.dart';
import 'package:pbl6/features/recruiter/job/domain/usecases/delete_job_usecase.dart';
import 'package:pbl6/features/shared/job/domain/entities/job.dart';

class RecruiterJobCard extends StatelessWidget {
  final Job job;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  // Không cần thêm onJobTap vào constructor, vì logic tap được xử lý tại đây

  const RecruiterJobCard({
    super.key,
    required this.job,
    required this.onEdit,
    required this.onDelete,
  });

  String _formatCurrency(int value) {
    final format = NumberFormat("#,##0", "vi_VN");
    return format.format(value);
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showDeleteConfirmDialog(BuildContext context) {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.noHeader,
      animType: AnimType.scale,
      dialogBackgroundColor: Colors.white,
      borderSide: BorderSide(color: Colors.red.shade300, width: 1.2),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.warning_amber_rounded,
            color: Colors.orange.shade600,
            size: 50,
          ),
          const SizedBox(height: 12),
          const Text(
            'Xóa tin tuyển dụng',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Bạn có chắc chắn muốn xóa tin tuyển dụng "${job.title}" không?',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.grey[800]),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Nút Hủy
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey.shade300,
                  foregroundColor: Colors.black87,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Hủy bỏ'),
              ),
              // Nút Đồng ý (Xóa)
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade600,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () async {
                  try {
                    final deleteUseCase = GetIt.I<DeleteJobUseCase>();
                    await deleteUseCase(job.id);

                    // Callback để cập nhật UI danh sách
                    onDelete();

                    if (context.mounted) {
                      MotionToast.success(
                        description: const Text(
                          'Xóa tin tuyển dụng thành công',
                        ),
                        toastAlignment: Alignment.topLeft,
                      ).show(context);
                    }
                  } catch (e) {
                    if (context.mounted) {
                      MotionToast.error(
                        description: Text('Lỗi khi xóa: $e'),
                      ).show(context);
                    }
                  }
                  Navigator.of(context).pop();
                },
                child: const Text('Đồng ý'),
              ),
            ],
          ),
        ],
      ),
    ).show();
  }

  @override
  Widget build(BuildContext context) {
    final baseUrl = ApiConstants.baseUrl;
    final imageUrl = job.logoUrl != null && job.logoUrl!.isNotEmpty
        ? (job.logoUrl!.startsWith('http')
              ? job.logoUrl!
              : '$baseUrl${job.logoUrl}')
        : null;

    final statusColor = job.status == JobStatus.ACTIVE
        ? Colors.green
        : (job.status == JobStatus.INACTIVE ? Colors.orange : Colors.red);
    final statusText = job.status == JobStatus.ACTIVE
        ? 'Đang hiển thị'
        : (job.status == JobStatus.INACTIVE ? 'Đã ẩn' : 'Đã đóng');

    // Bọc toàn bộ nội dung trong InkWell
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Phần có thể chạm để xem chi tiết
          InkWell(
            borderRadius: BorderRadius.circular(12),
             onTap: () async {
             
              final result = await context.push(
                '/recruiter/jobs/detail/${job.id}',
                extra: onDelete, 
              );
           
            },
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// --- Logo + Title + Status ---
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Logo
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
                          child: const Icon(
                            Icons.business_outlined,
                            color: Colors.grey,
                            size: 30,
                          ),
                        ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
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
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.circle,
                                    size: 10,
                                    color: statusColor,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    statusText,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: statusColor,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
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
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      _buildTag(Icons.location_on_outlined, job.location),
                      _buildTag(
                        Icons.work_outline,
                        job.jobType.name.replaceAll('_', ' '),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  /// --- Salary ---
                  Row(
                    children: [
                      const Icon(
                        Icons.payments_outlined,
                        size: 18,
                        color: Colors.black87,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${_formatCurrency(job.salaryMin)} - ${_formatCurrency(job.salaryMax)} VND',
                          style: const TextStyle(
                            fontSize: 15,
                            color: Colors.green,
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
                      Icon(
                        Icons.calendar_today_outlined,
                        size: 15,
                        color: Colors.grey.shade600,
                      ),
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

          // Divider nằm ngoài InkWell để không bị hiệu ứng chạm
          Divider(color: Colors.grey.shade200, height: 1, thickness: 1),
          const SizedBox(height: 8),

          /// --- NÚT HÀNH ĐỘNG (Không chạm để xem chi tiết) ---
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Nút Xóa
                TextButton.icon(
                  onPressed: () => _showDeleteConfirmDialog(context),
                  icon: const Icon(
                    Icons.delete_outline_rounded,
                    color: Colors.redAccent,
                  ),
                  label: const Text(
                    'Xóa',
                    style: TextStyle(color: Colors.redAccent),
                  ),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Nút Sửa
                ElevatedButton.icon(
                  onPressed: onEdit,
                  icon: const Icon(
                    Icons.edit_outlined,
                    size: 18,
                    color: Colors.white,
                  ),
                  label: const Text(
                    'Sửa',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppPallete.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Widget _buildTag giữ nguyên
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

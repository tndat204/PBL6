// file: features/shared/profile/presentation/widgets/profile_cv_tab.dart

import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:motion_toast/motion_toast.dart';
import 'package:pbl6/core/theme/app_pallete.dart';
import 'package:pbl6/features/user/profile/domain/usecases/get_cv_url_usecase.dart';
import 'package:pbl6/features/user/profile/domain/usecases/upload_cv_usecase.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfileCVTab extends StatefulWidget {
  final String? cvFileUrl;
  final GetCVUrlUseCase getCVUrlUseCase;
  final UploadCVUseCase uploadCVUseCase;

  const ProfileCVTab({
    super.key,
    required this.cvFileUrl,
    required this.getCVUrlUseCase,
    required this.uploadCVUseCase,
  });

  @override
  State<ProfileCVTab> createState() => _ProfileCVTabState();
}

class _ProfileCVTabState extends State<ProfileCVTab> {
  String? _currentCvUrl;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _currentCvUrl = widget.cvFileUrl;
  }

  Future<void> _pickAndUploadCV() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result == null || result.files.single.path == null) return;

    final file = File(result.files.single.path!);
    // Kiểm tra phần mở rộng
    final fileName = result.files.single.name.toLowerCase();
    if (!fileName.endsWith('.pdf')) {
      MotionToast.error(
        description: const Text('Chỉ chấp nhận tệp định dạng PDF.'),
      ).show(context);
      return;
    }

    // Optional: Check file size (example: max 5MB)
    final fileSize = await file.length();
    if (fileSize > 5 * 1024 * 1024) {
      MotionToast.error(
        description: const Text('Kích thước file vượt quá 5MB.'),
      ).show(context);
      return;
    }

    setState(() => _isUploading = true);

    try {
      final uploadResult = await widget.uploadCVUseCase(
        UploadCVParams(cvFile: file),
      );

      uploadResult.fold(
        (failure) {
          MotionToast.error(
            description: Text('Tải lên thất bại: ${failure.message}'),
          ).show(context);
        },
        (newUrl) {
          setState(() => _currentCvUrl = newUrl);
          MotionToast.success(
            description: const Text('CV đã được tải lên thành công!'),
            toastAlignment: Alignment.topLeft,
            animationType: AnimationType.slideInFromLeft,
          ).show(context);
        },
      );
    } catch (e) {
      MotionToast.error(description: Text('Lỗi tải lên CV: $e')).show(context);
    } finally {
      if (mounted) {
        // Check if widget is still mounted
        setState(() => _isUploading = false);
      }
    }
  }

  // ✅ HÀM _viewCV ĐÃ ĐƯỢC CẢI THIỆN
  Future<void> _viewCV() async {
    if (_currentCvUrl == null || _currentCvUrl!.isEmpty) {
      MotionToast.warning(
        description: const Text('Chưa có CV nào được tải lên.'),
      ).show(context);
      return;
    }

    // Ghi log URL để kiểm tra
    print("Attempting to launch URL: $_currentCvUrl");

    // Chuyển đổi thành Uri và kiểm tra tính hợp lệ
    final Uri? url = Uri.tryParse(_currentCvUrl!);
    if (url == null) {
      MotionToast.error(
        description: Text('URL không hợp lệ: $_currentCvUrl'),
      ).show(context);
      return;
    }

    // Kiểm tra scheme (http/https)
    if (!url.isScheme('HTTP') && !url.isScheme('HTTPS')) {
      MotionToast.error(
        description: Text('URL scheme không được hỗ trợ: ${url.scheme}'),
      ).show(context);
      return;
    }

    try {
      // Kiểm tra xem có thể mở URL không
      bool canLaunch = await canLaunchUrl(url);
      print("canLaunchUrl returned: $canLaunch for $url"); // Thêm log

      if (canLaunch) {
        // Mở URL (thử dùng platformDefault)
        bool launched = await launchUrl(
          url,
          mode: LaunchMode.externalApplication, // Hoặc externalApplication
        );

        if (!launched) {
          MotionToast.error(
            description: Text(
              'Không thể khởi chạy liên kết (launchUrl failed).',
            ),
          ).show(context);
        }
      } else {
        MotionToast.error(
          description: Text(
            'Không thể mở liên kết (canLaunchUrl failed). Vui lòng kiểm tra cấu hình AndroidManifest/Info.plist.',
          ),
        ).show(context);
      }
    } catch (e) {
      // Bắt lỗi nếu launchUrl gây ra exception
      print("Error launching URL: $e");
      MotionToast.error(
        description: Text('Đã xảy ra lỗi khi mở CV: $e'),
      ).show(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Cập nhật lại _currentCvUrl nếu widget được rebuild với url mới
    // (ví dụ: sau khi update profile ở tab khác)
    if (widget.cvFileUrl != _currentCvUrl) {
      _currentCvUrl = widget.cvFileUrl;
    }

    return Padding(
      padding: const EdgeInsets.all(20.0), // Tăng padding
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center, // Căn giữa nội dung
        children: [
          const Text(
            'Quản lý CV', // Rút gọn tiêu đề
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),

          // --- Khung thông tin CV ---
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.description_outlined,
                  color: AppPallete.primaryColor,
                  size: 30,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    _currentCvUrl != null && _currentCvUrl!.isNotEmpty
                        ? 'CV đã được tải lên' // Text ngắn gọn hơn
                        : 'Chưa có CV nào',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: _currentCvUrl != null && _currentCvUrl!.isNotEmpty
                          ? Colors
                                .black87 // Màu chữ bình thường
                          : Colors.redAccent, // Màu đỏ nổi bật hơn
                    ),
                  ),
                ),
                // Nút xem chỉ hiển thị khi có CV
                if (_currentCvUrl != null && _currentCvUrl!.isNotEmpty)
                  IconButton(
                    icon: const Icon(
                      Icons.visibility_outlined,
                      color: Colors.blueAccent,
                    ),
                    tooltip: 'Xem CV', // Thêm tooltip
                    onPressed: _viewCV,
                  ),
              ],
            ),
          ),

          const SizedBox(height: 30), // Tăng khoảng cách
          // --- Tải lên CV mới ---
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isUploading ? null : _pickAndUploadCV,
              icon: _isUploading
                  ? Container(
                      // Container để cố định kích thước spinner
                      width: 20,
                      height: 20,
                      margin: const EdgeInsets.only(
                        right: 8,
                      ), // Khoảng cách với text
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.upload_file_rounded),
              label: Text(
                _isUploading ? 'Đang tải lên...' : 'Tải lên hoặc cập nhật CV',
                style: TextStyle(fontSize: 16),
              ),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white, // Màu chữ và icon
                backgroundColor: AppPallete.primaryColor,
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                ), // Tăng padding nút
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 3, // Thêm đổ bóng nhẹ
              ),
            ),
          ),
          const SizedBox(height: 12), // Tăng khoảng cách
          const Text(
            'Hỗ trợ: PDF (Tối đa 5MB)', // Text ngắn gọn
            style: TextStyle(fontSize: 13, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

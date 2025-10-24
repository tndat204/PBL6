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
      allowedExtensions: ['pdf', 'doc', 'docx'],
    );

    if (result == null || result.files.single.path == null) return;

    final file = File(result.files.single.path!);
    setState(() => _isUploading = true);

    try {
      final uploadResult = await widget.uploadCVUseCase(UploadCVParams(cvFile: file));

      uploadResult.fold(
        (failure) {
          MotionToast.error(description: Text('Tải lên thất bại: ${failure.message}')).show(context);
        },
        (newUrl) {
          setState(() => _currentCvUrl = newUrl);
          MotionToast.success(description: const Text('CV đã được tải lên thành công!')).show(context);
        },
      );
    } catch (e) {
      MotionToast.error(description: Text('Lỗi tải lên CV: $e')).show(context);
    } finally {
      setState(() => _isUploading = false);
    }
  }

  Future<void> _viewCV() async {
    if (_currentCvUrl == null || _currentCvUrl!.isEmpty) return;
    final url = Uri.parse(_currentCvUrl!);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      MotionToast.error(description: Text('Không thể mở liên kết: $_currentCvUrl')).show(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quản lý Hồ sơ & Tài liệu',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          
          // --- Xem CV hiện tại ---
          ListTile(
            leading: const Icon(Icons.file_present, color: AppPallete.primaryColor),
            title: Text(
              _currentCvUrl != null && _currentCvUrl!.isNotEmpty
                  ? 'CV hiện tại đã có'
                  : 'Chưa có CV được tải lên',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: _currentCvUrl != null && _currentCvUrl!.isNotEmpty ? Colors.black : Colors.red,
              ),
            ),
            trailing: _currentCvUrl != null && _currentCvUrl!.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.visibility),
                    onPressed: _viewCV,
                  )
                : null,
            onTap: _currentCvUrl != null && _currentCvUrl!.isNotEmpty ? _viewCV : null,
          ),
          const Divider(),
          
          const SizedBox(height: 20),

          // --- Tải lên CV mới ---
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isUploading ? null : _pickAndUploadCV,
              icon: _isUploading 
                  ? const SizedBox(
                      width: 18, 
                      height: 18, 
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)
                    ) 
                  : const Icon(Icons.upload_file),
              label: Text(_isUploading ? 'Đang tải lên...' : 'Tải lên CV mới'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppPallete.primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Chỉ hỗ trợ file PDF, DOC, DOCX. Kích thước tối đa 5MB.',
            style: TextStyle(fontSize: 12, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
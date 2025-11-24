import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:pbl6/core/theme/app_pallete.dart';
import 'package:pbl6/features/shared/auth/presentation/widgets/custom_text_field.dart';
import 'package:pbl6/features/shared/review/domain/entities/review.dart';

class CreateReviewDialog extends StatefulWidget {
  final Review? existingReview;

  const CreateReviewDialog({super.key, this.existingReview});

  @override
  State<CreateReviewDialog> createState() => _CreateReviewDialogState();
}

class _CreateReviewDialogState extends State<CreateReviewDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _commentController;
  double _rating = 0.0;
  List<File> _newImages = [];
  bool _isLoadingImages = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.existingReview?.title ?? '');
    _commentController = TextEditingController(text: widget.existingReview?.comment ?? '');
    _rating = widget.existingReview?.rating ?? 0.0;
  }

  Future<void> _pickImages() async {
    setState(() => _isLoadingImages = true);
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: true,
      );
      if (result != null) {
        setState(() {
          _newImages.addAll(result.paths.map((path) => File(path!)).toList());
        });
      }
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      setState(() => _isLoadingImages = false);
    }
  }

  void _submitReview() {
    if (_rating == 0.0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn số sao đánh giá'), backgroundColor: Colors.red),
      );
      return;
    }
    if (_formKey.currentState!.validate()) {
      Navigator.of(context).pop({
        'title': _titleController.text.trim(),
        'comment': _commentController.text.trim(),
        'rating': _rating,
        'images': _newImages,
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingReview != null;

    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(
        isEditing ? 'Chỉnh sửa đánh giá' : 'Viết bài đánh giá',
        textAlign: TextAlign.center,
        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
      ),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RatingBar.builder(
                initialRating: _rating,
                minRating: 1,
                direction: Axis.horizontal,
                allowHalfRating: true,
                itemCount: 5,
                itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                itemBuilder: (context, _) => const Icon(Icons.star, color: Colors.amber),
                onRatingUpdate: (rating) => setState(() => _rating = rating),
              ),
              const SizedBox(height: 20),
              CustomTextField(
                label: 'Tiêu đề (bắt buộc)',
                icon: Icons.title,
                obscureText: false,
                controller: _titleController,
                validator: (value) => (value == null || value.isEmpty) ? 'Vui lòng nhập tiêu đề' : null,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'Mô tả trải nghiệm',
                icon: Icons.comment_outlined,
                obscureText: false,
                controller: _commentController,
                maxLines: 4,
                minLines: 3,
                validator: (value) => null,
              ),
              const SizedBox(height: 16),

              // --- Hiển thị ảnh cũ (Network) nếu có ---
              if (isEditing && widget.existingReview!.imageUrls.isNotEmpty) ...[
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text("Ảnh hiện tại:", style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                ),
                const SizedBox(height: 4),
                
                // ĐÃ SỬA: Thêm width: double.maxFinite để tránh lỗi RenderIntrinsicWidth
                SizedBox(
                  height: 80,
                  width: double.maxFinite, 
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: widget.existingReview!.imageUrls.length,
                    itemBuilder: (context, index) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          widget.existingReview!.imageUrls[index],
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],

              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _pickImages,
                  icon: _isLoadingImages
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.camera_alt_outlined),
                  label: Text(_newImages.isEmpty ? 'Thêm ảnh mới' : '${_newImages.length} ảnh mới đã chọn'),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Hủy')),
        ElevatedButton(
          onPressed: _submitReview,
          style: ElevatedButton.styleFrom(backgroundColor: AppPallete.primaryColor, foregroundColor: Colors.white),
          child: Text(isEditing ? 'Cập nhật' : 'Đăng'),
        ),
      ],
    );
  }
}
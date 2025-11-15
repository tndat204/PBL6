import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:pbl6/core/theme/app_pallete.dart';
import 'package:pbl6/features/shared/auth/presentation/widgets/custom_text_field.dart';


class CreateReviewDialog extends StatefulWidget {
  const CreateReviewDialog({super.key});

  @override
  State<CreateReviewDialog> createState() => _CreateReviewDialogState();
}

class _CreateReviewDialogState extends State<CreateReviewDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _commentController = TextEditingController();
  double _rating = 0.0;
  List<File> _images = [];
  bool _isLoadingImages = false;

  Future<void> _pickImages() async {
    setState(() => _isLoadingImages = true);
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: true,
      );

      if (result != null) {
        setState(() {
          _images = result.paths.map((path) => File(path!)).toList();
        });
      }
    } catch (e) {
      // Xử lý lỗi
    } finally {
      setState(() => _isLoadingImages = false);
    }
  }

  void _submitReview() {
    if (_rating == 0.0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng chọn số sao đánh giá'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    if (_formKey.currentState!.validate()) {
      Navigator.of(context).pop({
        'title': _titleController.text.trim(),
        'comment': _commentController.text.trim(),
        'rating': _rating,
        'images': _images,
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
    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text(
        'Viết bài đánh giá',
        textAlign: TextAlign.center,
        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
      ),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 1. Chọn sao
              RatingBar.builder(
                initialRating: _rating,
                minRating: 1,
                direction: Axis.horizontal,
                allowHalfRating: true,
                itemCount: 5,
                itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                itemBuilder: (context, _) =>
                    const Icon(Icons.star, color: Colors.amber),
                onRatingUpdate: (rating) {
                  setState(() {
                    _rating = rating;
                  });
                },
              ),
              const SizedBox(height: 20),

              // 2. Tiêu đề
              CustomTextField(
                label: 'Tiêu đề (bắt buộc)',
                icon: Icons.title,
                obscureText: false,
                controller: _titleController,
                validator: (value) =>
                    (value == null || value.isEmpty) ? 'Vui lòng nhập tiêu đề' : null,
              ),
              const SizedBox(height: 16),

              // 3. Comment
              CustomTextField(
                label: 'Mô tả trải nghiệm',
                icon: Icons.comment_outlined,
                obscureText: false,
                controller: _commentController,
                maxLines: 4,
                minLines: 3,
                validator: (value) => null, // Comment có thể để trống
              ),
              const SizedBox(height: 16),

              // 4. Nút thêm ảnh
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _pickImages,
                  icon: _isLoadingImages
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.camera_alt_outlined),
                  label: Text(
                    _images.isEmpty
                        ? 'Thêm ảnh'
                        : '${_images.length} ảnh đã chọn',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Hủy'),
        ),
        ElevatedButton(
          onPressed: _submitReview,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppPallete.primaryColor,
            foregroundColor: Colors.white,
          ),
          child: const Text('Đăng'),
        ),
      ],
    );
  }
}

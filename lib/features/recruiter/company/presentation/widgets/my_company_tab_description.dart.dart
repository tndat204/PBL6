import 'package:flutter/material.dart';
import 'package:pbl6/features/shared/auth/presentation/widgets/custom_elevated_button.dart';
import 'package:pbl6/features/shared/auth/presentation/widgets/custom_text_field.dart';
import 'package:pbl6/features/shared/company/domain/entities/company.dart';

class MyCompanyTabDescription extends StatefulWidget {
  final Company company;
  final Future<void> Function(Company updatedCompany) onSave;

  const MyCompanyTabDescription({
    super.key,
    required this.company,
    required this.onSave,
  });

  @override
  State<MyCompanyTabDescription> createState() =>
      _MyCompanyTabDescriptionState();
}

class _MyCompanyTabDescriptionState extends State<MyCompanyTabDescription> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    _descriptionController =
        TextEditingController(text: widget.company.description ?? '');
  }

  void _onSavePressed() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Tạo đối tượng Company đã cập nhật
    final updatedCompany = widget.company.copyWith(
      description: _descriptionController.text.trim(),
    );

    // Gọi callback onSave của trang cha
    widget.onSave(updatedCompany);
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          CustomTextField(
            label: 'Mô tả công ty',
            icon: Icons.description_outlined,
            controller: _descriptionController,
            keyboardType: TextInputType.multiline,
            maxLines: 10, // Cho phép nhập nhiều dòng
            minLines: 5,
            obscureText: false, // <-- SỬA LỖI
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Vui lòng nhập mô tả công ty';
              }
              if (value.length < 50) {
                 return 'Mô tả phải có ít nhất 50 ký tự';
              }
              return null;
            },
          ),
          const SizedBox(height: 32),
          CustomElevatedButton(
            text: 'Lưu mô tả',
            onPressed: _onSavePressed,
          ),
        ],
      ),
    );
  }
}
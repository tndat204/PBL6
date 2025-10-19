import 'package:flutter/material.dart';
import 'package:pbl6/features/shared/auth/domain/entities/user_entity.dart';
import 'package:pbl6/features/shared/auth/presentation/widgets/custom_text_field.dart';

import '../../../auth/presentation/widgets/custom_elevated_button.dart';

class MyInfoTabPersonal extends StatefulWidget {
  final UserEntity user;
  final Future<void> Function(Map<String, dynamic>) onSave;

  const MyInfoTabPersonal({
    super.key,
    required this.user,
    required this.onSave,
  });

  @override
  State<MyInfoTabPersonal> createState() => _MyInfoTabPersonalState();
}

class _MyInfoTabPersonalState extends State<MyInfoTabPersonal> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.fullName);
    _phoneController = TextEditingController(text: widget.user.phone);
    _addressController = TextEditingController(text: widget.user.address);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          CustomTextField(
            label: 'Họ và tên',
            icon: Icons.person,
            obscureText: false,
            controller: _nameController,
          ),
          const SizedBox(height: 16),
          CustomTextField(
            label: 'Số điện thoại',
            icon: Icons.phone,
            obscureText: false,
            controller: _phoneController,
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 16),
          CustomTextField(
            label: 'Địa chỉ',
            icon: Icons.home,
            obscureText: false,
            controller: _addressController,
          ),
          const SizedBox(height: 32),

          // 🔹 Thay nút thường bằng CustomElevatedButton
          CustomElevatedButton(
            text: 'Cập nhật',
            onPressed: () async {
              if (!_formKey.currentState!.validate()) return;

              final data = {
                'fullName': _nameController.text,
                'phone': _phoneController.text,
                'address': _addressController.text,
              };

              await widget.onSave(data);
            },
          ),
        ],
      ),
    );
  }
}

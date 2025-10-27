import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:motion_toast/motion_toast.dart';
import 'package:pbl6/features/shared/auth/presentation/widgets/custom_elevated_button.dart';
import 'package:pbl6/features/shared/auth/presentation/widgets/custom_text_field.dart';
import 'package:pbl6/features/shared/user/domain/usecases/change_my_password_usecase.dart';

class MyInfoTabChangePassword extends StatefulWidget {
  const MyInfoTabChangePassword({super.key});

  @override
  State<MyInfoTabChangePassword> createState() =>
      _MyInfoTabChangePasswordState();
}

class _MyInfoTabChangePasswordState extends State<MyInfoTabChangePassword> {
  final _formKey = GlobalKey<FormState>();
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;

  late final ChangeMyPasswordUsecase _changeMyPasswordUseCase;

  @override
  void initState() {
    super.initState();
    _changeMyPasswordUseCase = GetIt.I<ChangeMyPasswordUsecase>();
  }

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleChangePassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await _changeMyPasswordUseCase(
        oldPassword: _oldPasswordController.text,
        newPassword: _newPasswordController.text,
      );

      MotionToast.success(
        title: const Text("Thành công",
            style: TextStyle(fontWeight: FontWeight.bold)),
        description: const Text('Đổi mật khẩu thành công!'),
        animationType: AnimationType.slideInFromLeft,
        toastAlignment: Alignment.topLeft,
      ).show(context);

      _formKey.currentState?.reset();
      _oldPasswordController.clear();
      _newPasswordController.clear();
      _confirmPasswordController.clear();
    } catch (e) {
      MotionToast.error(
        title: const Text("Lỗi",
            style: TextStyle(fontWeight: FontWeight.bold)),
        description: Text('Đã xảy ra lỗi: $e'),
        animationType: AnimationType.slideInFromLeft,
        toastAlignment: Alignment.topLeft,
      ).show(context);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CustomTextField(
              label: 'Mật khẩu cũ',
              icon: Icons.lock_outline,
              obscureText: true,
              controller: _oldPasswordController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Vui lòng nhập mật khẩu cũ';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            CustomTextField(
              label: 'Mật khẩu mới',
              icon: Icons.lock_person_outlined,
              obscureText: true,
              controller: _newPasswordController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Vui lòng nhập mật khẩu mới';
                }
                final regex = RegExp(
                    r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&.,#^()_+-]).{8,}$');
                if (!regex.hasMatch(value)) {
                  return 'Ít nhất 8 ký tự, gồm chữ hoa, thường, số, ký tự đặc biệt';
                }
                if (value == _oldPasswordController.text) {
                  return 'Mật khẩu mới phải khác mật khẩu cũ';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            CustomTextField(
              label: 'Xác nhận mật khẩu mới',
              icon: Icons.lock_person_outlined,
              obscureText: true,
              controller: _confirmPasswordController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Vui lòng xác nhận mật khẩu mới';
                }
                if (value != _newPasswordController.text) {
                  return 'Mật khẩu xác nhận không khớp';
                }
                return null;
              },
            ),
            const SizedBox(height: 32),
            CustomElevatedButton(
              text: 'Đổi mật khẩu',
              isLoading: _isLoading,
              onPressed: _isLoading ? null : _handleChangePassword,
            ),
          ],
        ),
      ),
    );
  }
}

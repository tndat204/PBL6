// file: features/shared/auth/presentation/signup_form.dart

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:motion_toast/motion_toast.dart';
import 'package:pbl6/core/theme/app_pallete.dart';
import 'package:pbl6/features/shared/auth/data/datasources/auth_remote_datasource.dart';
import 'package:pbl6/features/shared/auth/data/models/register_request_model.dart';
import 'package:pbl6/features/shared/auth/domain/usecases/register_usecase.dart';
import 'package:pbl6/features/shared/auth/presentation/widgets/custom_dropdown_field.dart';
import 'package:pbl6/features/shared/auth/presentation/widgets/custom_elevated_button.dart';
import 'package:pbl6/features/shared/auth/presentation/widgets/custom_text_field.dart';
import 'package:pbl6/features/shared/auth/presentation/widgets/terms_modal.dart';
import 'package:pbl6/routes/route_names.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignupForm extends StatefulWidget {
  const SignupForm({super.key});

  @override
  State<SignupForm> createState() => _SignupFormState();
}

class _SignupFormState extends State<SignupForm> {
  bool _agreeTerms = false;

  String? _selectedProvinceId; // 'id' của tỉnh, kiểu String
  String? _selectedWardName; // Tên phường/xã đã chọn
  String? _selectedProvinceName;

  List<Map<String, dynamic>> _provinces = [];
  List<Map<String, dynamic>> _wards = [];

  bool _loadingProvinces = true;
  bool _loadingWards = false;
  bool _isRegistering = false;

  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _birthDateController = TextEditingController();
  final _detailedAddressController = TextEditingController();

  DateTime? _selectedBirthDate;

  // 💡 Biến trạng thái lỗi tập trung
  String? _serverError;

  late final RegisterUseCase _registerUseCase;
  final AuthRemoteDataSource _authDataSource =
      GetIt.instance<AuthRemoteDataSource>();

  @override
  void initState() {
    super.initState();
    _registerUseCase = GetIt.I<RegisterUseCase>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchProvinces();
    });
  }

  Future<void> _fetchProvinces() async {
    try {
      // API service đã được cập nhật để dùng API mới
      final data = await _authDataSource.fetchProvinces();
      setState(() {
        _provinces = data;
        _loadingProvinces = false;
      });
    } catch (e) {
      setState(() {
        _loadingProvinces = false;
        _serverError = 'Lỗi tải tỉnh/thành phố: $e';
      });
    }
  }

  Future<void> _onProvinceChanged(String? id) async {
    if (id == null) return;

    // 1. Tìm tên tỉnh (provinceName) dựa trên ID (id)
    final selectedProvince = _provinces.firstWhere((p) => p['id'] == id);
    final String provinceName = selectedProvince['province']; // Lấy tên tỉnh

    setState(() {
      _selectedProvinceId = id;
      _selectedProvinceName = provinceName; // Cập nhật tên tỉnh
      _selectedWardName = null; // Reset phường/xã
      _wards = [];
      _loadingWards = true;
      _serverError = null;
    });

    try {
      // 2. Gọi API lấy phường/xã bằng TÊN TỈNH (provinceName)
      // Giả sử AuthRemoteDataSource.fetchWards đã được sửa để nhận String
      final wards = await _authDataSource.fetchWards(provinceName);
      setState(() {
        // Danh sách wards giờ chỉ có name (theo cấu trúc API mới)
        _wards = wards;
        _loadingWards = false;
      });
    } catch (e) {
      setState(() {
        _loadingWards = false;
        _serverError = 'Lỗi tải phường/xã: $e';
      });
    }
  }

  void _onWardChanged(String? name) {
    setState(() {
      _selectedWardName = name;
      _serverError = null;
    });
  }

  Future<void> _selectBirthDate() async {
    FocusScope.of(context).unfocus();
    final picked = await showDatePicker(
      context: Navigator.of(context, rootNavigator: true).context,
      initialDate: _selectedBirthDate ?? DateTime.now(),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      locale: const Locale('vi', 'VN'),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppPallete.primaryColor,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AppPallete.textColor,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedBirthDate = picked;
        _birthDateController.text = DateFormat('dd-MM-yyyy').format(picked);
      });
    }
  }

  // 💡 Hàm map lỗi từ API
  String _mapErrorToMessage(Object e) {
    final errorString = e.toString().toLowerCase();

    if (errorString.contains("đã tồn tại email") ||
        errorString.contains("email_existed")) {
      return "Email này đã được sử dụng.";
    }
    if (errorString.contains("đã tồn tại username") ||
        errorString.contains("username_existed")) {
      return "Tên đăng nhập này đã tồn tại.";
    }
    if (errorString.contains("đã tồn tại số điện thoại") ||
        errorString.contains("phone_existed")) {
      return "Số điện thoại này đã được sử dụng.";
    }
    if (errorString.contains("tên đăng nhập hoặc email hoặc sdt đã tồn tại") ||
        errorString.contains("user_existed")) {
      return "Email hoặc số điện thoại đã tồn tại.";
    }
    if (errorString.contains("your age must be at least") ||
        errorString.contains("invalid_dob")) {
      return "Bạn chưa đủ tuổi để đăng ký.";
    }
    if (errorString.contains("tên đăng nhập chưa hợp lệ") ||
        errorString.contains("username_invalid")) {
      return "Tên đăng nhập không hợp lệ (ví dụ: chứa khoảng trắng).";
    }

    // Lỗi chung
    return "Đăng ký thất bại. Vui lòng thử lại.";
  }

  // 💡 Hàm hiển thị modal điều khoản

  Future<void> _handleRegister() async {
    // 💡 Xóa lỗi cũ khi bắt đầu submit
    if (mounted) setState(() => _serverError = null);

    // Kiểm tra validation của Form
    if (!_formKey.currentState!.validate()) {
      return; // Dừng nếu các trường (CustomTextField) không hợp lệ
    }

    // 💡 Kiểm tra logic (checkbox, dropdowns) và gán lỗi
    if (!_agreeTerms) {
      setState(() => _serverError = "Bạn phải đồng ý với điều khoản sử dụng.");
      return;
    }
    if (_selectedProvinceId == null) {
      setState(() => _serverError = "Vui lòng chọn tỉnh/thành phố");
      return;
    }
    if (_wards.isNotEmpty && _selectedWardName == null) {
      setState(() => _serverError = "Vui lòng chọn phường/xã");
      return;
    }

    // 💡 Nếu tất cả kiểm tra đều qua
    setState(() => _isRegistering = true);
    try {
      final detailedPart = _detailedAddressController.text.trim();
      final wardPart =
          _selectedWardName != null && _selectedWardName!.isNotEmpty
          ? _selectedWardName!
          : '';
      final provincePart =
          _selectedProvinceName != null && _selectedProvinceName!.isNotEmpty
          ? _selectedProvinceName!
          : '';

      final addressParts = [
        detailedPart,
        wardPart,
        provincePart,
      ].where((s) => s.isNotEmpty).toList();
      final address = addressParts.join(', ');

      final request = RegisterRequest(
        // 💡 Dùng email làm username
        username: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        fullName: _nameController.text.trim(),
        address: address,
        taxCode: '',
        nameCompany: '',
        avatarUrl: '',
        birthDate: _selectedBirthDate ?? DateTime(2000, 1, 1),
      );

      await _registerUseCase(request);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('registered_email', _emailController.text.trim());

      // 💡 Vẫn dùng MotionToast cho THÀNH CÔNG
      MotionToast.success(
        title: const Text("Thành công"),
        description: const Text("Đăng kí thành công! Vui lòng đăng nhập!"),
        animationType: AnimationType.slideInFromLeft,
        toastDuration: const Duration(seconds: 2),
        toastAlignment: Alignment.topLeft,
      ).show(context);

      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          context.pushReplacementNamed(RouteNames.LOGIN);
        }
      });
    } catch (e) {
      // 💡 Gán lỗi đã map vào _serverError
      if (mounted) {
        setState(() {
          _serverError = _mapErrorToMessage(e);
        });
      }
    } finally {
      if (mounted) setState(() => _isRegistering = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _phoneController.dispose();
    _birthDateController.dispose();
    _detailedAddressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          CustomTextField(
            semanticsLabel: "nameField", // 💡
            label: 'Họ và Tên',
            icon: Icons.person_outline,
            obscureText: false,
            controller: _nameController,
            validator: (value) =>
                value!.isEmpty ? 'Vui lòng nhập họ và tên' : null,
          ),
          const SizedBox(height: 20),
          CustomTextField(
            semanticsLabel: "emailField", // 💡
            label: 'Email',
            icon: Icons.email_outlined,
            obscureText: false,
            controller: _emailController,
            validator: (value) {
              if (value!.isEmpty) return 'Vui lòng nhập email';
              if (!RegExp(
                r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
              ).hasMatch(value)) {
                return 'Email không hợp lệ';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: _selectBirthDate,
            child: AbsorbPointer(
              child: Semantics(
                label: 'birthDateField',
                child: ExcludeSemantics(
                  child: CustomTextField(
                    semanticsLabel: "birthDateField",
                    label: 'Ngày sinh',
                    icon: Icons.cake_outlined,
                    obscureText: false,
                    controller: _birthDateController,
                    validator: (value) =>
                        value!.isEmpty ? 'Vui lòng chọn ngày sinh' : null,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),
          CustomTextField(
            semanticsLabel: "passwordField", // 💡
            label: 'Mật khẩu',
            icon: Icons.lock_outline,
            obscureText: true,
            controller: _passwordController,
            validator: (value) {
              if (value!.isEmpty) return 'Vui lòng nhập mật khẩu';
              final regex = RegExp(
                r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&]).{8,}$',
              );
              if (!regex.hasMatch(value)) {
                return 'Mật khẩu ít nhất 8 ký tự, có chữ hoa, số và ký tự đặc biệt';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          CustomTextField(
            semanticsLabel: "confirmPasswordField", // 💡
            label: 'Nhập lại mật khẩu',
            icon: Icons.lock_outline,
            obscureText: true,
            controller: _confirmPasswordController,
            validator: (value) {
              if (value!.isEmpty) return 'Vui lòng nhập lại mật khẩu';
              if (value != _passwordController.text) {
                return 'Mật khẩu không khớp';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          CustomTextField(
            semanticsLabel: "phoneField", // 💡
            label: 'Số điện thoại',
            icon: Icons.phone_outlined,
            obscureText: false,
            keyboardType: TextInputType.phone,
            controller: _phoneController,
            validator: (value) {
              if (value!.isEmpty) return 'Vui lòng nhập số điện thoại';
              if (!RegExp(r'^\d{10,11}$').hasMatch(value)) {
                return 'Số điện thoại không hợp lệ';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),

          // --- Dropdown Tỉnh / Thành phố ---
          if (_loadingProvinces)
            const CircularProgressIndicator()
          else
            CustomDropdownField<String>(
              semanticsLabel: "provinceDropdown",
              label: 'Tỉnh/Thành phố',
              icon: Icons.location_on_outlined,
              value: _selectedProvinceId,
              hint: 'Chọn tỉnh/thành phố',
              items: _provinces.map((province) {
                final String id = province['id']; // Dùng 'id'
                final String name =
                    province['province']; // Dùng 'province' cho tên hiển thị
                return DropdownMenuItem<String>(value: id, child: Text(name));
              }).toList(),
              // 💡 ĐÃ SỬA: Kiểu dữ liệu tham số là String
              onChanged: (value) => _onProvinceChanged(value),
              validator: (value) =>
                  value == null ? 'Vui lòng chọn tỉnh/thành phố' : null,
            ),

          const SizedBox(height: 20),

          // --- Dropdown Phường / Xã ---
          if (_loadingWards)
            const CircularProgressIndicator()
          else
            CustomDropdownField<String>(
              semanticsLabel: "wardDropdown",
              label: 'Phường/Xã',
              icon: Icons.location_city_outlined,
              value: _selectedWardName,
              hint: _wards.isEmpty ? 'Không có phường/xã' : 'Chọn phường/xã',
              items: _wards.map((ward) {
                // Phường/xã chỉ có trường 'name' theo API mới
                final String name = ward['name'];
                // 💡 Giá trị (value) của Dropdown là TÊN phường/xã (String)
                return DropdownMenuItem<String>(value: name, child: Text(name));
              }).toList(),
              onChanged: _wards.isEmpty
                  ? null
                  // 💡 ĐÃ SỬA: Kiểu dữ liệu tham số là String
                  : (value) => _onWardChanged(value),
              validator: (value) => value == null && _wards.isNotEmpty
                  ? 'Vui lòng chọn phường/xã'
                  : null,
            ),

          const SizedBox(height: 20),
          CustomTextField(
            semanticsLabel: "detailedAddressField", // 💡
            label: 'Địa chỉ chi tiết (VD: số nhà, tên đường)',
            icon: Icons.place_outlined,
            obscureText: false,
            controller: _detailedAddressController,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Vui lòng nhập địa chỉ chi tiết';
              }

              if (value.trim().length > 50) {
                return 'Địa chỉ không được vượt quá 50 ký tự';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),

          // 💡 HÀNG ĐIỀU KHOẢN ĐÃ CẬP NHẬT
          Row(
            children: [
              Transform.scale(
                scale: 1.2,
                child: Semantics(
                  label: "agreeTermsCheckbox",
                  child: Checkbox(
                    value: _agreeTerms,
                    onChanged: (value) =>
                        setState(() => _agreeTerms = value ?? false),
                    activeColor: AppPallete.primaryColor,
                    checkColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: RichText(
                  text: TextSpan(
                    style: TextStyle(
                      fontFamily: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.fontFamily,
                      color: AppPallete.textColor,
                      fontWeight: FontWeight.w500,
                      fontSize: 15,
                    ),
                    children: [
                      const TextSpan(text: 'Tôi đồng ý với '),
                      TextSpan(
                        text: 'điều khoản sử dụng',
                        style: const TextStyle(
                          color: AppPallete.primaryColor,
                          fontWeight: FontWeight.bold, // 💡 In đậm
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            TermsModal.show(context);
                          },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // 💡 WIDGET HIỂN THỊ LỖI TẬP TRUNG
          if (_serverError != null) ...[
            Padding(
              padding: const EdgeInsets.only(top: 24.0, bottom: 8.0),
              child: Semantics(
                label: _serverError!,
                child: ExcludeSemantics(
                  child: Text(
                    _serverError!,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.red[700],
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
          ] else ...[
            const SizedBox(height: 32), // Khoảng trống mặc định
          ],

          // --- Nút Đăng ký ---
          _isRegistering
              ? const Center(child: CircularProgressIndicator())
              : Semantics(
                  label: "registerButton", // 💡
                  button: true,
                  child: ExcludeSemantics(
                    child: CustomElevatedButton(
                      text: 'Đăng ký',
                      onPressed: _handleRegister,
                    ),
                  ),
                ),
        ],
      ),
    );
  }
}

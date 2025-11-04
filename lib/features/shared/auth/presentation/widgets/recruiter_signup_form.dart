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

class RecruiterSignupForm extends StatefulWidget {
  const RecruiterSignupForm({super.key});

  @override
  State<RecruiterSignupForm> createState() => _RecruiterSignupFormState();
}

class _RecruiterSignupFormState extends State<RecruiterSignupForm> {
  bool _agreeTerms = false;

  String? _selectedProvinceId;
  String? _selectedWardName;
  String? _selectedProvinceName;

  List<Map<String, dynamic>> _provinces = [];
  List<Map<String, dynamic>> _wards = [];

  bool _loadingProvinces = true;
  bool _loadingWards = false;
  bool _isRegistering = false;
  String? _serverError;

  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _companyNameController = TextEditingController();
  final _taxCodeController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _birthDateController = TextEditingController();
  // 💡 Thêm Controller cho địa chỉ chi tiết
  final _detailedAddressController = TextEditingController();

  DateTime? _selectedBirthDate;

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
      final data = await _authDataSource.fetchProvinces();
      setState(() {
        _provinces = data;
        _loadingProvinces = false;
      });
    } catch (e) {
      setState(() => _loadingProvinces = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Lỗi tải tỉnh/thành phố: $e')));
    }
  }

  // 💡 LOGIC ĐÃ SỬA: Nhận ID tỉnh (String), dùng TÊN tỉnh để gọi API phường/xã
  Future<void> _onProvinceChanged(String? id) async {
    if (id == null) return;

    // 1. Tìm tên tỉnh (provinceName) dựa trên ID
    final selectedProvince = _provinces.firstWhere(
      (p) => p['id'] == id, // Dùng 'id' (String)
    );
    final String provinceName =
        selectedProvince['province']; // Lấy tên tỉnh từ 'province'

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
      final wards = await _authDataSource.fetchWards(
        provinceName,
      ); // 💡 Truyền TÊN tỉnh
      setState(() {
        _wards = wards;
        _loadingWards = false;
      });
    } catch (e) {
      setState(() {
        _loadingWards = false;
        // 💡 Gán lỗi vào _serverError thay vì SnackBar
        _serverError = 'Lỗi tải phường/xã: $e';
      });
    }
  }

  // 💡 LOGIC ĐÃ SỬA: Nhận TÊN phường/xã (String)
  void _onWardChanged(String? name) {
    setState(() {
      _selectedWardName = name;
      _serverError = null;
    });
  }

  Future<void> _selectBirthDate() async {
    FocusScope.of(context).unfocus();

    final picked = await showDatePicker(
      context: Navigator.of(
        context,
        rootNavigator: true,
      ).context, // ✅ dùng context gốc của MaterialApp
      initialDate: _selectedBirthDate ?? DateTime.now(),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      locale: const Locale('vi', 'VN'),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppPallete.primaryColor, // màu chủ đạo
              onPrimary: Colors.white, // màu chữ trong header
              surface: Colors.white, // màu nền hộp thoại
              onSurface: AppPallete.textColor, // màu chữ ngày
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedBirthDate = picked;
        // 👇 Hiển thị dd-MM-yyyy cho người dùng
        _birthDateController.text = DateFormat('dd-MM-yyyy').format(picked);
      });
    }
  }

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

    return "Đăng ký thất bại. Vui lòng thử lại.";
  }

  Future<void> _handleRegister() async {
    // 💡 Xóa lỗi cũ khi bắt đầu submit
    if (mounted) setState(() => _serverError = null);

    // Kiểm tra validation của Form
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // 💡 Kiểm tra logic (checkbox, dropdowns) và gán lỗi
    if (!_agreeTerms) {
      setState(() => _serverError = "Bạn phải đồng ý với điều khoản sử dụng.");
      return;
    }
    if (_selectedProvinceId == null) {
      setState(() => _serverError = "Vui lòng chọn Tỉnh/Thành phố.");
      return;
    }
    if (_wards.isNotEmpty && _selectedWardName == null) {
      setState(() => _serverError = "Vui lòng chọn Phường/Xã.");
      return;
    }

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
        username: _emailController.text,
        password: _passwordController.text,
        email: _emailController.text,
        phone: _phoneController.text,
        fullName: _fullNameController.text,
        address: address,
        taxCode: _taxCodeController.text,
        nameCompany: _companyNameController.text,
        avatarUrl: '',
        birthDate: _selectedBirthDate ?? DateTime(2000, 1, 1),
      );

      await _registerUseCase(request);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('registered_email', _emailController.text);

      MotionToast.success(
        title: const Text("Thành công"),
        description: const Text(
          "Đăng ký thành công, vui lòng đăng nhập để tiếp tục",
        ),
        animationType: AnimationType.slideInFromLeft,
        toastDuration: const Duration(seconds: 2),
        toastAlignment: Alignment.topLeft,
        borderRadius: 12,
        width: 320,
        height: 90,
      ).show(context);

      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          context.pushReplacementNamed(RouteNames.LOGIN);
        }
      });
    } catch (e) {
      // 💡 Gán lỗi đã map vào _serverError (Đồng bộ với SignupForm)
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
    _fullNameController.dispose();
    _companyNameController.dispose();
    _taxCodeController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _birthDateController.dispose();
    // 💡 Dispose controller địa chỉ chi tiết
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
            key: const ValueKey('email_field'),
            label: 'Nhập email',
            icon: Icons.email_outlined,
            obscureText: false,
            controller: _emailController,
            validator: (value) {
              if (value!.isEmpty) return 'Vui lòng nhập email';
              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value))
                return 'Email không hợp lệ';
              return null;
            },
          ),
          const SizedBox(height: 20),
          CustomTextField(
            key: const ValueKey('fullname_field'),
            label: 'Họ và Tên',
            icon: Icons.person_outline,
            obscureText: false,
            controller: _fullNameController,
            validator: (value) =>
                value!.isEmpty ? 'Vui lòng nhập họ và tên' : null,
          ),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: _selectBirthDate,
            child: AbsorbPointer(
              child: CustomTextField(
                key: const ValueKey('birth_date_field'),
                label: 'Ngày sinh',
                icon: Icons.cake_outlined,
                obscureText: false,
                controller: _birthDateController,
                validator: (value) {
                  if (value!.isEmpty) return 'Vui lòng chọn ngày sinh';
                  return null;
                },
              ),
            ),
          ),
          const SizedBox(height: 20),
          CustomTextField(
            key: const ValueKey('password_field'),
            label: 'Nhập mật khẩu',
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
            key: const ValueKey('confirm_password_field'),
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
            key: const ValueKey('company_name_field'),
            label: 'Tên công ty',
            icon: Icons.business_outlined,
            obscureText: false,
            controller: _companyNameController,
            validator: (value) =>
                value!.isEmpty ? 'Vui lòng nhập tên công ty' : null,
          ),
          const SizedBox(height: 20),
          CustomTextField(
            key: const ValueKey('tax_code_field'),
            label: 'Mã số thuế',
            icon: Icons.confirmation_number_outlined,
            obscureText: false,
            controller: _taxCodeController,
            validator: (value) =>
                value!.isEmpty ? 'Vui lòng nhập mã số thuế' : null,
          ),
          const SizedBox(height: 20),
          CustomTextField(
            key: const ValueKey('phone_field'),
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

          if (_loadingProvinces)
            const CircularProgressIndicator()
          else
            CustomDropdownField<String>(
              key: const ValueKey('province_dropdown'),
              label: 'Tỉnh/Thành phố',
              icon: Icons.location_on_outlined,
              value: _selectedProvinceId,
              hint: 'Chọn tỉnh/thành phố',
              items: _provinces.map((province) {
                final String id = province['id'];
                final String name = province['province'];
                return DropdownMenuItem<String>(value: id, child: Text(name));
              }).toList(),
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
              key: const ValueKey('ward_dropdown'),
              label: 'Phường/Xã',
              icon: Icons.location_city_outlined,
              value: _selectedWardName,
              hint: _wards.isEmpty ? 'Không có phường/xã' : 'Chọn phường/xã',
              items: _wards.map((ward) {
                final String name = ward['name'] as String;
                return DropdownMenuItem<String>(value: name, child: Text(name));
              }).toList(),
              onChanged: _wards.isEmpty
                  ? null
                  : (value) => _onWardChanged(value),
              validator: (value) => value == null && _wards.isNotEmpty
                  ? 'Vui lòng chọn phường/xã'
                  : null,
            ),
          const SizedBox(height: 20),

          // 💡 Địa chỉ chi tiết (Đồng bộ với SignupForm)
          CustomTextField(
            key: const ValueKey('detailed_address_field'),
            label: 'Địa chỉ chi tiết (VD: số nhà, tên đường)',
            icon: Icons.place_outlined,
            obscureText: false,
            controller: _detailedAddressController,
            validator: (value) =>
                value!.isEmpty ? 'Vui lòng nhập địa chỉ chi tiết' : null,
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Transform.scale(
                scale: 1.2,
                child: Checkbox(
                  key: const ValueKey('agree_terms_checkbox'),
                  value: _agreeTerms,
                  onChanged: (value) {
                    setState(() => _agreeTerms = value ?? false);
                  },
                  activeColor: AppPallete.primaryColor,
                  checkColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
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
                          fontWeight: FontWeight.bold,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            TermsModal.show(context); // 💡 Dùng TermsModal
                          },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          if (_serverError != null) ...[
            Padding(
              padding: const EdgeInsets.only(top: 24.0, bottom: 8.0),
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
          ] else ...[
            const SizedBox(height: 32),
          ],
         _isRegistering
              ? const Center(child: CircularProgressIndicator())
              : CustomElevatedButton(
                  key: const ValueKey('register_button'),
                  text: 'Đăng ký',
                  onPressed: _handleRegister,
                ),
        ],
      ),
    );
  }
}

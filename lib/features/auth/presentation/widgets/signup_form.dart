import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:motion_toast/motion_toast.dart';
import 'package:pbl6/core/theme/app_pallete.dart';
import 'package:pbl6/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:pbl6/features/auth/data/models/register_request_model.dart';
import 'package:pbl6/features/auth/domain/usecases/register_usecase.dart';
import 'package:pbl6/features/auth/presentation/pages/login_page.dart';
import 'package:pbl6/features/auth/presentation/widgets/custom_dropdown_field.dart';
import 'package:pbl6/features/auth/presentation/widgets/custom_elevated_button.dart';
import 'package:pbl6/features/auth/presentation/widgets/custom_text_field.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignupForm extends StatefulWidget {
  const SignupForm({super.key});

  @override
  State<SignupForm> createState() => _SignupFormState();
}

class _SignupFormState extends State<SignupForm> {
  bool _agreeTerms = false;

  int? _selectedProvinceCode;
  int? _selectedWardCode;
  String? _selectedProvinceName;
  String? _selectedWardName;

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
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Lỗi tải tỉnh/thành phố: $e')));
    }
  }

  Future<void> _onProvinceChanged(int? code) async {
    if (code == null) return;
    setState(() {
      _selectedProvinceCode = code;
      _selectedWardCode = null;
      _selectedWardName = null;
      _wards = [];
      _loadingWards = true;
      _selectedProvinceName =
          _provinces.firstWhere((p) => p['code'] == code)['name'];
    });

    try {
      final wards = await _authDataSource.fetchWards(code);
      setState(() {
        _wards = wards;
        _loadingWards = false;
      });
    } catch (e) {
      setState(() => _loadingWards = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Lỗi tải phường/xã: $e')));
    }
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

  Future<void> _handleRegister() async {
    if (_formKey.currentState!.validate() && _agreeTerms) {
      setState(() => _isRegistering = true);
      try {
        final address =
            '${_selectedProvinceName ?? ''}, ${_selectedWardName ?? ''}';

        final request = RegisterRequest(
          username: _emailController.text,
          password: _passwordController.text,
          email: _emailController.text,
          phone: _phoneController.text,
          fullName: _nameController.text,
          address: address,
          taxCode: '', // để trống
          nameCompany: '', // để trống
          avatarUrl: '', // để trống
          birthDate: _selectedBirthDate ?? DateTime(2000, 1, 1),
        );

        await _registerUseCase(request);

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('registered_email', _emailController.text);

        MotionToast(
          icon: Icons.check_circle,
          primaryColor: AppPallete.lightGradient,
          secondaryColor: const Color.fromARGB(255, 74, 98, 138),
          title: const Text(
            "Thành công",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
          ),
          description: const Text(
            "Đăng ký thành công, vui lòng đăng nhập để tiếp tục",
            style: TextStyle(color: AppPallete.backgroundColor),
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
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const LoginPage()),
            );
          }
        });
      } catch (e) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Đăng ký thất bại: $e')));
      } finally {
        if (mounted) setState(() => _isRegistering = false);
      }
    } else if (!_agreeTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bạn phải đồng ý điều khoản')),
      );
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          CustomTextField(
            label: 'Họ và Tên',
            icon: Icons.person_outline,
            obscureText: false,
            controller: _nameController,
            validator: (value) =>
                value!.isEmpty ? 'Vui lòng nhập họ và tên' : null,
          ),
          const SizedBox(height: 20),
          CustomTextField(
            label: 'Email',
            icon: Icons.email_outlined,
            obscureText: false,
            controller: _emailController,
            validator: (value) {
              if (value!.isEmpty) return 'Vui lòng nhập email';
              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                  .hasMatch(value)) {
                return 'Email không hợp lệ';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: _selectBirthDate,
            child: AbsorbPointer(
              child: CustomTextField(
                label: 'Ngày sinh',
                icon: Icons.cake_outlined,
                obscureText: false,
                controller: _birthDateController,
                validator: (value) =>
                    value!.isEmpty ? 'Vui lòng chọn ngày sinh' : null,
              ),
            ),
          ),
          const SizedBox(height: 20),
          CustomTextField(
            label: 'Mật khẩu',
            icon: Icons.lock_outline,
            obscureText: true,
            controller: _passwordController,
            validator: (value) {
              if (value!.isEmpty) return 'Vui lòng nhập mật khẩu';
              if (value.length < 8) return 'Mật khẩu ít nhất 8 ký tự';
              return null;
            },
          ),
          const SizedBox(height: 20),
          CustomTextField(
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
            CustomDropdownField<int>(
              label: 'Tỉnh/Thành phố',
              icon: Icons.location_on_outlined,
              value: _selectedProvinceCode,
              hint: 'Chọn tỉnh/thành phố',
              items: _provinces.map((province) {
                final int code = province['code'];
                final String name = province['name'];
                return DropdownMenuItem<int>(value: code, child: Text(name));
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
            CustomDropdownField<int>(
              label: 'Phường/Xã',
              icon: Icons.location_city_outlined,
              value: _selectedWardCode,
              hint: _wards.isEmpty ? 'Không có phường/xã' : 'Chọn phường/xã',
              items: _wards.map((ward) {
                final int code = ward['code'];
                final String name = ward['name'];
                return DropdownMenuItem<int>(value: code, child: Text(name));
              }).toList(),
              onChanged: _wards.isEmpty
                  ? null
                  : (value) {
                      setState(() {
                        _selectedWardCode = value;
                        _selectedWardName = _wards
                            .firstWhere((w) => w['code'] == value)['name'];
                      });
                    },
              validator: (value) => value == null && _wards.isNotEmpty
                  ? 'Vui lòng chọn phường/xã'
                  : null,
            ),

          const SizedBox(height: 20),
          Row(
            children: [
              Transform.scale(
                scale: 1.2,
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
              const SizedBox(width: 8),
              Text(
                'Tôi đồng ý với điều khoản',
                style: TextStyle(
                  color: AppPallete.textColor,
                  fontWeight: FontWeight.w500,
                  fontSize: 15,
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          _isRegistering
              ? const Center(child: CircularProgressIndicator())
              : CustomElevatedButton(
                  text: 'Đăng ký',
                  onPressed: _handleRegister,
                ),
        ],
      ),
    );
  }
}

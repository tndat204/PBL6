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
import 'package:pbl6/routes/route_names.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RecruiterSignupForm extends StatefulWidget {
  const RecruiterSignupForm({super.key});

  @override
  State<RecruiterSignupForm> createState() => _RecruiterSignupFormState();
}

class _RecruiterSignupFormState extends State<RecruiterSignupForm> {
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

  Future<void> _onProvinceChanged(int? code) async {
    if (code == null) return;
    setState(() {
      _selectedProvinceCode = code;
      _selectedWardCode = null;
      _selectedWardName = null;
      _wards = [];
      _loadingWards = true;
      _selectedProvinceName = _provinces.firstWhere(
        (p) => p['code'] == code,
      )['name'];
    });

    try {
      final wards = await _authDataSource.fetchWards(code);
      setState(() {
        _wards = wards;
        _loadingWards = false;
      });
    } catch (e) {
      setState(() => _loadingWards = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Lỗi tải phường/xã: $e')));
    }
  }

  // 💡 Thêm hàm này để cập nhật tên Phường/Xã khi chọn
  void _onWardChanged(int? code) {
    setState(() {
      _selectedWardCode = code;
      _selectedWardName = code == null
          ? null
          : _wards.firstWhere((w) => w['code'] == code)['name'];
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

  Future<void> _handleRegister() async {
    // 💡 Thêm kiểm tra validation cho Dropdown Tỉnh/Thành phố và Phường/Xã
    if (_formKey.currentState!.validate() &&
        _agreeTerms &&
        _selectedProvinceCode != null &&
        (_wards.isEmpty || _selectedWardCode != null)) {
      setState(() => _isRegistering = true);
      try {
        // 💡 Logic kết hợp địa chỉ: Địa chỉ chi tiết, Phường/Xã, Tỉnh/Thành phố
        final detailedPart = _detailedAddressController.text.trim();
        final wardPart =
            _selectedWardName != null && _selectedWardName!.isNotEmpty
            ? _selectedWardName!
            : '';
        final provincePart =
            _selectedProvinceName != null && _selectedProvinceName!.isNotEmpty
            ? _selectedProvinceName!
            : '';

        // Nối các phần lại, chỉ thêm dấu phẩy nếu có phần tử đứng trước
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
          address: address, // 💡 Sử dụng địa chỉ đã kết hợp
          taxCode: _taxCodeController.text,
          nameCompany: _companyNameController.text,
          avatarUrl: '',
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
            context.pushReplacementNamed(RouteNames.LOGIN);
          }
        });
      } catch (e) {
        MotionToast.error(
          title: const Text(
            "Đăng ký thất bại",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          description: Text(
            "Đã xảy ra lỗi: ${e.toString()}", // Bao quát lỗi backend trả về
            maxLines: 2,
          ),
          animationType: AnimationType.slideInFromLeft, // ✅
          toastDuration: const Duration(seconds: 3),
          toastAlignment: Alignment.topLeft, // ✅
          borderRadius: 12,
          width: 320,
          height: 90,
        ).show(context);
      } finally {
        if (mounted) setState(() => _isRegistering = false);
      }
    } else if (!_agreeTerms) {
      MotionToast.warning(
        title: const Text(
          "Lỗi điều khoản",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        description: const Text("Bạn phải đồng ý với điều khoản sử dụng."),
        animationType: AnimationType.slideInFromLeft, // ✅
        toastDuration: const Duration(seconds: 2),
        toastAlignment: Alignment.topLeft, // ✅
        borderRadius: 12,
        width: 320,
        height: 90,
      ).show(context);
    } else if (_selectedProvinceCode == null) {
      MotionToast.warning(
        title: const Text(
          "Lỗi địa chỉ",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        description: const Text("Vui lòng chọn Tỉnh/Thành phố."),
        animationType: AnimationType.slideInFromLeft, // ✅
        toastDuration: const Duration(seconds: 2),
        toastAlignment: Alignment.topLeft, // ✅
        borderRadius: 12,
        width: 320,
        height: 90,
      ).show(context);
    } else if (_wards.isNotEmpty && _selectedWardCode == null) {
      MotionToast.warning(
        title: const Text(
          "Lỗi địa chỉ",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        description: const Text("Vui lòng chọn Phường/Xã."),
        animationType: AnimationType.slideInFromLeft, // ✅
        toastDuration: const Duration(seconds: 2),
        toastAlignment: Alignment.topLeft, // ✅
        borderRadius: 12,
        width: 320,
        height: 90,
      ).show(context);
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
          // 💡 Thêm trường địa chỉ chi tiết
         
          if (_loadingProvinces)
            const CircularProgressIndicator()
          else
            CustomDropdownField<int>(
              key: const ValueKey('province_dropdown'),
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
          if (_loadingWards)
            const CircularProgressIndicator()
          else
            CustomDropdownField<int>(
              key: const ValueKey('ward_dropdown'),
              label: 'Phường/Xã',
              icon: Icons.location_city_outlined,
              value: _selectedWardCode,
              hint: _wards.isEmpty ? 'Không có phường/xã' : 'Chọn phường/xã',
              items: _wards.map((ward) {
                final int code = ward['code'] as int;
                final String name = ward['name'] as String;
                return DropdownMenuItem<int>(value: code, child: Text(name));
              }).toList(),
              // 💡 Chỉnh sửa onChanged để gọi _onWardChanged
              onChanged: _wards.isEmpty
                  ? null
                  : (value) => _onWardChanged(value),
              validator: (value) => value == null && _wards.isNotEmpty
                  ? 'Vui lòng chọn phường/xã'
                  : null,
            ),

          const SizedBox(height: 20),
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
                key: const ValueKey('register_button'),
                  text: 'Đăng ký',
                  onPressed: _handleRegister,
                ),
        ],
      ),
    );
  }
}

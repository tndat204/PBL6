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

  String? _selectedProvinceId; 
  String? _selectedWardName; 
  String? _selectedProvinceName;

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

  // 💡 LOGIC ĐÃ SỬA: Nhận ID tỉnh (String), dùng TÊN tỉnh để gọi API phường/xã
  Future<void> _onProvinceChanged(String? id) async {
    if (id == null) return;
    
    // 1. Tìm tên tỉnh (provinceName) dựa trên ID
    final selectedProvince = _provinces.firstWhere(
      (p) => p['id'] == id, // Dùng 'id' (String)
    );
    final String provinceName = selectedProvince['province']; // Lấy tên tỉnh từ 'province'

    setState(() {
      _selectedProvinceId = id;
      _selectedProvinceName = provinceName; // Cập nhật tên tỉnh
      _selectedWardName = null; // Reset phường/xã
      _wards = [];
      _loadingWards = true;
    });

    try {
      // 2. Gọi API lấy phường/xã bằng TÊN TỈNH (provinceName)
      final wards = await _authDataSource.fetchWards(provinceName); // 💡 Truyền TÊN tỉnh
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

  // 💡 LOGIC ĐÃ SỬA: Nhận TÊN phường/xã (String)
  void _onWardChanged(String? name) {
    setState(() {
      _selectedWardName = name;
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
    // 💡 SỬA: Kiểm tra _selectedProvinceId và _selectedWardName (đều là String)
    if (_formKey.currentState!.validate() &&
        _agreeTerms &&
        _selectedProvinceId != null &&
        (_wards.isEmpty || _selectedWardName != null)) {
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
          address: address, // Sử dụng địa chỉ đã kết hợp
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
            "Đã xảy ra lỗi: ${e.toString()}",
            maxLines: 2,
          ),
          animationType: AnimationType.slideInFromLeft,
          toastDuration: const Duration(seconds: 3),
          toastAlignment: Alignment.topLeft,
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
        animationType: AnimationType.slideInFromLeft,
        toastDuration: const Duration(seconds: 2),
        toastAlignment: Alignment.topLeft,
        borderRadius: 12,
        width: 320,
        height: 90,
      ).show(context);
    } else if (_selectedProvinceId == null) { // 💡 Kiểm tra ID tỉnh (String)
      MotionToast.warning(
        title: const Text(
          "Lỗi địa chỉ",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        description: const Text("Vui lòng chọn Tỉnh/Thành phố."),
        animationType: AnimationType.slideInFromLeft,
        toastDuration: const Duration(seconds: 2),
        toastAlignment: Alignment.topLeft,
        borderRadius: 12,
        width: 320,
        height: 90,
      ).show(context);
    } else if (_wards.isNotEmpty && _selectedWardName == null) { // 💡 Kiểm tra TÊN phường/xã (String)
      MotionToast.warning(
        title: const Text(
          "Lỗi địa chỉ",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        description: const Text("Vui lòng chọn Phường/Xã."),
        animationType: AnimationType.slideInFromLeft,
        toastDuration: const Duration(seconds: 2),
        toastAlignment: Alignment.topLeft,
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
            // 💡 ĐÃ SỬA: Dùng String cho value và ID
            CustomDropdownField<String>( 
              key: const ValueKey('province_dropdown'),
              label: 'Tỉnh/Thành phố',
              icon: Icons.location_on_outlined,
              value: _selectedProvinceId,
              hint: 'Chọn tỉnh/thành phố',
              items: _provinces.map((province) {
                final String id = province['id']; // Dùng 'id'
                final String name = province['province']; // Dùng 'province' cho tên hiển thị
                return DropdownMenuItem<String>(value: id, child: Text(name));
              }).toList(),
              onChanged: (value) => _onProvinceChanged(value), // 💡 Tham số là String?
              validator: (value) =>
                  value == null ? 'Vui lòng chọn tỉnh/thành phố' : null,
            ),
          const SizedBox(height: 20),
         if (_loadingWards)
            const CircularProgressIndicator()
          else
            // 💡 ĐÃ SỬA: Dùng String cho value và TÊN phường/xã
            CustomDropdownField<String>( 
              key: const ValueKey('ward_dropdown'),
              label: 'Phường/Xã',
              icon: Icons.location_city_outlined,
              value: _selectedWardName, // Dùng tên đã chọn
              hint: _wards.isEmpty ? 'Không có phường/xã' : 'Chọn phường/xã',
              items: _wards.map((ward) {
                // Phường/xã chỉ có trường 'name' theo API mới
                final String name = ward['name'] as String; 
                // 💡 Giá trị (value) của Dropdown là TÊN phường/xã (String)
                return DropdownMenuItem<String>(value: name, child: Text(name));
              }).toList(),
              // 💡 Chỉnh sửa onChanged để gọi _onWardChanged (nhận String)
              onChanged: _wards.isEmpty
                  ? null
                  : (value) => _onWardChanged(value), 
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

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:pbl6/core/theme/app_pallete.dart';
import 'package:pbl6/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:pbl6/features/auth/presentation/widgets/custom_elevated_button.dart';
import 'package:pbl6/features/auth/presentation/widgets/custom_text_field.dart';

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

  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _companyNameController = TextEditingController();
  final _taxCodeController = TextEditingController(); // 👉 thêm controller
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final AuthRemoteDataSource _authDataSource =
      GetIt.instance<AuthRemoteDataSource>();

  @override
  void initState() {
    super.initState();
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

  @override
  void dispose() {
    _fullNameController.dispose();
    _companyNameController.dispose();
    _taxCodeController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          CustomTextField(
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
            label: 'Họ và Tên',
            icon: Icons.person_outline,
            obscureText: false,
            controller: _fullNameController,
            validator: (value) =>
                value!.isEmpty ? 'Vui lòng nhập họ và tên' : null,
          ),
          const SizedBox(height: 20),
          CustomTextField(
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
            label: 'Tên công ty',
            icon: Icons.business_outlined,
            obscureText: false,
            controller: _companyNameController,
            validator: (value) =>
                value!.isEmpty ? 'Vui lòng nhập tên công ty' : null,
          ),
          const SizedBox(height: 20),
          CustomTextField(
            label: 'Mã số thuế',
            icon: Icons.confirmation_number_outlined,
            obscureText: false,
            controller: _taxCodeController,
            validator: (value) =>
                value!.isEmpty ? 'Vui lòng nhập mã số thuế' : null,
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
          if (_loadingProvinces)
            const CircularProgressIndicator()
          else
            DropdownButtonFormField<int>(
              isExpanded: true,
              value: _selectedProvinceCode,
              hint: const Text('Chọn tỉnh/thành phố'),
              dropdownColor: AppPallete.inputBackgroundColor,
              items: _provinces.map((province) {
                final int code = province['code'] as int;
                final String name = province['name'] as String;
                return DropdownMenuItem<int>(
                  value: code,
                  child: Text(
                    name,
                    style: TextStyle(color: AppPallete.textColor),
                  ),
                );
              }).toList(),
              onChanged: (value) => _onProvinceChanged(value),
              decoration: InputDecoration(
                prefixIcon: Icon(
                  Icons.location_on_outlined,
                  color: AppPallete.mutedTextColor,
                  size: 22,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: AppPallete.borderColor,
                    width: 1.5,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: AppPallete.borderColor,
                    width: 1.5,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: AppPallete.primaryColor,
                    width: 2,
                  ),
                ),
                filled: true,
                fillColor: AppPallete.inputBackgroundColor,
              ),
              validator: (value) =>
                  value == null ? 'Vui lòng chọn tỉnh/thành phố' : null,
            ),
          const SizedBox(height: 20),
          if (_loadingWards)
            const CircularProgressIndicator()
          else
            DropdownButtonFormField<int>(
              isExpanded: true,
              value: _selectedWardCode,
              hint: Text(
                _wards.isEmpty ? 'Không có phường/xã' : 'Chọn phường/xã',
              ),
              dropdownColor: AppPallete.inputBackgroundColor,
              items: _wards.map((ward) {
                final int code = ward['code'] as int;
                final String name = ward['name'] as String;
                return DropdownMenuItem<int>(
                  value: code,
                  child: Text(
                    name,
                    style: TextStyle(color: AppPallete.textColor),
                  ),
                );
              }).toList(),
              onChanged: _wards.isEmpty
                  ? null
                  : (value) {
                      setState(() {
                        _selectedWardCode = value;
                        _selectedWardName = _wards.firstWhere(
                          (w) => w['code'] == value,
                        )['name'];
                      });
                    },
              decoration: InputDecoration(
                prefixIcon: const Icon(
                  Icons.location_city_outlined,
                  color: AppPallete.mutedTextColor,
                  size: 22,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: AppPallete.borderColor,
                    width: 1.5,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: AppPallete.borderColor,
                    width: 1.5,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: AppPallete.primaryColor,
                    width: 2,
                  ),
                ),
                filled: true,
                fillColor: AppPallete.inputBackgroundColor,
              ),
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
                  onChanged: (value) {
                    setState(() {
                      _agreeTerms = value ?? false;
                    });
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
          CustomElevatedButton(
            text: 'Đăng ký',
            onPressed: () {
              if (_formKey.currentState!.validate() && _agreeTerms) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Form hợp lệ, chuẩn bị gửi API'),
                  ),
                );
              } else if (!_agreeTerms) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Bạn phải đồng ý điều khoản')),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}

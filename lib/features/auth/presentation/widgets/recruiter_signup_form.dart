import 'package:flutter/material.dart';
import 'package:pbl6/core/theme/app_pallete.dart';
import 'package:pbl6/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:pbl6/features/auth/presentation/widgets/custom_text_field.dart';
import 'package:pbl6/features/auth/presentation/widgets/custom_elevated_button.dart';
import 'package:provider/provider.dart';

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
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authDataSource = Provider.of<AuthRemoteDataSource>(
        context,
        listen: false,
      );
      _fetchProvinces(authDataSource);
    });
  }

  Future<void> _fetchProvinces(AuthRemoteDataSource ds) async {
    try {
      final data = await ds.fetchProvinces();
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

  Future<void> _onProvinceChanged(int? code, AuthRemoteDataSource ds) async {
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
      final wards = await ds.fetchWards(code);
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
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authDataSource = Provider.of<AuthRemoteDataSource>(
      context,
      listen: false,
    );

    return Form(
      key: _formKey,
      child: Column(
        children: [
          // Email
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

          // Họ và tên
          CustomTextField(
            label: 'Họ và Tên',
            icon: Icons.person_outline,
            obscureText: false,
            controller: _fullNameController,
            validator: (value) =>
                value!.isEmpty ? 'Vui lòng nhập họ và tên' : null,
          ),
          const SizedBox(height: 20),

          // Mật khẩu
          CustomTextField(
            label: 'Nhập mật khẩu',
            icon: Icons.lock_outline,
            obscureText: true,
            controller: _passwordController,
            validator: (value) {
              if (value!.isEmpty) return 'Vui lòng nhập mật khẩu';
              if (value.length < 8) return 'Mật khẩu phải có ít nhất 8 ký tự';
              return null;
            },
          ),
          const SizedBox(height: 20),

          // Xác nhận mật khẩu
          CustomTextField(
            label: 'Nhập lại mật khẩu',
            icon: Icons.lock_outline,
            obscureText: true,
            controller: _confirmPasswordController,
            validator: (value) {
              if (value!.isEmpty) return 'Vui lòng nhập lại mật khẩu';
              if (value != _passwordController.text)
                return 'Mật khẩu không khớp';
              return null;
            },
          ),
          const SizedBox(height: 20),

          // Tên công ty
          CustomTextField(
            label: 'Tên công ty',
            icon: Icons.business_outlined,
            obscureText: false,
            controller: _companyNameController,
            validator: (value) =>
                value!.isEmpty ? 'Vui lòng nhập tên công ty' : null,
          ),
          const SizedBox(height: 20),

          // Số điện thoại
          CustomTextField(
            label: 'Số điện thoại',
            icon: Icons.phone_outlined,
            obscureText: false,
            keyboardType: TextInputType.phone,
            controller: _phoneController,
            validator: (value) {
              if (value!.isEmpty) return 'Vui lòng nhập số điện thoại';
              if (!RegExp(r'^\d{10,11}$').hasMatch(value))
                return 'Số điện thoại không hợp lệ';
              return null;
            },
          ),
          const SizedBox(height: 20),

          // Địa chỉ: Tỉnh/Thành phố
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
              onChanged: (value) => _onProvinceChanged(value, authDataSource),
              decoration: InputDecoration(
              
                prefixIcon: Icon(
                  Icons.location_on_outlined,
                  color: AppPallete
                      .mutedTextColor, // giống CustomTextField khi chưa focus
                  size: 22, // chỉnh lại size cho đồng bộ
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

          // Địa chỉ: Phường/Xã
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
                  color: AppPallete
                      .mutedTextColor, // giống CustomTextField khi chưa focus
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

          // Checkbox
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

          // Button
          CustomElevatedButton(
            text: 'Đăng ký',
            onPressed: () => _handleSignUp(authDataSource),
          ),
        ],
      ),
    );
  }

  void _handleSignUp(AuthRemoteDataSource authDataSource) {
    if (_formKey.currentState!.validate() && _agreeTerms) {
      if (_selectedProvinceCode == null ||
          (_wards.isNotEmpty && _selectedWardCode == null)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Vui lòng chọn tỉnh/thành phố và phường/xã (nếu có)'),
          ),
        );
        return;
      }
      authDataSource.signupEmployer(
        fullName: _fullNameController.text,
        companyName: _companyNameController.text,
        phone: _phoneController.text,
        province: _selectedProvinceName ?? '',
        ward: _selectedWardName ?? '',
        email: _emailController.text,
        password: _passwordController.text,
      );
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Đăng ký thành công!')));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng điền đầy đủ thông tin và đồng ý điều khoản'),
        ),
      );
    }
  }
}

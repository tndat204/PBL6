import 'package:flutter/material.dart';
// 💡 Import cần thiết cho GetIt và Dropdown
import 'package:get_it/get_it.dart';
import 'package:pbl6/features/shared/auth/data/datasources/auth_remote_datasource.dart';
import 'package:pbl6/features/shared/auth/domain/entities/user_entity.dart';
import 'package:pbl6/features/shared/auth/presentation/widgets/custom_dropdown_field.dart';
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
  // 💡 Đổi _addressController thành _detailedAddressController
  late TextEditingController _detailedAddressController;

  // 💡 State cho Dropdown Tỉnh/Thành phố và Phường/Xã
  List<Map<String, dynamic>> _provinces = [];
  List<Map<String, dynamic>> _wards = [];
  bool _loadingProvinces = true;
  bool _loadingWards = false;

  int? _selectedProvinceCode;
  int? _selectedWardCode;
  String? _selectedProvinceName;
  String? _selectedWardName;
  String? _initialDetailedAddress;

  final AuthRemoteDataSource _authDataSource =
      GetIt.instance<AuthRemoteDataSource>();

  // 💡 Hàm tách địa chỉ ban đầu
  void _parseInitialAddress(String address) {
    if (address.isEmpty) return;

    final parts = address.split(', ').map((e) => e.trim()).toList();
    if (parts.length >= 3) {
      // Giả định: [Địa chỉ chi tiết], [Phường/Xã], [Tỉnh/Thành phố]
      _initialDetailedAddress = parts[0];
      _selectedWardName = parts[1];
      _selectedProvinceName = parts[2];
    } else {
      // Nếu không đúng định dạng, coi cả là địa chỉ chi tiết
      _initialDetailedAddress = address;
    }
  }

  @override
  void initState() {
    super.initState();
    _parseInitialAddress(widget.user.address); // 💡 Phân tích địa chỉ
    _nameController = TextEditingController(text: widget.user.fullName);
    _phoneController = TextEditingController(text: widget.user.phone);
    // 💡 Khởi tạo với phần địa chỉ chi tiết đã tách
    _detailedAddressController =
        TextEditingController(text: _initialDetailedAddress ?? widget.user.address);
    
    // Bắt đầu tải danh sách tỉnh/thành phố
    _fetchProvinces();
  }

  // 💡 Hàm tải danh sách tỉnh/thành phố
  Future<void> _fetchProvinces() async {
    try {
      final data = await _authDataSource.fetchProvinces();
      setState(() {
        _provinces = data;
        _loadingProvinces = false;
        // 💡 Tìm và thiết lập mã tỉnh/thành phố ban đầu nếu có tên
        if (_selectedProvinceName != null) {
          final initialProvince = _provinces.firstWhere(
              (p) => p['name'] == _selectedProvinceName,
              orElse: () => {});
          if (initialProvince.isNotEmpty) {
            _selectedProvinceCode = initialProvince['code'];
            // Tải phường/xã nếu tìm thấy tỉnh/thành phố
            _fetchWards(_selectedProvinceCode!);
          }
        }
      });
    } catch (e) {
      if (mounted) setState(() => _loadingProvinces = false);
      // Xử lý lỗi
    }
  }

  // 💡 Hàm tải danh sách phường/xã
  Future<void> _fetchWards(int provinceCode) async {
    setState(() => _loadingWards = true);
    try {
      final wards = await _authDataSource.fetchWards(provinceCode);
      if (mounted) {
        setState(() {
          _wards = wards;
          _loadingWards = false;
          // 💡 Tìm và thiết lập mã phường/xã ban đầu nếu có tên
          if (_selectedWardName != null) {
            final initialWard = _wards.firstWhere(
                (w) => w['name'] == _selectedWardName,
                orElse: () => {});
            if (initialWard.isNotEmpty) {
              _selectedWardCode = initialWard['code'];
            }
          }
        });
      }
    } catch (e) {
      if (mounted) setState(() => _loadingWards = false);
      // Xử lý lỗi
    }
  }

  // 💡 Xử lý khi chọn tỉnh/thành phố
  Future<void> _onProvinceChanged(int? code) async {
    if (code == null) {
      setState(() {
        _selectedProvinceCode = null;
        _selectedProvinceName = null;
        _selectedWardCode = null;
        _selectedWardName = null;
        _wards = [];
      });
      return;
    }

    setState(() {
      _selectedProvinceCode = code;
      _selectedWardCode = null;
      _selectedWardName = null;
      _wards = [];
      _loadingWards = true;
      _selectedProvinceName =
          _provinces.firstWhere((p) => p['code'] == code)['name'];
    });
    await _fetchWards(code);
  }

  // 💡 Xử lý khi chọn phường/xã
  void _onWardChanged(int? code) {
    setState(() {
      _selectedWardCode = code;
      _selectedWardName = code == null
          ? null
          : _wards.firstWhere((w) => w['code'] == code)['name'];
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _detailedAddressController.dispose(); // 💡 Dispose controller mới
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
            validator: (value) =>
                value!.isEmpty ? 'Vui lòng nhập họ và tên' : null,
          ),
          const SizedBox(height: 16),
          CustomTextField(
            label: 'Số điện thoại',
            icon: Icons.phone,
            obscureText: false,
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            validator: (value) {
              if (value!.isEmpty) return 'Vui lòng nhập số điện thoại';
              if (!RegExp(r'^\d{10,11}$').hasMatch(value)) {
                return 'Số điện thoại không hợp lệ';
              }
              return null;
            },
          ),

          const SizedBox(height: 16),

          // 💡 Dropdown Tỉnh/Thành phố
          if (_loadingProvinces)
            const Center(child: CircularProgressIndicator())
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
              onChanged: _onProvinceChanged,
              validator: (value) =>
                  value == null ? 'Vui lòng chọn tỉnh/thành phố' : null,
            ),

          const SizedBox(height: 16),

          // 💡 Dropdown Phường/Xã
          if (_loadingWards)
            const Center(child: CircularProgressIndicator())
          else
            CustomDropdownField<int>(
              label: 'Phường/Xã',
              icon: Icons.location_city_outlined,
              value: _selectedWardCode,
              hint: _wards.isEmpty ? 'Không có phường/xã' : 'Chọn phường/xã',
              items: _wards.map((ward) {
                final int code = ward['code'] as int;
                final String name = ward['name'] as String;
                return DropdownMenuItem<int>(value: code, child: Text(name));
              }).toList(),
              onChanged: _wards.isEmpty ? null : _onWardChanged,
              validator: (value) => value == null && _wards.isNotEmpty
                  ? 'Vui lòng chọn phường/xã'
                  : null,
            ),
                      const SizedBox(height: 16),
          // 💡 Thêm trường địa chỉ chi tiết
          CustomTextField(
            label: 'Địa chỉ chi tiết (VD: số nhà, tên đường)',
            icon: Icons.place,
            obscureText: false,
            controller: _detailedAddressController,
            validator: (value) =>
                value!.isEmpty ? 'Vui lòng nhập địa chỉ chi tiết' : null,
          ),
          const SizedBox(height: 32),

          // 🔹 Thay nút thường bằng CustomElevatedButton
          CustomElevatedButton(
            text: 'Cập nhật',
            onPressed: () async {
              // 💡 Kiểm tra validation cho Dropdown Tỉnh/Thành phố và Phường/Xã
              if (!_formKey.currentState!.validate() ||
                  _selectedProvinceCode == null ||
                  (_wards.isNotEmpty && _selectedWardCode == null)) {
                return;
              }

              // 💡 Logic kết hợp địa chỉ: Địa chỉ chi tiết, Phường/Xã, Tỉnh/Thành phố
              final detailedPart = _detailedAddressController.text.trim();
              final wardPart = _selectedWardName != null && _selectedWardName!.isNotEmpty ? _selectedWardName! : '';
              final provincePart = _selectedProvinceName != null && _selectedProvinceName!.isNotEmpty ? _selectedProvinceName! : '';

              // Nối các phần lại, chỉ thêm dấu phẩy nếu có phần tử đứng trước
              final addressParts = [detailedPart, wardPart, provincePart]
                  .where((s) => s.isNotEmpty)
                  .toList();
              final newAddress = addressParts.join(', ');

              final data = {
                'fullName': _nameController.text,
                'phone': _phoneController.text,
                'address': newAddress, // 💡 Sử dụng địa chỉ mới đã kết hợp
              };

              await widget.onSave(data);
            },
          ),
        ],
      ),
    );
  }
}
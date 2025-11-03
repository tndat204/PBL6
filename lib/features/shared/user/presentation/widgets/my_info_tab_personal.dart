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

 // 💡 ĐÃ SỬA: Dùng String? cho ID tỉnh và tên phường/xã
  String? _selectedProvinceId; // ID tỉnh (String)
  String? _selectedWardName; // Tên phường/xã đã chọn (String)
  String? _selectedProvinceName; 
  String? _initialDetailedAddress;

  final AuthRemoteDataSource _authDataSource =
      GetIt.instance<AuthRemoteDataSource>();

  // 💡 Hàm tách địa chỉ ban đầu (Không thay đổi logic phân tích, chỉ thay đổi biến gán)
  void _parseInitialAddress(String address) {
    if (address.isEmpty) return;

    final parts = address.split(', ').map((e) => e.trim()).toList();
    if (parts.length >= 3) {
      // Giả định: [Địa chỉ chi tiết], [Phường/Xã], [Tỉnh/Thành phố]
      _initialDetailedAddress = parts[0];
      _selectedWardName = parts[1]; // Tên Phường/Xã (String)
      _selectedProvinceName = parts[2]; // Tên Tỉnh/Thành phố (String)
    } else {
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
        
        if (_selectedProvinceName != null) {
          final initialProvince = _provinces.firstWhere(
              // Dùng 'province' cho tên tỉnh, thay vì 'name'
              (p) => p['province'] == _selectedProvinceName,
              orElse: () => {});
              
          if (initialProvince.isNotEmpty) {
            // Lấy 'id' (String) thay vì 'code' (int)
            _selectedProvinceId = initialProvince['id']; 
            
            // Tải phường/xã bằng TÊN TỈNH (String)
            _fetchWards(_selectedProvinceName!);
          }
        }
      });
    } catch (e) {
      if (mounted) setState(() => _loadingProvinces = false);
      // Xử lý lỗi
    }
  }

  // 💡 Hàm tải danh sách phường/xã (SỬA THAM SỐ VÀ LOGIC DỮ LIỆU)
  Future<void> _fetchWards(String provinceName) async {
    setState(() => _loadingWards = true);
    try {
      // 💡 API mới nhận TÊN TỈNH (String)
      final wards = await _authDataSource.fetchWards(provinceName); 
      if (mounted) {
        setState(() {
          _wards = wards;
          _loadingWards = false;
          
          if (_selectedWardName != null) {
            // Danh sách wards chỉ có 'name' (String) theo API mới
            final initialWard = _wards.firstWhere(
                (w) => w['name'] == _selectedWardName,
                orElse: () => {});
                
            if (initialWard.isNotEmpty) {
              // 💡 KHÔNG GÁN MÃ, chỉ cần đảm bảo _selectedWardName đã được thiết lập
              // _selectedWardName = initialWard['name']; // Đã có từ _parseInitialAddress
            }
          }
        });
      }
    } catch (e) {
      if (mounted) setState(() => _loadingWards = false);
      // Xử lý lỗi
    }
  }

  // 💡 Xử lý khi chọn tỉnh/thành phố (SỬA THAM SỐ VÀ LOGIC DỮ LIỆU)
  Future<void> _onProvinceChanged(String? id) async {
    if (id == null) {
      setState(() {
        _selectedProvinceId = null;
        _selectedProvinceName = null;
        _selectedWardName = null;
        _wards = [];
      });
      return;
    }

    // 1. Lấy tên tỉnh từ ID
    final String provinceName = _provinces.firstWhere((p) => p['id'] == id)['province'];

    setState(() {
      _selectedProvinceId = id;
      _selectedProvinceName = provinceName;
      _selectedWardName = null; // Reset phường/xã
      _wards = [];
      _loadingWards = true;
    });
    
    // 2. Gọi API lấy wards bằng TÊN tỉnh
    await _fetchWards(provinceName); 
  }

  // 💡 Xử lý khi chọn phường/xã (SỬA THAM SỐ VÀ LOGIC DỮ LIỆU)
  void _onWardChanged(String? name) {
    setState(() {
      // Gán TÊN phường/xã (String)
      _selectedWardName = name; 
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

          if (_loadingProvinces)
            const Center(child: CircularProgressIndicator())
          else
            CustomDropdownField<String>( // 💡 Dùng String
              label: 'Tỉnh/Thành phố',
              icon: Icons.location_on_outlined,
              value: _selectedProvinceId, // 💡 Dùng ID (String)
              hint: 'Chọn tỉnh/thành phố',
              items: _provinces.map((province) {
                final String id = province['id']; // Dùng 'id'
                final String name = province['province']; // Dùng 'province' cho tên
                return DropdownMenuItem<String>(value: id, child: Text(name));
              }).toList(),
              onChanged: _onProvinceChanged, // 💡 Nhận String?
              validator: (value) =>
                  value == null ? 'Vui lòng chọn tỉnh/thành phố' : null,
            ),
          const SizedBox(height: 16),

          // 💡 Dropdown Phường/Xã
          if (_loadingWards)
            const Center(child: CircularProgressIndicator())
          else
            CustomDropdownField<String>( // 💡 Dùng String
              label: 'Phường/Xã',
              icon: Icons.location_city_outlined,
              value: _selectedWardName, // 💡 Dùng TÊN phường/xã (String)
              hint: _wards.isEmpty ? 'Không có phường/xã' : 'Chọn phường/xã',
              items: _wards.map((ward) {
                // API mới chỉ trả về 'name' cho wards (tên là String)
                final String name = ward['name'] as String; 
                return DropdownMenuItem<String>(value: name, child: Text(name)); // 💡 value là TÊN (String)
              }).toList(),
              onChanged: _wards.isEmpty ? null : _onWardChanged, // 💡 Nhận String?
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
              // 💡 Kiểm tra validation: Dùng ID (String) và TÊN phường/xã (String)
              if (!_formKey.currentState!.validate() ||
                  _selectedProvinceId == null || 
                  (_wards.isNotEmpty && _selectedWardName == null)) {
                return;
              }

              // 💡 Logic kết hợp địa chỉ: Địa chỉ chi tiết, Phường/Xã, Tỉnh/Thành phố
              final detailedPart = _detailedAddressController.text.trim();
              final wardPart = _selectedWardName != null && _selectedWardName!.isNotEmpty ? _selectedWardName! : '';
              final provincePart = _selectedProvinceName != null && _selectedProvinceName!.isNotEmpty ? _selectedProvinceName! : '';

              final addressParts = [detailedPart, wardPart, provincePart]
                  .where((s) => s.isNotEmpty)
                  .toList();
              final newAddress = addressParts.join(', ');

              final data = {
                'fullName': _nameController.text,
                'phone': _phoneController.text,
                'address': newAddress, // Sử dụng địa chỉ mới đã kết hợp
              };

              await widget.onSave(data);
            },
          ),
        ],
      ),
    );
  }
}
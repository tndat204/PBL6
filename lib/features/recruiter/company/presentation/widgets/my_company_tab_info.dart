import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:pbl6/features/shared/auth/data/datasources/auth_remote_datasource.dart';
import 'package:pbl6/features/shared/auth/presentation/widgets/custom_dropdown_field.dart';
import 'package:pbl6/features/shared/auth/presentation/widgets/custom_elevated_button.dart';
import 'package:pbl6/features/shared/auth/presentation/widgets/custom_text_field.dart';
import 'package:pbl6/features/shared/company/domain/entities/company.dart';

class MyCompanyTabInfo extends StatefulWidget {
  final Company company;
  final Future<void> Function(Company updatedCompany) onSave;

  const MyCompanyTabInfo({
    super.key,
    required this.company,
    required this.onSave,
  });

  @override
  State<MyCompanyTabInfo> createState() => _MyCompanyTabInfoState();
}

class _MyCompanyTabInfoState extends State<MyCompanyTabInfo> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  late TextEditingController _nameController;
  late TextEditingController _taxCodeController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _detailedAddressController;
  late TextEditingController _descriptionController; // 💡 THÊM CONTROLLER MÔ TẢ

  // Dropdown State
  List<Map<String, dynamic>> _provinces = [];
  List<Map<String, dynamic>> _wards = [];
  bool _loadingProvinces = true;
  bool _loadingWards = false;

  String? _selectedProvinceId;
  String? _selectedWardName;
  String? _selectedProvinceName;
  String? _initialDetailedAddress;

  final AuthRemoteDataSource _authDataSource = GetIt.I<AuthRemoteDataSource>();

  void _parseInitialAddress(String address) {
    if (address.isEmpty) return;
    final parts = address.split(', ').map((e) => e.trim()).toList();
    if (parts.length >= 3) {
      _initialDetailedAddress = parts[0];
      _selectedWardName = parts[1];
      _selectedProvinceName = parts[2];
    } else {
      _initialDetailedAddress = address;
    }
  }

  @override
  void initState() {
    super.initState();
    // Khởi tạo controllers với dữ liệu công ty
    _nameController = TextEditingController(text: widget.company.name);
    _taxCodeController = TextEditingController(text: widget.company.taxCode);
    _phoneController = TextEditingController(text: widget.company.phone ?? '');
    _emailController = TextEditingController(text: widget.company.email ?? '');
    _descriptionController = TextEditingController(text: widget.company.description ?? ''); // 💡 KHỞI TẠO

    // Khởi tạo logic địa chỉ
    _parseInitialAddress(widget.company.address);
    _detailedAddressController =
        TextEditingController(text: _initialDetailedAddress ?? '');
    
    _fetchProvinces();
  }

  Future<void> _fetchProvinces() async {
    try {
      final data = await _authDataSource.fetchProvinces();
      setState(() {
        _provinces = data;
        _loadingProvinces = false;
        
        if (_selectedProvinceName != null) {
          final initialProvince = _provinces.firstWhere(
            (p) => p['province'] == _selectedProvinceName,
            orElse: () => {});
            
          if (initialProvince.isNotEmpty) {
            _selectedProvinceId = initialProvince['id']; 
            _fetchWards(_selectedProvinceName!);
          }
        }
      });
    } catch (e) {
      if (mounted) setState(() => _loadingProvinces = false);
    }
  }

  Future<void> _fetchWards(String provinceName) async {
    setState(() => _loadingWards = true);
    try {
      final wards = await _authDataSource.fetchWards(provinceName); 
      if (mounted) {
        setState(() {
          _wards = wards;
          _loadingWards = false;
          
          if (_selectedWardName != null) {
            final initialWard = _wards.firstWhere(
                (w) => w['name'] == _selectedWardName,
                orElse: () => {});
            if (initialWard.isEmpty) {
              _selectedWardName = null; // Reset nếu không tìm thấy ward cũ
            }
          }
        });
      }
    } catch (e) {
      if (mounted) setState(() => _loadingWards = false);
    }
  }

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

    final String provinceName = _provinces.firstWhere((p) => p['id'] == id)['province'];

    setState(() {
      _selectedProvinceId = id;
      _selectedProvinceName = provinceName;
      _selectedWardName = null; 
      _wards = [];
      _loadingWards = true;
    });
    
    await _fetchWards(provinceName); 
  }

  void _onWardChanged(String? name) {
    setState(() => _selectedWardName = name);
  }
  
  void _onSavePressed() {
    if (!_formKey.currentState!.validate() ||
        _selectedProvinceId == null ||
        (_wards.isNotEmpty && _selectedWardName == null)) {
      return;
    }

    final detailedPart = _detailedAddressController.text.trim();
    final wardPart = _selectedWardName ?? '';
    final provincePart = _selectedProvinceName ?? '';

    final addressParts = [detailedPart, wardPart, provincePart]
        .where((s) => s.isNotEmpty)
        .toList();
    final newAddress = addressParts.join(', ');

    // 💡 Tạo đối tượng Company đã cập nhật (THÊM DESCRIPTION)
    final updatedCompany = widget.company.copyWith(
      name: _nameController.text.trim(),
      taxCode: _taxCodeController.text.trim(),
      phone: _phoneController.text.trim(),
      email: _emailController.text.trim(),
      address: newAddress,
      description: _descriptionController.text.trim(), // 💡 THÊM VÀO ĐÂY
    );

    // Gọi callback onSave của trang cha
    widget.onSave(updatedCompany);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _taxCodeController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _detailedAddressController.dispose();
    _descriptionController.dispose(); // 💡 DISPOSE
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
            label: 'Tên công ty',
            icon: Icons.business,
            controller: _nameController,
            validator: (v) => v!.isEmpty ? 'Không được để trống' : null,
            obscureText: false, 
          ),
          const SizedBox(height: 16),
          CustomTextField(
            label: 'Mã số thuế',
            icon: Icons.receipt_long,
            controller: _taxCodeController,
            validator: (v) => v!.isEmpty ? 'Không được để trống' : null,
            obscureText: false, 
          ),
          const SizedBox(height: 16),
          CustomTextField(
            label: 'Email công ty',
            icon: Icons.email,
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            validator: (v) => (v!.isEmpty || !v.contains('@')) ? 'Email không hợp lệ' : null,
            obscureText: false, 
          ),
          const SizedBox(height: 16),
          CustomTextField(
            label: 'Số điện thoại',
            icon: Icons.phone,
            controller: _phoneController,
            keyboardType: TextInputType.phone,
             validator: (value) {
              if (value!.isEmpty) return 'Vui lòng nhập số điện thoại';
              if (!RegExp(r'^\d{10,11}$').hasMatch(value)) {
                return 'Số điện thoại không hợp lệ';
              }
              return null;
            },
            obscureText: false, 
          ),
          const SizedBox(height: 16),

          // --- Dropdowns Địa chỉ ---
          if (_loadingProvinces)
            const Center(child: CircularProgressIndicator())
          else
            CustomDropdownField<String>(
              label: 'Tỉnh/Thành phố',
              icon: Icons.location_on_outlined,
              value: _selectedProvinceId,
              hint: 'Chọn tỉnh/thành phố',
              items: _provinces.map((province) {
                return DropdownMenuItem<String>(
                  value: province['id'], 
                  child: Text(province['province'])
                );
              }).toList(),
              onChanged: _onProvinceChanged,
              validator: (v) => v == null ? 'Vui lòng chọn tỉnh' : null,
            ),
          const SizedBox(height: 16),

          if (_loadingWards)
            const Center(child: CircularProgressIndicator())
          else
            CustomDropdownField<String>(
              label: 'Phường/Xã',
              icon: Icons.location_city_outlined,
              value: _selectedWardName,
              hint: _wards.isEmpty ? 'Không có phường/xã' : 'Chọn phường/xã',
              items: _wards.map((ward) {
                final String name = ward['name'] as String;
                return DropdownMenuItem<String>(value: name, child: Text(name));
              }).toList(),
              onChanged: _wards.isEmpty ? null : _onWardChanged,
              validator: (v) => (v == null && _wards.isNotEmpty) ? 'Vui lòng chọn phường/xã' : null,
            ),
          const SizedBox(height: 16),
          
          CustomTextField(
            label: 'Địa chỉ chi tiết (VD: số nhà, tên đường)',
            icon: Icons.place,
            controller: _detailedAddressController,
            validator: (v) => v!.isEmpty ? 'Vui lòng nhập địa chỉ' : null,
            obscureText: false, 
          ),
          const SizedBox(height: 16),

          // 💡 THÊM TRƯỜNG MÔ TẢ VÀO ĐÂY
          CustomTextField(
            label: 'Mô tả công ty',
            icon: Icons.description_outlined,
            controller: _descriptionController,
            keyboardType: TextInputType.multiline,
            maxLines: 10, 
            minLines: 5,
            obscureText: false, 
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Vui lòng nhập mô tả công ty';
              }
              if (value.length < 50) {
                 return 'Mô tả phải có ít nhất 50 ký tự';
              }
              return null;
            },
          ),
          
          const SizedBox(height: 32),
          
          CustomElevatedButton(
            text: 'Lưu thay đổi',
            onPressed: _onSavePressed,
          ),

          // 💡 THÊM KHOẢNG ĐỆM Ở CUỐI
          // Giúp nút "Lưu" có thể cuộn lên trên CustomBottomBar
          const SizedBox(height: 100),
        ],
      ),
    );
  }
}
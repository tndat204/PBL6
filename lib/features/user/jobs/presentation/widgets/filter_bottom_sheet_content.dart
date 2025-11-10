import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pbl6/core/theme/app_pallete.dart';
import 'package:pbl6/features/shared/auth/presentation/widgets/custom_dropdown_field.dart';

// Model để truyền/nhận giá trị filter
class FilterValues {
  double? minSalary;
  double? maxSalary;
  String? locationProvince;
  String? jobType;
  DateTime? expiryDateBefore;

  FilterValues({
    this.minSalary,
    this.maxSalary,
    this.locationProvince,
    this.jobType,
    this.expiryDateBefore,
  });

  bool get hasActiveFilters =>
      minSalary != null ||
      maxSalary != null ||
      locationProvince != null ||
      jobType != null ||
      expiryDateBefore != null;
}

class FilterBottomSheetContent extends StatefulWidget {
  final FilterValues initialFilters;
  final List<Map<String, dynamic>> provinces;
  final List<String> jobTypeNames;
  final bool isLoadingProvinces;

  const FilterBottomSheetContent({
    Key? key,
    required this.initialFilters,
    required this.provinces,
    required this.jobTypeNames,
    this.isLoadingProvinces = false,
  }) : super(key: key);

  @override
  _FilterBottomSheetContentState createState() =>
      _FilterBottomSheetContentState();
}

class _FilterBottomSheetContentState extends State<FilterBottomSheetContent> {
  late FilterValues _currentFilters;
  late RangeValues _currentSalaryRange;
  DateTime? _selectedExpiryDate;

  final double _minSalaryLimit = 0;
  final double _maxSalaryLimit = 100000000;
  final currencyFormatter = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');

  final Map<String, String> _jobTypeDisplayMap = {
    'FULL_TIME': 'Full-time',
    'PART_TIME': 'Part-time',
    'CONTRACT': 'Contract',
    'REMOTE': 'Remote',
      };

  @override
  void initState() {
    super.initState();
    _currentFilters = FilterValues(
      minSalary: widget.initialFilters.minSalary,
      maxSalary: widget.initialFilters.maxSalary,
      locationProvince: widget.initialFilters.locationProvince,
      jobType: widget.initialFilters.jobType,
      expiryDateBefore: widget.initialFilters.expiryDateBefore,
    );
    _currentSalaryRange = RangeValues(
      _currentFilters.minSalary ?? _minSalaryLimit,
      _currentFilters.maxSalary ?? _maxSalaryLimit,
    );
    _selectedExpiryDate = _currentFilters.expiryDateBefore;
  }

  Future<void> _selectExpiryDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedExpiryDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 730)),
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
    if (picked != null && picked != _selectedExpiryDate) {
      setState(() {
        _selectedExpiryDate = picked;
        _currentFilters.expiryDateBefore = picked;
      });
    }
  }

  String _formatSalary(double value) {
    if (value >= 1000000) return '${(value / 1000000).toStringAsFixed(0)} Tr';
    if (value >= 1000) return '${(value / 1000).toStringAsFixed(0)} K';
    return currencyFormatter.format(value);
  }

  @override
  Widget build(BuildContext context) {
    // SỬA: Tạo danh sách unique (độc nhất) để tránh lỗi assertion
    final uniqueProvinceNames = widget.provinces
        .map((p) => p['province'] as String?)
        .where((name) => name != null && name.isNotEmpty) // Lọc null hoặc rỗng
        .toSet() // Lọc trùng lặp
        .toList();

    final uniqueJobTypeNames = widget.jobTypeNames.toSet().toList();

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 70,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Header ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Bộ lọc nâng cao',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.grey),
                    onPressed: () => Navigator.pop(context),
                    tooltip: 'Đóng',
                  ),
                ],
              ),
              const Divider(height: 20, thickness: 1),

              // --- Lọc Lương ---
              const Text('Khoảng lương (VND)',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              RangeSlider(
                values: _currentSalaryRange,
                min: _minSalaryLimit,
                max: _maxSalaryLimit,
                divisions: 100,
                labels: RangeLabels(
                  _formatSalary(_currentSalaryRange.start),
                  _formatSalary(_currentSalaryRange.end),
                ),
                activeColor: AppPallete.primaryColor,
                inactiveColor: Colors.grey.shade300,
                onChanged: (RangeValues values) {
                  setState(() {
                    _currentSalaryRange = values;
                    _currentFilters.minSalary =
                        values.start > _minSalaryLimit ? values.start : null;
                    _currentFilters.maxSalary =
                        values.end < _maxSalaryLimit ? values.end : null;
                  });
                },
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(_formatSalary(_currentSalaryRange.start),
                        style:
                            const TextStyle(color: Colors.grey, fontSize: 12)),
                    Text(_formatSalary(_currentSalaryRange.end),
                        style:
                            const TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // --- Lọc Địa điểm ---
              CustomDropdownField<String>(
                key: const ValueKey('filter_province_dropdown'),
                label: 'Địa điểm',
                icon: Icons.location_on_outlined,
                value: _currentFilters.locationProvince,
                hint: widget.isLoadingProvinces
                    ? 'Đang tải...'
                    : 'Tất cả tỉnh/thành phố',
                items: [
                  const DropdownMenuItem<String>(
                      value: null, child: Text('Tất cả địa điểm')),
                  // SỬA: Dùng danh sách unique đã lọc
                  ...uniqueProvinceNames.map((provinceName) {
                    return DropdownMenuItem<String>(
                      value: provinceName,
                      child: Text(provinceName!),
                    );
                  })
                ],
                onChanged: widget.isLoadingProvinces
                    ? null
                    : (String? newValue) {
                        setState(() {
                          _currentFilters.locationProvince = newValue;
                        });
                      },
              ),
              const SizedBox(height: 24),

              // --- Lọc Loại công việc ---
              CustomDropdownField<String>(
                key: const ValueKey('filter_jobtype_dropdown'),
                label: 'Loại công việc',
                icon: Icons.work_outline,
                value: _currentFilters.jobType,
                hint: 'Tất cả loại hình',
                items: [
                  const DropdownMenuItem<String>(
                      value: null, child: Text('Tất cả loại hình')),
                  // SỬA: Dùng danh sách unique đã lọc
                  ...uniqueJobTypeNames.map((enumName) {
                    return DropdownMenuItem<String>(
                      value: enumName,
                      child:
                          Text(_jobTypeDisplayMap[enumName] ?? enumName),
                    );
                  })
                ],
                onChanged: (String? newValue) {
                  setState(() {
                    _currentFilters.jobType = newValue;
                  });
                },
              ),
              const SizedBox(height: 24),

              // --- Lọc Ngày hết hạn ---
              const Text('Hạn nộp hồ sơ trước ngày',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                title: Text(
                  _selectedExpiryDate == null
                      ? 'Không chọn'
                      : DateFormat('dd/MM/yyyy').format(_selectedExpiryDate!),
                  style: TextStyle(
                    fontSize: 16,
                    color: _selectedExpiryDate == null
                        ? Colors.grey.shade600
                        : Colors.black87,
                  ),
                ),
                trailing: const Icon(Icons.calendar_today_outlined,
                    color: Colors.grey),
                onTap: () => _selectExpiryDate(context),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.grey.shade300),
                ),
              ),
              if (_selectedExpiryDate != null)
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      setState(() {
                        _selectedExpiryDate = null;
                        _currentFilters.expiryDateBefore = null;
                      });
                    },
                    child: const Text('Xóa ngày',
                        style: TextStyle(
                            color: Colors.redAccent, fontSize: 13)),
                  ),
                ),
              const SizedBox(height: 32),

              // --- Nút hành động ---
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pop(context, FilterValues());
                      },
                      style: OutlinedButton.styleFrom(
                        padding:
                            const EdgeInsets.symmetric(vertical: 14),
                        side:
                            BorderSide(color: Colors.grey.shade400),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Đặt lại',
                          style: TextStyle(color: Colors.black54)),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context, _currentFilters);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppPallete.primaryColor,
                        foregroundColor: Colors.white,
                        padding:
                            const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        elevation: 2,
                      ),
                      child: const Text('Áp dụng'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
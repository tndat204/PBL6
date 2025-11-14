import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:motion_toast/motion_toast.dart';
import 'package:pbl6/core/theme/app_pallete.dart';
import 'package:pbl6/core/utils/currency_input_formatter.dart';
import 'package:pbl6/features/recruiter/job/domain/usecases/create_job_usecase.dart';
import 'package:pbl6/features/recruiter/job/domain/usecases/update_job_usecase.dart';
import 'package:pbl6/features/shared/auth/data/datasources/auth_remote_datasource.dart';
import 'package:pbl6/features/shared/auth/domain/repositories/auth_repository.dart';
import 'package:pbl6/features/shared/auth/presentation/widgets/custom_dropdown_field.dart';
import 'package:pbl6/features/shared/auth/presentation/widgets/custom_elevated_button.dart';
import 'package:pbl6/features/shared/auth/presentation/widgets/custom_text_field.dart';
import 'package:pbl6/features/shared/category/domain/entities/category.dart';
import 'package:pbl6/features/shared/category/domain/usecases/get_all_categories_usecase.dart';
import 'package:pbl6/features/shared/company/domain/entities/company.dart';
import 'package:pbl6/features/shared/company/domain/usecases/get_company_details_usecase.dart';
import 'package:pbl6/features/shared/job/domain/entities/job.dart';
import 'package:pbl6/features/shared/job/domain/usecases/get_job_details_usecase.dart';
import 'package:pbl6/features/shared/skill/domain/entities/skill.dart';
import 'package:pbl6/features/shared/skill/domain/usecases/get_all_skills_usecase.dart';

class UpsertJobPage extends StatefulWidget {
  final String? jobId; 
  const UpsertJobPage({super.key, this.jobId});

  bool get isEditMode => jobId != null;

  @override
  State<UpsertJobPage> createState() => _UpsertJobPageState();
}

class _UpsertJobPageState extends State<UpsertJobPage> {
  // UseCases & Repositories
  late final AuthRepository _authRepository;
  late final GetJobDetailsUseCase _getJobDetailsUseCase;
  late final GetAllCategoriesUseCase _getAllCategoriesUseCase;
  late final GetAllSkillsUseCase _getAllSkillsUseCase;
  late final GetCompanyDetailsUseCase _getCompanyDetailsUseCase;
  late final AuthRemoteDataSource _authDataSource;
  late final CreateJobUseCase _createJobUseCase;
  late final UpdateJobUseCase _updateJobUseCase;

  // Form State
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = true;
  String? _companyId;
  Company? _myCompany;
  Job? _editingJob;

  // Data for Dropdowns
  List<Category> _categories = [];
  List<Skill> _allSkills = []; // Đổi tên thành _allSkills để tránh nhầm lẫn
  List<Map<String, dynamic>> _provinces = [];
  final List<ExperienceLevel> _expLevels = ExperienceLevel.values;
  final List<JobType> _jobTypes = JobType.values;

  final _titleController = TextEditingController();
  final _salaryMinController = TextEditingController();
  final _salaryMaxController = TextEditingController();
  int _expMin = 0;
  int _expMax = 0;
  final _descriptionController = TextEditingController();
  final _expiryDateController = TextEditingController();

  ExperienceLevel? _selectedExpLevel;
  JobType? _selectedJobType;
  String? _selectedProvince;
  bool _isActive = true;

  List<Skill> _selectedSkills = [];
  List<Category> _selectedCategories = [];

  @override
  void initState() {
    super.initState();
    // Init GetIt
    _authRepository = GetIt.I<AuthRepository>();
    _getJobDetailsUseCase = GetIt.I<GetJobDetailsUseCase>();
    _getAllCategoriesUseCase = GetIt.I<GetAllCategoriesUseCase>();
    _getAllSkillsUseCase = GetIt.I<GetAllSkillsUseCase>();
    _getCompanyDetailsUseCase = GetIt.I<GetCompanyDetailsUseCase>();
    _authDataSource = GetIt.I<AuthRemoteDataSource>();
    _createJobUseCase = GetIt.I<CreateJobUseCase>();
    _updateJobUseCase = GetIt.I<UpdateJobUseCase>();

    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    try {
      // 1. Lấy ID công ty (bắt buộc)
      _companyId = await _authRepository.getCompanyId();
      if (_companyId == null) throw Exception("Không tìm thấy công ty");

      // 2. Tải song song các dữ liệu cho dropdown
      final results = await Future.wait([
        _getCompanyDetailsUseCase(_companyId!),
        _getAllCategoriesUseCase(),
        _getAllSkillsUseCase(),
        _authDataSource.fetchProvinces(),
        if (widget.isEditMode) _getJobDetailsUseCase(widget.jobId!),
      ]);

      // 3. Gán dữ liệu
      _myCompany = results[0] as Company;
      _categories = results[1] as List<Category>;
      _allSkills = results[2] as List<Skill>;
      _provinces = results[3] as List<Map<String, dynamic>>;
      if (widget.isEditMode) {
        _editingJob = results[4] as Job;
        _prefillForm();
      } else {
        // Gán giá trị mặc định cho form Add
        _selectedJobType = JobType.FULL_TIME;
        _selectedExpLevel = ExperienceLevel.ANY;
        _isActive = true;
      }
    } catch (e) {
      if (mounted) {
        MotionToast.error(
          description: Text("Lỗi tải dữ liệu: $e"),
        ).show(context);
        context.pop();
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _prefillForm() {
    if (_editingJob == null) return;
    final job = _editingJob!;

    _titleController.text = job.title;
    _salaryMinController.text = NumberFormat('#,###').format(job.salaryMin);
    _salaryMaxController.text = NumberFormat('#,###').format(job.salaryMax);
    _expMin = job.requiredYearsOfExpMin;
    _expMax = job.requiredYearsOfExpMax;
    _descriptionController.text = job.description;
    _expiryDateController.text = DateFormat('dd/MM/yyyy').format(
      DateTime(job.expiryDate.year, job.expiryDate.month, job.expiryDate.day),
    );

    _selectedExpLevel = job.experienceLevel;
    _selectedJobType = job.jobType;
    _isActive = job.status == JobStatus.ACTIVE;

    final foundProvince = _provinces.firstWhere(
      (p) => p['province'] != null && job.location.contains(p['province']),
      orElse: () =>
          {}, // trả về Map trống, hợp lệ với List<Map<String,dynamic>>
    );

    _selectedProvince = foundProvince.isNotEmpty
        ? foundProvince['province'] as String?
        : null;

    // Tìm skills/categories đã chọn
    _selectedSkills = _allSkills
        .where((s) => job.skillIds.contains(s.id))
        .toList();
    _selectedCategories = _categories
        .where((c) => job.categoryIds.contains(c.id))
        .toList();
  }

  // 💡 HÀM XỬ LÝ KHI CHỌN/BỎ CHỌN CATEGORY
  void _onCategoryChanged(List<Category> newSelectedCategories) {
    setState(() {
      _selectedCategories = newSelectedCategories;

      final Set<String> recommendedSkillIds = {};
      for (final category in newSelectedCategories) {
        recommendedSkillIds.addAll(category.skills.map((s) => s.id));
      }

      final Set<Skill> newSkillsSet = {};

      for (final skillId in recommendedSkillIds) {
        final skill = _allSkills.firstWhere((s) => s.id == skillId);
        newSkillsSet.add(skill);
      }

      for (final skill in _selectedSkills) {
        if (!recommendedSkillIds.contains(skill.id)) {
          newSkillsSet.add(skill);
        }
      }

      _selectedSkills = newSkillsSet.toList();
    });
  }

  void _onSkillChanged(List<Skill> selectedSkills) {
    setState(() {
      _selectedSkills = selectedSkills;
    });
  }

  Future<void> _selectDate(
    BuildContext context,
    TextEditingController controller,
  ) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: controller.text.isNotEmpty
          ? DateFormat('dd/MM/yyyy').parse(controller.text)
          : DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
      locale: const Locale('vi', 'VN'),
    );
    if (picked != null) {
      setState(() {
        controller.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      MotionToast.error(
        description: Text('Vui lòng kiểm tra lại các trường'),
      ).show(context);
      return;
    }

    if (_myCompany == null) {
      MotionToast.error(
        description: Text('Lỗi thông tin công ty'),
      ).show(context);
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 1. Tạo đối tượng Job
      final jobData = Job(
        id: _editingJob?.id ?? '', // Sẽ bị bỏ qua bởi API khi tạo mới
        companyId: _myCompany!.id,
        title: _titleController.text,
        description: _descriptionController.text,
        status: _isActive ? JobStatus.ACTIVE : JobStatus.INACTIVE,
        salaryMin:
            int.tryParse(_salaryMinController.text.replaceAll(',', '')) ?? 0,
        salaryMax:
            int.tryParse(_salaryMaxController.text.replaceAll(',', '')) ?? 0,

        jobType: _selectedJobType!,
        experienceLevel: _selectedExpLevel!,
        requiredYearsOfExpMin: _expMin,
        requiredYearsOfExpMax: _expMax,
        // Dùng danh sách đã chọn
        categoryIds: _selectedCategories.map((c) => c.id).toList(),
        skillIds: _selectedSkills.map((s) => s.id).toList(),

        location: _selectedProvince!,
        expiryDate: _expiryDateController.text.isNotEmpty
            ? (() {
                return DateFormat(
                  'dd/MM/yyyy',
                ).parseStrict(_expiryDateController.text);
              })()
            : DateTime.now(),
        postedBy: '', // API sẽ tự gán
      );

      // 2. Gọi UseCase
      if (widget.isEditMode) {
        await _updateJobUseCase(
          UpdateJobParams(jobId: widget.jobId!, job: jobData),
        );
      } else {
        await _createJobUseCase(jobData);
      }

      // 3. Thông báo thành công và quay lại
      if (mounted) {
        MotionToast.success(
          description: Text(
            widget.isEditMode ? 'Cập nhật thành công!' : 'Đăng tin thành công!',
          ),
          toastAlignment: Alignment.topLeft,
        ).show(context);
        context.pop(true);
      }
    } catch (e) {
      if (mounted) {
        final errorString = e.toString();
        final maxLength = errorString.length < 100 ? errorString.length : 100;

        MotionToast.error(
          description: Text(
            'Đã xảy ra lỗi: ${errorString.substring(0, maxLength)}${errorString.length > 100 ? '...' : ''}',
          ),
        ).show(context);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Nền trắng
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black),
        title: Text(
          widget.isEditMode
              ? 'Chỉnh sửa tin tuyển dụng'
              : 'Đăng tin tuyển dụng',
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Tên tin tuyển dụng
                    CustomTextField(
                      controller: _titleController,
                      label: 'Tên tin tuyển dụng *',
                      icon: Icons.title,
                      validator: (val) =>
                          val!.isEmpty ? 'Không được để trống' : null,
                      obscureText: false,
                    ),
                    const SizedBox(height: 16),

                    // Danh mục (Multi-select)
                    _buildMultiSelectChipField<Category>(
                      label: 'Danh mục *',
                      icon: Icons.category,
                      allItems: _categories,
                      selectedItems: _selectedCategories,
                      // 💡 GỌI HÀM XỬ LÝ HYBRID
                      onChanged: _onCategoryChanged,
                      validator: (list) =>
                          list!.isEmpty ? 'Phải chọn ít nhất 1' : null,
                    ),
                    const SizedBox(height: 16),

                    // Kỹ năng (Multi-select) - BÂY GIỜ PHỤ THUỘC VÀO CATEGORY
                    _buildMultiSelectChipField<Skill>(
                      label: 'Kỹ năng *',
                      icon: Icons.code,
                      // 💡 CHỈ LỌC SKILL TỪ CÁC CATEGORY ĐÃ CHỌN ĐỂ ĐỀ XUẤT
                      allItems:
                          _allSkills, // Truyền tất cả skills cho dialog chọn
                      selectedItems: _selectedSkills,
                      onChanged: _onSkillChanged, // GỌI HÀM CẬP NHẬT SKILL
                      validator: (list) =>
                          list!.isEmpty ? 'Phải chọn ít nhất 1' : null,
                    ),
                    const SizedBox(height: 16),

                    // Công ty (disabled)
                    CustomTextField(
                      controller: TextEditingController(
                        text: _myCompany?.name ?? '',
                      ),
                      label: 'Công ty *',
                      icon: Icons.business,
                      enabled: false,
                      obscureText: false,
                    ),
                    const SizedBox(height: 16),

                    // Địa điểm
                    CustomDropdownField<String>(
                      label: 'Địa điểm *',
                      icon: Icons.location_on,
                      value: _selectedProvince,
                      hint: 'Chọn tỉnh/thành phố',
                      items: _provinces
                          .map(
                            (p) => DropdownMenuItem(
                              value: p['province'] as String,
                              child: Text(p['province'] as String),
                            ),
                          )
                          .toList(),
                      onChanged: (val) =>
                          setState(() => _selectedProvince = val),
                      validator: (val) =>
                          val == null ? 'Vui lòng chọn địa điểm' : null,
                    ),
                    const SizedBox(height: 16),

                    // Lương
                    Row(
                      children: [
                        Expanded(
                          child: CustomTextField(
                            controller: _salaryMinController,
                            label: 'Lương từ *',
                            icon: Icons.attach_money,
                            keyboardType: TextInputType.number,
                            inputFormatters: [CurrencyInputFormatter()],
                            validator: (val) =>
                                val!.isEmpty ? 'Không để trống' : null,
                            obscureText: false,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: CustomTextField(
                            controller: _salaryMaxController,
                            label: 'Lương đến *',
                            icon: Icons.money_off,
                            keyboardType: TextInputType.number,
                            inputFormatters: [CurrencyInputFormatter()],
                            validator: (val) =>
                                val!.isEmpty ? 'Không để trống' : null,
                            obscureText: false,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Trình độ
                    CustomDropdownField<ExperienceLevel>(
                      label: 'Trình độ *',
                      icon: Icons.bar_chart,
                      value: _selectedExpLevel,
                      hint: 'Chọn trình độ',
                      items: _expLevels
                          .map(
                            (e) =>
                                DropdownMenuItem(value: e, child: Text(e.name)),
                          )
                          .toList(),
                      onChanged: (val) =>
                          setState(() => _selectedExpLevel = val),
                      validator: (val) => val == null ? 'Vui lòng chọn' : null,
                    ),
                    const SizedBox(height: 16),

                    // Kinh nghiệm
                    Row(
                      children: [
                        // Kinh nghiệm từ
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Kinh nghiệm từ (năm) *'),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  IconButton(
                                    onPressed: () {
                                      setState(() {
                                        if (_expMin > 0) {
                                          _expMin--;
                                          // Đồng bộ expMax nếu cần
                                          if (_expMax < _expMin)
                                            _expMax = _expMin;
                                        }
                                      });
                                    },
                                    icon: const Icon(
                                      Icons.remove_circle_outline,
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.grey),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      '$_expMin',
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      setState(() {
                                        _expMin++;
                                        // Đồng bộ expMax nếu cần
                                        if (_expMax < _expMin)
                                          _expMax = _expMin;
                                      });
                                    },
                                    icon: const Icon(Icons.add_circle_outline),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Kinh nghiệm đến
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Kinh nghiệm đến (năm) *'),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  IconButton(
                                    onPressed: () {
                                      setState(() {
                                        if (_expMax > _expMin) _expMax--;
                                      });
                                    },
                                    icon: const Icon(
                                      Icons.remove_circle_outline,
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.grey),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      '$_expMax',
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      setState(() {
                                        _expMax++;
                                      });
                                    },
                                    icon: const Icon(Icons.add_circle_outline),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Ngày kết thúc
                    CustomTextField(
                      controller: _expiryDateController,
                      label: 'Ngày kết thúc *',
                      icon: Icons.calendar_today,
                      readOnly: true,
                      onTap: () => _selectDate(context, _expiryDateController),
                      validator: (val) =>
                          val!.isEmpty ? 'Vui lòng chọn ngày' : null,
                      obscureText: false,
                    ),
                    const SizedBox(height: 16),

                    // Loại hình
                    CustomDropdownField<JobType>(
                      label: 'Loại hình *',
                      icon: Icons.work,
                      value: _selectedJobType,
                      hint: 'Chọn loại hình',
                      items: _jobTypes
                          .map(
                            (e) =>
                                DropdownMenuItem(value: e, child: Text(e.name)),
                          )
                          .toList(),
                      onChanged: (val) =>
                          setState(() => _selectedJobType = val),
                      validator: (val) => val == null ? 'Vui lòng chọn' : null,
                    ),
                    const SizedBox(height: 16),

                    // Kích hoạt
                    SwitchListTile(
                      title: const Text('Kích hoạt (hiển thị cho người dùng)'),
                      value: _isActive,
                      onChanged: (val) => setState(() => _isActive = val),
                      activeColor: AppPallete.primaryColor,
                      contentPadding: EdgeInsets.zero,
                    ),
                    const SizedBox(height: 16),

                    // Mô tả
                    CustomTextField(
                      controller: _descriptionController,
                      label: 'Mô tả *',
                      icon: Icons.description,
                      minLines: 5,
                      maxLines: 8,
                      validator: (val) =>
                          val!.isEmpty ? 'Không được để trống' : null,
                      obscureText: false,
                    ),
                    const SizedBox(height: 32),

                    // Nút submit
                    SizedBox(
                      width: double.infinity,
                      child: CustomElevatedButton(
                        text: widget.isEditMode ? 'Cập nhật' : 'Đăng tin',
                        onPressed: _submitForm,
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
    );
  }

  // Widget build multi-select cho Skill và Category
  Widget _buildMultiSelectChipField<T>({
    required String label,
    required IconData icon,
    required List<T> allItems,
    required List<T> selectedItems,
    required Function(List<T>) onChanged,
    String? Function(List<T>?)? validator,
  }) {
    // Giả sử T là Skill hoặc Category và có thuộc tính 'name' và 'id'
    String getItemName(T item) {
      if (item is Skill) return item.name;
      if (item is Category) return item.name;
      return item.toString();
    }

    // 💡 Lấy danh sách đề xuất (chỉ áp dụng cho Skill)
    List<T> getRecommendedItems(List<T> items) {
      if (T == Skill) {
        final Set<String> recommendedIds = {};
        for (final category in _selectedCategories) {
          recommendedIds.addAll(category.skills.map((s) => s.id));
        }

        // Lọc ra các skill được đề xuất dựa trên các Category đã chọn
        return items
            .where((item) => recommendedIds.contains((item as Skill).id))
            .cast<T>()
            .toList();
      }
      return allItems; // Trả về tất cả nếu là Category
    }

    // Sử dụng danh sách đề xuất cho Skills, nếu có Category được chọn
    final List<T> displayItems = (T == Skill && _selectedCategories.isNotEmpty)
        ? getRecommendedItems(allItems)
        : [];

    // Lọc các item đã chọn khỏi danh sách đề xuất để tránh trùng lặp
    final Set<T> recommendedSet = Set<T>.from(displayItems);
    final List<T> nonSelectedRecommended = displayItems
        .where((item) => !selectedItems.contains(item))
        .toList();

    return FormField<List<T>>(
      key: ValueKey('$label-${selectedItems.length}'),
      initialValue: selectedItems,
      validator: validator,
      builder: (formFieldState) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Label và Icon ---
            Row(
              children: [
                Icon(icon, color: AppPallete.mutedTextColor, size: 22),
                const SizedBox(width: 12),
                Text(
                  label,
                  style: TextStyle(
                    color: AppPallete.mutedTextColor,
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // --- Các chip đã chọn ---
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppPallete.inputBackgroundColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: formFieldState.hasError
                      ? Colors.red[700]!
                      : AppPallete.borderColor,
                  width: 1.5,
                ),
              ),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ...selectedItems.map((item) {
                    return Chip(
                      label: Text(getItemName(item)),
                      backgroundColor: AppPallete.primaryColor.withOpacity(0.1),
                      labelStyle: const TextStyle(
                        color: AppPallete.primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                      onDeleted: () {
                        // 💡 LOGIC XÓA
                        final newSelected = List<T>.from(selectedItems);
                        newSelected.remove(item);
                        onChanged(newSelected);
                        formFieldState.didChange(newSelected);
                      },
                      deleteIconColor: AppPallete.primaryColor,
                    );
                  }),
                  // --- Nút "Thêm" ---
                  ActionChip(
                    label: const Text('Thêm...'),
                    avatar: const Icon(Icons.add_circle_outline, size: 18),
                    backgroundColor: Colors.grey.shade200,
                    onPressed: () async {
                      await _showMultiSelectDialog(
                        context: context,
                        title: 'Chọn $label',
                        allItems: allItems,
                        selectedItems: selectedItems,
                        onConfirm: (selected) {
                          onChanged(selected);
                          formFieldState.didChange(selected);
                        },
                      );
                    },
                  ),
                ],
              ),
            ),

            // --- SKILL ĐỀ XUẤT (Chỉ hiển thị cho Skills) ---
            if (T == Skill && nonSelectedRecommended.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 10, left: 5),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Đề xuất từ danh mục:',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppPallete.mutedTextColor,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: nonSelectedRecommended.map((item) {
                        return ActionChip(
                          label: Text(getItemName(item)),
                          backgroundColor: AppPallete.primaryColor.withOpacity(
                            0.05,
                          ),
                          labelStyle: const TextStyle(
                            color: AppPallete.primaryColor,
                          ),
                          onPressed: () {
                            // Thêm skill đề xuất vào danh sách đã chọn
                            final newSelected = List<T>.from(selectedItems);
                            newSelected.add(item);
                            onChanged(newSelected);
                            formFieldState.didChange(newSelected);
                          },
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),

            // --- Hiển thị lỗi ---
            if (formFieldState.hasError)
              Padding(
                padding: const EdgeInsets.only(left: 12, top: 8),
                child: Text(
                  formFieldState.errorText!,
                  style: TextStyle(
                    color: Colors.red[700],
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  // Dialog chọn multi-select
  Future<void> _showMultiSelectDialog<T>({
    required BuildContext context,
    required String title,
    required List<T> allItems,
    required List<T> selectedItems,
    required Function(List<T>) onConfirm,
  }) async {
    String getItemName(T item) {
      if (item is Skill) return item.name;
      if (item is Category) return item.name;
      return item.toString();
    }

    final tempSelected = List<T>.from(selectedItems);
    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(title),
              content: SingleChildScrollView(
                child: Wrap(
                  spacing: 8,
                  children: allItems.map((item) {
                    final isSelected = tempSelected.contains(item);
                    return FilterChip(
                      label: Text(getItemName(item)),
                      selected: isSelected,
                      onSelected: (selected) {
                        setDialogState(() {
                          if (selected) {
                            tempSelected.add(item);
                          } else {
                            tempSelected.remove(item);
                          }
                        });
                      },
                      selectedColor: AppPallete.primaryColor.withOpacity(0.2),
                      checkmarkColor: AppPallete.primaryColor,
                    );
                  }).toList(),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => context.pop(),
                  child: const Text('Hủy'),
                ),
                ElevatedButton(
                  onPressed: () {
                    onConfirm(tempSelected);
                    context.pop();
                  },
                  child: const Text('Xác nhận'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

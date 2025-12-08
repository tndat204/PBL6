import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:motion_toast/motion_toast.dart';
import 'package:pbl6/core/theme/app_pallete.dart';
import 'package:pbl6/core/utils/currency_input_formatter.dart';
import 'package:pbl6/features/ai_matching/domain/usecases/summarize_jd_usecase.dart';
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
  // 🆕 UseCase cho AI Summarize
  late final SummarizeJdUseCase _summarizeJdUseCase;

  // Form State
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = true;
  // 🆕 State loading riêng cho AI
  bool _isAiProcessing = false;

  String? _companyId;
  Company? _myCompany;
  Job? _editingJob;

  // Data for Dropdowns
  List<Category> _categories = [];
  List<Skill> _allSkills = [];
  final List<ExperienceLevel> _expLevels = ExperienceLevel.values;
  final List<JobType> _jobTypes = JobType.values;

  // Controllers
  final _titleController = TextEditingController();
  // 🆕 Controller cho Description
  final _descriptionController = TextEditingController();
  final _salaryMinController = TextEditingController();
  final _salaryMaxController = TextEditingController();
  int _expMin = 0;
  int _expMax = 0;
  final _expiryDateController = TextEditingController();

  // Dropdown Values
  ExperienceLevel? _selectedExpLevel;
  JobType? _selectedJobType;

  // Địa chỉ
  List<Map<String, dynamic>> _provinces = [];
  List<Map<String, dynamic>> _wards = [];
  String? _selectedProvinceId;
  String? _selectedProvinceName;
  String? _selectedWardName;
  final _detailedAddressController = TextEditingController();

  // File JD
  String? _jdFilePath;
  String? _jdFileName;
  bool _isJdFilePicked = false;

  bool _isActive = true;

  // Multi-select values
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
    // 🆕 Inject UseCase
    _summarizeJdUseCase = GetIt.I<SummarizeJdUseCase>();

    _loadInitialData();
  }

  // 🆕 Hàm chọn file và gọi AI
  Future<void> _pickJdFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result == null || result.files.single.path == null) return;

    final filePath = result.files.single.path!;
    final fileName = result.files.single.name;
    final file = File(filePath);

    if (!fileName.toLowerCase().endsWith('.pdf')) {
      MotionToast.error(
        description: const Text('Chỉ chấp nhận PDF.'),
      ).show(context);
      return;
    }

    final fileSize = await file.length();
    if (fileSize > 5 * 1024 * 1024) {
      MotionToast.error(
        description: const Text('Kích thước file vượt quá 5MB.'),
      ).show(context);
      return;
    }

    setState(() {
      _jdFilePath = filePath;
      _jdFileName = fileName;
      _isJdFilePicked = true;
      _isAiProcessing = true;
    });

    await _processJdWithAi(filePath);
  }

  Future<void> _processJdWithAi(String filePath) async {
    try {
      final response = await _summarizeJdUseCase(
        SummarizeJdParams(jdFilePath: filePath),
      );

      if (response.success && response.summary != null) {
        final data = response.summary!;

        final StringBuffer sb = StringBuffer();

        if (data.summary != null && data.summary!.isNotEmpty) {
          sb.writeln("TÓM TẮT (Summary):");
          sb.writeln(data.summary);
          sb.writeln("");
        }

        if (data.keyResponsibilities.isNotEmpty) {
          sb.writeln("TRÁCH NHIỆM CHÍNH (Responsibility):");
          for (var item in data.keyResponsibilities) {
            sb.writeln("- $item");
          }
          sb.writeln("");
        }

        if (data.keyRequirements.isNotEmpty) {
          sb.writeln("YÊU CẦU CÔNG VIỆC (Requirement):");
          for (var item in data.keyRequirements) {
            sb.writeln("- $item");
          }
          sb.writeln("");
        }

        if (data.benefits.isNotEmpty) {
          sb.writeln("QUYỀN LỢI (Benefit):");
          for (var item in data.benefits) {
            sb.writeln("- $item");
          }
        }

        setState(() {
          _descriptionController.text = sb.toString();
          // Nếu AI trả về Title và người dùng chưa nhập title, điền luôn
          if (_titleController.text.isEmpty && data.jobTitle != null) {
            _titleController.text = data.jobTitle!;
          }
        });

        if (mounted) {
          MotionToast.success(
            description: const Text("AI đã trích xuất nội dung thành công!"),
          ).show(context);
        }
      }
    } catch (e) {
      if (mounted) {
        MotionToast.warning(
          description: Text("AI không thể đọc file này: $e"),
        ).show(context);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isAiProcessing = false; // Tắt loading AI
        });
      }
    }
  }

  Future<void> _loadInitialData() async {
    try {
      _companyId = await _authRepository.getCompanyId();
      if (_companyId == null) throw Exception("Không tìm thấy công ty");

      final results = await Future.wait([
        _getCompanyDetailsUseCase(_companyId!),
        _getAllCategoriesUseCase(),
        _getAllSkillsUseCase(),
        _authDataSource.fetchProvinces(),
        if (widget.isEditMode) _getJobDetailsUseCase(widget.jobId!),
      ]);

      _myCompany = results[0] as Company;
      _categories = results[1] as List<Category>;
      _allSkills = results[2] as List<Skill>;
      _provinces = results[3] as List<Map<String, dynamic>>;

      if (widget.isEditMode) {
        _editingJob = results[4] as Job;
        await _prefillForm();
      } else {
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

  Future<void> _prefillForm() async {
    if (_editingJob == null) return;
    final job = _editingJob!;

    _titleController.text = job.title;
    // 🆕 Prefill Description cũ
    _descriptionController.text = job.description;

    _salaryMinController.text = NumberFormat('#,###').format(job.salaryMin);
    _salaryMaxController.text = NumberFormat('#,###').format(job.salaryMax);
    _expMin = job.requiredYearsOfExpMin;
    _expMax = job.requiredYearsOfExpMax;
    _expiryDateController.text = DateFormat('dd/MM/yyyy').format(
      DateTime(job.expiryDate.year, job.expiryDate.month, job.expiryDate.day),
    );

    if (job.jdFile.isNotEmpty) {
      setState(() {
        _jdFileName = job.jdFile.split('/').last;
        _isJdFilePicked = true;
      });
    }

    _selectedExpLevel = job.experienceLevel;
    _selectedJobType = job.jobType;
    _isActive = job.status == JobStatus.ACTIVE;

    await _prefillAddress(job.location);

    _selectedSkills = _allSkills
        .where((s) => job.skillIds.contains(s.id))
        .toList();
    _selectedCategories = _categories
        .where((c) => job.categoryIds.contains(c.id))
        .toList();
  }

  Future<void> _prefillAddress(String location) async {
    if (location.isEmpty) return;
    final parts = location.split(',').map((e) => e.trim()).toList();

    String? initialWardName;
    String? initialProvinceName;
    String initialDetailedAddress = location;

    if (parts.length >= 3) {
      initialDetailedAddress = parts[0];
      initialWardName = parts[1];
      initialProvinceName = parts[2];
    }

    _detailedAddressController.text = initialDetailedAddress;

    if (initialProvinceName != null) {
      final prov = _provinces.firstWhere(
        (p) => p['province'] == initialProvinceName,
        orElse: () => {},
      );

      if (prov.isNotEmpty) {
        _selectedProvinceId = prov['id'];
        _selectedProvinceName = initialProvinceName;
        await _fetchWards(initialProvinceName);
        if (_wards.any((w) => w['name'] == initialWardName)) {
          _selectedWardName = initialWardName;
        }
      }
    }
  }

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

  Future<void> _fetchWards(String provinceName) async {
    final wards = await _authDataSource.fetchWards(provinceName);
    _wards = wards;
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
    final province = _provinces.firstWhere((p) => p['id'] == id);
    final provinceName = province['province'];

    setState(() {
      _selectedProvinceId = id;
      _selectedProvinceName = provinceName;
      _selectedWardName = null;
      _wards = [];
    });
    await _fetchWards(provinceName);
    setState(() {});
  }

  void _onWardChanged(String? name) {
    setState(() => _selectedWardName = name);
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

    final bool hasExistingJd =
        widget.isEditMode && (_editingJob?.jdFile.isNotEmpty ?? false);
    final bool isJdRequired = !widget.isEditMode || !hasExistingJd;

    if (isJdRequired && _jdFilePath == null) {
      MotionToast.error(
        description: Text('Vui lòng tải lên file Mô tả công việc (PDF)'),
      ).show(context);
      return;
    }

    // Kiểm tra description
    if (_descriptionController.text.trim().isEmpty) {
      MotionToast.error(
        description: const Text('Mô tả công việc không được để trống'),
      ).show(context);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final jobData = Job(
        id: _editingJob?.id ?? '',
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
        categoryIds: _selectedCategories.map((c) => c.id).toList(),
        skillIds: _selectedSkills.map((s) => s.id).toList(),

        location: [
          _detailedAddressController.text.trim(),
          _selectedWardName ?? '',
          _selectedProvinceName ?? '',
        ].where((e) => e.isNotEmpty).join(', '),
        expiryDate: _expiryDateController.text.isNotEmpty
            ? (() {
                return DateFormat(
                  'dd/MM/yyyy',
                ).parseStrict(_expiryDateController.text);
              })()
            : DateTime.now(),
        postedBy: '',
        jdFile: (widget.isEditMode && _jdFilePath == null)
            ? _editingJob!.jdFile
            : '',
      );

      final filePathToSend = _jdFilePath;

      if (widget.isEditMode) {
        await _updateJobUseCase(
          UpdateJobParams(
            jobId: widget.jobId!,
            job: jobData,
            jdFilePath: filePathToSend,
          ),
        );
      } else {
        await _createJobUseCase(
          CreateJobParams(job: jobData, jdFilePath: filePathToSend),
        );
      }

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
      backgroundColor: Colors.white,
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

                    // --- SECTION JD FILE & AI ---
                    const Text(
                      'Tải file Mô tả công việc (JD) *',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Hệ thống sẽ dùng AI để tự động trích xuất nội dung vào phần mô tả bên dưới.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const SizedBox(height: 8),

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: _isJdFilePicked
                              ? AppPallete.primaryColor
                              : Colors.grey.shade300,
                          width: _isJdFilePicked ? 2.0 : 1.0,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                _isJdFilePicked
                                    ? Icons.description
                                    : Icons.upload_file,
                                color: _isJdFilePicked
                                    ? AppPallete.primaryColor
                                    : Colors.grey.shade600,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _jdFileName ??
                                      (widget.isEditMode &&
                                              (_editingJob?.jdFile.isNotEmpty ??
                                                  false)
                                          ? 'File cũ: ${(_editingJob?.jdFile.split('/').last ?? 'JD.pdf')}'
                                          : 'Chưa chọn file PDF nào'),
                                  style: TextStyle(
                                    color:
                                        _isJdFilePicked ||
                                            (widget.isEditMode &&
                                                (_editingJob
                                                        ?.jdFile
                                                        .isNotEmpty ??
                                                    false))
                                        ? Colors.black87
                                        : Colors.grey.shade600,
                                    fontWeight:
                                        _isJdFilePicked ||
                                            (widget.isEditMode &&
                                                (_editingJob
                                                        ?.jdFile
                                                        .isNotEmpty ??
                                                    false))
                                        ? FontWeight.w600
                                        : FontWeight.w500,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (_isJdFilePicked)
                                IconButton(
                                  icon: const Icon(
                                    Icons.close,
                                    color: Colors.red,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _jdFilePath = null;
                                      _jdFileName = null;
                                      _isJdFilePicked = false;
                                    });
                                  },
                                ),
                            ],
                          ),

                          // 🆕 HIỂN THỊ LOADING AI
                          if (_isAiProcessing)
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 12.0,
                              ),
                              child: Row(
                                children: const [
                                  SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  ),
                                  SizedBox(width: 12),
                                  Text(
                                    "AI đang đọc file & tạo mô tả...",
                                    style: TextStyle(
                                      color: AppPallete.primaryColor,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: _pickJdFile,
                              icon: const Icon(Icons.folder_open),
                              label: Text(
                                _isJdFilePicked
                                    ? 'Chọn lại file'
                                    : 'Chọn file JD (PDF)',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 🆕 MÔ TẢ CÔNG VIỆC (EDITABLE)
                    CustomTextField(
                      controller: _descriptionController,
                      label: 'Mô tả công việc (AI Generated) *',
                      icon: Icons.notes,
                      maxLines: 10, // Cho phép nhiều dòng
                      validator: (val) =>
                          val!.isEmpty ? 'Vui lòng nhập mô tả' : null,
                      obscureText: false,
                    ),
                    const SizedBox(height: 16),
                    // -----------------------------

                    // Danh mục
                    _buildMultiSelectChipField<Category>(
                      label: 'Danh mục *',
                      icon: Icons.category,
                      allItems: _categories,
                      selectedItems: _selectedCategories,
                      onChanged: _onCategoryChanged,
                      validator: (list) =>
                          list!.isEmpty ? 'Phải chọn ít nhất 1' : null,
                    ),
                    const SizedBox(height: 16),

                    // Kỹ năng
                    _buildMultiSelectChipField<Skill>(
                      label: 'Kỹ năng *',
                      icon: Icons.code,
                      allItems: _allSkills,
                      selectedItems: _selectedSkills,
                      onChanged: _onSkillChanged,
                      validator: (list) =>
                          list!.isEmpty ? 'Phải chọn ít nhất 1' : null,
                    ),
                    const SizedBox(height: 16),

                    // Công ty
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
                      label: 'Tỉnh/Thành phố',
                      icon: Icons.location_on_outlined,
                      value: _selectedProvinceId,
                      items: _provinces.map((p) {
                        return DropdownMenuItem<String>(
                          value: p['id'],
                          child: Text(p['province']),
                        );
                      }).toList(),
                      onChanged: _onProvinceChanged,
                      validator: (v) =>
                          v == null ? 'Chọn tỉnh/thành phố' : null,
                    ),

                    const SizedBox(height: 16),
                    CustomDropdownField<String>(
                      label: 'Phường/Xã',
                      icon: Icons.location_city_outlined,
                      value: _selectedWardName,
                      items: _wards.map((w) {
                        final name = w['name'] as String;
                        return DropdownMenuItem<String>(
                          value: name,
                          child: Text(name),
                        );
                      }).toList(),
                      onChanged: _wards.isEmpty
                          ? null
                          : (v) {
                              setState(() => _selectedWardName = v);
                            },
                      validator: (v) {
                        if (_wards.isNotEmpty && v == null) {
                          return "Chọn phường/xã";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      label: 'Địa chỉ chi tiết',
                      icon: Icons.place,
                      obscureText: false,
                      controller: _detailedAddressController,
                      validator: (value) =>
                          value!.isEmpty ? 'Nhập địa chỉ chi tiết' : null,
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

  Widget _buildMultiSelectChipField<T>({
    required String label,
    required IconData icon,
    required List<T> allItems,
    required List<T> selectedItems,
    required Function(List<T>) onChanged,
    String? Function(List<T>?)? validator,
  }) {
    String getItemName(T item) {
      if (item is Skill) return item.name;
      if (item is Category) return item.name;
      return item.toString();
    }

    List<T> getRecommendedItems(List<T> items) {
      if (T == Skill) {
        final Set<String> recommendedIds = {};
        for (final category in _selectedCategories) {
          recommendedIds.addAll(category.skills.map((s) => s.id));
        }
        return items
            .where((item) => recommendedIds.contains((item as Skill).id))
            .cast<T>()
            .toList();
      }
      return allItems;
    }

    final List<T> displayItems = (T == Skill && _selectedCategories.isNotEmpty)
        ? getRecommendedItems(allItems)
        : [];

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
            Row(
              children: [
                Icon(icon, color: AppPallete.mutedTextColor, size: 22),
                const SizedBox(width: 12),
                Text(
                  label,
                  style: TextStyle(
                    color: AppPallete.mutedTextColor,
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

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
                      backgroundColor: Colors.white,

                      side: BorderSide(
                        color: AppPallete.primaryColor.withOpacity(0.5),
                      ),

                      labelStyle: const TextStyle(
                        color: AppPallete.primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                      onDeleted: () {
                        final newSelected = List<T>.from(selectedItems);
                        newSelected.remove(item);
                        onChanged(newSelected);
                        formFieldState.didChange(newSelected);
                      },
                      deleteIconColor: AppPallete.primaryColor,
                    );
                  }),
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
              title: Text(
                title,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),

              content: SizedBox(
                width: double.maxFinite,
                height: 400,
                child: Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: allItems.length,
                        itemBuilder: (context, index) {
                          final item = allItems[index];
                          final isSelected = tempSelected.contains(item);

                          return CheckboxListTile(
                            title: Text(
                              getItemName(item),
                              style: TextStyle(
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                                color: Colors.black87,
                              ),
                            ),
                            value: isSelected,
                            activeColor: AppPallete.primaryColor,
                            checkColor: Colors.white,
                            controlAffinity: ListTileControlAffinity.leading,
                            contentPadding: EdgeInsets.zero,
                            onChanged: (bool? value) {
                              setDialogState(() {
                                if (value == true) {
                                  tempSelected.add(item);
                                } else {
                                  tempSelected.remove(item);
                                }
                              });
                            },
                          );
                        },
                      ),
                    ),
                    const Divider(color: Colors.grey),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => context.pop(),
                  child: const Text(
                    'Hủy',
                    style: TextStyle(color: Color.fromARGB(205, 158, 158, 158)),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    onConfirm(tempSelected);
                    context.pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppPallete.primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
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

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:pbl6/core/theme/app_pallete.dart';
import 'package:pbl6/features/recruiter/job/domain/usecases/get_my_posted_job_usecase.dart';
import 'package:pbl6/features/recruiter/job/presentation/widgets/recruiter_job_card.dart';
import 'package:pbl6/features/shared/auth/data/datasources/auth_remote_datasource.dart';
import 'package:pbl6/features/shared/auth/domain/repositories/auth_repository.dart';
import 'package:pbl6/features/shared/category/domain/entities/category.dart';
import 'package:pbl6/features/shared/category/domain/usecases/get_all_categories_usecase.dart';
import 'package:pbl6/features/shared/company/domain/entities/company.dart';
import 'package:pbl6/features/shared/company/domain/usecases/get_company_details_usecase.dart';
import 'package:pbl6/features/shared/job/domain/entities/job.dart';
import 'package:pbl6/features/shared/widgets/custom_app_bar.dart';
import 'package:pbl6/features/user/jobs/presentation/models/category_ui_model.dart';
import 'package:pbl6/features/user/jobs/presentation/widgets/category_chip.dart';
import 'package:pbl6/features/user/jobs/presentation/widgets/filter_bottom_sheet_content.dart';
import 'package:pbl6/features/user/jobs/presentation/widgets/search_bar.dart';

class RecruiterJobPage extends StatefulWidget {
  const RecruiterJobPage({super.key});

  @override
  State<RecruiterJobPage> createState() => _RecruiterJobPageState();
}

class _RecruiterJobPageState extends State<RecruiterJobPage> {
  // --- Use Cases & Services ---
  late final GetMyPostedJobsUseCase _getMyPostedJobsUseCase;
  late final AuthRepository _authRepository;
  late final AuthRemoteDataSource _authDataSource;
  late final GetCompanyDetailsUseCase _getCompanyDetailsUseCase; // Sửa: Thêm
  late final GetAllCategoriesUseCase _getAllCategoriesUseCase; // Sửa: Thêm

  // --- Data Lists ---
  List<Job> _allJobs = [];
  List<Job> _filteredJobs = [];
  List<Map<String, dynamic>> _provinces = [];
  List<CategoryUiModel> _uiCategories = []; // Sửa: Thêm
  Company? _myCompany; // Sửa: Thêm

  // --- Filter State ---
  String? _companyId;
  String? _searchQuery;
  double? _filterMinSalary;
  double? _filterMaxSalary;
  String? _filterLocationProvince;
  String? _filterJobType;
  DateTime? _filterExpiryDateBefore;
  JobStatus? _filterStatus = JobStatus.ACTIVE;
  String? _selectedCategoryId = _allCategoriesId; // Sửa: Thêm

  // --- UI State ---
  bool _isLoading = true;
  bool _isLoadingProvinces = false;

  // --- Constants ---
  final List<String> _jobTypeNames = JobType.values.map((e) => e.name).toList();
  static const String _allCategoriesId = 'ALL_CATEGORIES'; // Sửa: Thêm
  static const Map<JobStatus, String> _jobStatusNames = {
  JobStatus.ACTIVE: 'Đang hiển thị',
  JobStatus.INACTIVE: 'Đã ẩn',
  JobStatus.CLOSED: 'Đã đóng',
};
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _getMyPostedJobsUseCase = GetIt.I<GetMyPostedJobsUseCase>();
      _authRepository = GetIt.I<AuthRepository>();
      _authDataSource = GetIt.I<AuthRemoteDataSource>();
      _getCompanyDetailsUseCase = GetIt.I<GetCompanyDetailsUseCase>();
      _getAllCategoriesUseCase = GetIt.I<GetAllCategoriesUseCase>();

      await _loadAllData();
    });
  }

  Future<void> _loadProvinces() async {
    if (_provinces.isNotEmpty || _isLoadingProvinces) return;
    if (mounted) setState(() => _isLoadingProvinces = true);
    try {
      _provinces = await _authDataSource.fetchProvinces();
    } catch (e) {
      print("Error loading provinces: $e");
    } finally {
      if (mounted) setState(() => _isLoadingProvinces = false);
    }
  }

  // SỬA: Nâng cấp hàm tải dữ liệu
  Future<void> _loadAllData({bool refresh = false}) async {
    if (refresh || _allJobs.isEmpty) {
      if (mounted) setState(() => _isLoading = true);
    }

    try {
      // 1. Tải song song Tỉnh + Category + CompanyID
      final results = await Future.wait([
        _loadProvinces(), // Hàm này không trả về giá trị, chỉ cập nhật _provinces
        _getAllCategoriesUseCase(), // Lỗi xảy ra nếu nó chưa được init
        _authRepository.getCompanyId(),
      ]);

      // Phải lấy kết quả tại index 1 và 2 (vì _loadProvinces() là void/Future<void>)
      final categories = results[1] as List<Category>;
      _companyId = results[2] as String?;

      if (_companyId == null) {
        throw Exception("Không tìm thấy companyId, vui lòng đăng nhập lại");
      }

      // 2. Tải song song Chi tiết Công ty + Danh sách Jobs
      final results2 = await Future.wait([
        _getCompanyDetailsUseCase(_companyId!),
        _getMyPostedJobsUseCase(
          GetMyPostedJobsParams(companyId: _companyId!, status: _filterStatus),
        ),
      ]);

      _myCompany = results2[0] as Company;
      final jobs = results2[1] as List<Job>;

      // 3. Xử lý Categories
      if (refresh || _uiCategories.length <= 1) {
        _uiCategories = categories
            .map((c) => CategoryUiModel.fromEntity(c, isSelected: false))
            .toList();
        _uiCategories.insert(
          0,
          CategoryUiModel(
            category: const Category(
              id: _allCategoriesId,
              name: 'Tất cả',
              skills: [],
            ),
            isSelected: true,
          ),
        );
        _selectedCategoryId = _allCategoriesId;
      }

      // 4. Gán Company Info vào Jobs
      _allJobs = jobs
          .map(
            (job) => job.copyWith(
              companyName: _myCompany?.name,
              logoUrl: _myCompany?.logoUrl,
            ),
          )
          .toList();

      if (mounted) {
        setState(() {
          _filterJobs(); // Áp dụng bộ lọc
        });
      }
    } catch (e) {
      print("Lỗi tải Job của Recruiter: $e");
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lỗi tải dữ liệu: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // SỬA: Thêm logic lọc Category
  void _filterJobs({String? query}) {
    if (query != null) _searchQuery = query;

    setState(() {
      _filteredJobs = _allJobs.where((job) {
        // Category
        final matchCategory =
            (_selectedCategoryId == null ||
            _selectedCategoryId == _allCategoriesId ||
            job.categoryIds.contains(_selectedCategoryId));

        // Search Query
        final cleanQuery = _searchQuery?.trim().toLowerCase();
        final matchQuery = (cleanQuery == null || cleanQuery.isEmpty)
            ? true
            : (job.title.trim().toLowerCase().contains(cleanQuery));

        // Salary
        final matchSalary =
            (_filterMinSalary == null || job.salaryMin >= _filterMinSalary!) &&
            (_filterMaxSalary == null || job.salaryMax <= _filterMaxSalary!);

        // Location
        final matchLocation =
            (_filterLocationProvince == null ||
                job.location.contains(_filterLocationProvince!)) ||
            (job.locationProvince == _filterLocationProvince);

        // Job Type
        final matchJobType =
            (_filterJobType == null || job.jobType.name == _filterJobType);

        // Expiry Date
        final matchExpiry =
            (_filterExpiryDateBefore == null ||
            !job.expiryDate.isAfter(_filterExpiryDateBefore!));

        // Combine
        return matchCategory && // THÊM
            matchQuery &&
            matchSalary &&
            matchLocation &&
            matchJobType &&
            matchExpiry;
      }).toList();
    });
  }

  // SỬA: Thêm hàm xử lý chọn Category
  void _handleCategorySelected(CategoryUiModel selectedModel) {
    if (_selectedCategoryId == selectedModel.category.id) return;
    setState(() {
      for (int i = 0; i < _uiCategories.length; i++) {
        _uiCategories[i] = _uiCategories[i].copyWith(
          isSelected: _uiCategories[i].category.id == selectedModel.category.id,
        );
      }
      _selectedCategoryId = selectedModel.category.id;
    });
    _filterJobs();
  }

  void _onJobDeleted(String jobId) {
    setState(() {
      _allJobs.removeWhere((job) => job.id == jobId);
      _filteredJobs.removeWhere((job) => job.id == jobId);
    });
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet<FilterValues>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => FilterBottomSheetContent(
        initialFilters: FilterValues(
          minSalary: _filterMinSalary,
          maxSalary: _filterMaxSalary,
          locationProvince: _filterLocationProvince,
          jobType: _filterJobType,
          expiryDateBefore: _filterExpiryDateBefore,
        ),
        provinces: _provinces,
        jobTypeNames: _jobTypeNames,
        isLoadingProvinces: _isLoadingProvinces,
      ),
    ).then((returnedFilters) {
      if (returnedFilters != null) {
        setState(() {
          _filterMinSalary = returnedFilters.minSalary;
          _filterMaxSalary = returnedFilters.maxSalary;
          _filterLocationProvince = returnedFilters.locationProvince;
          _filterJobType = returnedFilters.jobType;
          _filterExpiryDateBefore = returnedFilters.expiryDateBefore;
        });
        _filterJobs(); // Áp dụng bộ lọc mới
      }
    });
  }

  Widget _buildStatusFilters() {
    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemBuilder: (context, index) {
          final status = JobStatus.values[index];
          final isSelected = _filterStatus == status;
          final statusName = _jobStatusNames[status] ?? status.name;

          // LOGIC MỚI: Xác định màu nền khi được chọn (selectedColor)
          Color selectedChipColor;
          Color selectedBorderColor;
          
          if (status == JobStatus.ACTIVE) {
            selectedChipColor = Colors.green; 
            selectedBorderColor = Colors.green;
          } else if (status == JobStatus.INACTIVE) {
            selectedChipColor = Colors.orange; 
            selectedBorderColor = Colors.orange;
          } else { // JobStatus.CLOSED
            selectedChipColor = Colors.red; // Màu đỏ đậm
            selectedBorderColor = Colors.red;
          }

          return ChoiceChip(
            label: Text(statusName),
            selected: isSelected,
            onSelected: (selected) {
              if (selected) {
                setState(() {
                  _filterStatus = status;
                });
                _loadAllData(refresh: true);
              }
            },
            // Áp dụng màu sắc tùy chỉnh theo trạng thái
            selectedColor: selectedChipColor, 
            labelStyle: TextStyle(
              color: isSelected ? Colors.white : Colors.black87,
              fontWeight: FontWeight.w600,
            ),
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(
                color: isSelected ? selectedBorderColor : AppPallete.borderColor,
              ),
            ),
          );
        },
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemCount: JobStatus.values.length,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // SỬA: Đổi Scaffold thành cấu trúc giống JobPage (CustomScrollView)
    return Scaffold(
      backgroundColor: Colors.white, // Nền trắng cho nội dung cuộn
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: AppPallete.backgroundGradient,
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: () => _loadAllData(refresh: true),
            color: AppPallete.primaryColor,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                // --- Header (CustomAppBar, Tiêu đề, Search, Filter) ---
                SliverAppBar(
                  pinned: false,
                  floating: true,
                  snap: false,
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  toolbarHeight: 0, // Ẩn toolbar mặc định
                  flexibleSpace: FlexibleSpaceBar(
                    background: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomAppBar(),
                        SizedBox(height: 16),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'Quản lý tin tuyển dụng', // hoặc copy style JobPage
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.w400,
                                  fontSize: 40, // giống JobPage
                                  color: AppPallete.textColor,
                                  height: 1.3,
                                  fontFamily: 'Italianno',
                                ),
                          ),
                        ),
                        const SizedBox(height: 18),
                        // SỬA: Đặt SearchBar và Nút Add cạnh nhau
                        CustomSearchBar(
                          onSearchChanged: (query) => _filterJobs(query: query),
                          onFilterPressed: _showFilterBottomSheet,
                        ),
                        
                      ],
                    ),
                  ),
                  // SỬA: Tăng chiều cao
                  expandedHeight: 250,
                ),

                // --- Main Content (Danh sách Jobs) ---
                SliverToBoxAdapter(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(24),
                      ),
                      border: Border(
                        top: BorderSide(color: Colors.grey.shade200, width: 1),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20),
                        // Categories
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'Danh mục',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 40,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            itemCount: _uiCategories.length,
                            itemBuilder: (context, index) {
                              final uiModel = _uiCategories[index];
                              return CategoryChip(
                                uiModel: uiModel,
                                onSelected: _handleCategorySelected,
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 24),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'Lọc theo trạng thái',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildStatusFilters(),

                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: ElevatedButton.icon(
                              onPressed: () async {
                                final result = await context.push(
                                  '/recruiter/jobs/upsert',
                                );
                                if (result == true) {
                                  _loadAllData(refresh: true);
                                }
                              },
                              icon: const Icon(Icons.add),
                              label: const Text('Thêm mới'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppPallete.primaryColor,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                            ),
                          ),
                        ),

                      
                        // --- Danh sách Job ---
                        _isLoading
                            ? const Padding(
                                padding: EdgeInsets.symmetric(vertical: 64),
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              )
                            : _filteredJobs.isEmpty
                            ? Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 64,
                                  horizontal: 24,
                                ),
                                child: Center(
                                  child: Text(
                                    _allJobs.isEmpty
                                        ? 'Bạn chưa đăng tin tuyển dụng nào.'
                                        : 'Không có tin nào khớp với bộ lọc.',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                              )
                            : ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: _filteredJobs.length,
                                padding: const EdgeInsets.only(
                                  top: 8,
                                  bottom: 80,
                                ),
                                itemBuilder: (context, index) {
                                  return RecruiterJobCard(
                                    job: _filteredJobs[index],
                                    onEdit: () async {
                                      final result = await context.push(
                                        '/recruiter/jobs/upsert',
                                        extra: _filteredJobs[index].id,
                                      );
                                      if (result == true) {
                                        _loadAllData(refresh: true);
                                      }
                                    },
                                    onDelete: () {
                                      _onJobDeleted(_filteredJobs[index].id);
                                    },
                                  );
                                },
                              ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      // SỬA: Xóa FAB ở đây (vì đã chuyển vào Header)
    );
  }
}

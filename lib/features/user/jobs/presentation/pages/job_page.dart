import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:pbl6/core/theme/app_pallete.dart';
import 'package:pbl6/features/shared/auth/data/datasources/auth_remote_datasource.dart'; // Import Auth source
import 'package:pbl6/features/shared/category/domain/entities/category.dart';
import 'package:pbl6/features/shared/category/domain/usecases/get_all_categories_usecase.dart';
import 'package:pbl6/features/shared/company/domain/usecases/get_company_details_usecase.dart';
import 'package:pbl6/features/shared/job/domain/entities/job.dart';
import 'package:pbl6/features/shared/user/domain/entities/user.dart';
import 'package:pbl6/features/shared/user/domain/usecases/get_my_info_usecase.dart';
import 'package:pbl6/features/shared/user/presentation/providers/user_provider.dart';
import 'package:pbl6/features/shared/widgets/custom_app_bar.dart';
import 'package:pbl6/features/user/jobs/domain/usecases/get_all_jobs_usecase.dart';
import 'package:pbl6/features/user/jobs/presentation/models/category_ui_model.dart';
import 'package:pbl6/features/user/jobs/presentation/widgets/category_chip.dart';
import 'package:pbl6/features/user/jobs/presentation/widgets/filter_bottom_sheet_content.dart';
import 'package:pbl6/features/user/jobs/presentation/widgets/job_card.dart';
import 'package:pbl6/features/user/jobs/presentation/widgets/search_bar.dart';
import 'package:provider/provider.dart';

class JobPage extends StatefulWidget {
  const JobPage({super.key});

  @override
  State<JobPage> createState() => _JobPageState();
}

class _JobPageState extends State<JobPage> {
  // --- Use Cases & Services ---
  late final GetAllJobsUseCase _getAllJobsUseCase;
  late final GetAllCategoriesUseCase _getAllCategoriesUseCase;
  late final GetMyInfoUseCase _getMyInfoUseCase;
  late final GetCompanyDetailsUseCase _getCompanyDetailsUseCase;
  late final AuthRemoteDataSource _authDataSource; // ✅ Use AuthRemoteDataSource

  // --- Data Lists ---
  List<CategoryUiModel> _uiCategories = [];
  List<Job> _allJobs = [];
  List<Job> _filteredJobs = [];
  User? _loadedUser;
  List<Map<String, dynamic>> _provinces = [];

  // --- Filter State ---
  String? _selectedCategoryId = _allCategoriesId;
  String? _searchQuery;
  double? _filterMinSalary;
  double? _filterMaxSalary;
  String? _filterLocationProvince; // Stores Province Name
  String? _filterJobType; // Stores JobType enum NAME ('FULL_TIME')
  DateTime? _filterExpiryDateBefore;

  // --- UI State ---
  bool _isLoading = true;
  bool _isLoadingProvinces = false;

  // --- Constants ---
  // ✅ Generate job type names directly from the JobType enum
  final List<String> _jobTypeNames = JobType.values.map((e) => e.name).toList();
  static const String _allCategoriesId = 'ALL_CATEGORIES';

  @override
  void initState() {
    super.initState();
    _getAllJobsUseCase = GetIt.I<GetAllJobsUseCase>();
    _getAllCategoriesUseCase = GetIt.I<GetAllCategoriesUseCase>();
    _getMyInfoUseCase = GetIt.I<GetMyInfoUseCase>();
    _getCompanyDetailsUseCase = GetIt.I<GetCompanyDetailsUseCase>();
    _authDataSource = GetIt.I<AuthRemoteDataSource>(); // ✅ Get from GetIt

    // SỬA: Gọi hàm tải dữ liệu mới
    _loadAllData();
    // _loadInitialData(); // XÓA
    // _loadProvinces(); // XÓA
  }

  // --- Data Loading ---

  // SỬA: Hàm này giờ chỉ tải tỉnh
  Future<void> _loadProvinces() async {
    if (_provinces.isNotEmpty || _isLoadingProvinces) return;
    
    // SỬA: Để hàm gọi quản lý trạng thái loading
    if (mounted) setState(() => _isLoadingProvinces = true);
    
    try {
      _provinces = await _authDataSource.fetchProvinces(); // ✅ Use AuthDataSource
      print("Provinces loaded: ${_provinces.length}");
    } catch (e) {
      print("Error loading provinces: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi tải danh sách tỉnh/thành phố: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoadingProvinces = false);
    }
  }

  // SỬA: Hàm _loadInitialData giờ là một phần của _loadAllData
  // và không tự xử lý _isLoading
  Future<void> _loadInitialData({bool refresh = false}) async {
    try {
      // Load User Info
      if (refresh || context.read<UserProvider>().user == null) {
        final userEntity = await _getMyInfoUseCase();
        _loadedUser = User.fromAuthEntity(userEntity);
        if (mounted) context.read<UserProvider>().setUser(_loadedUser!);
      } else {
        _loadedUser = context.read<UserProvider>().user;
      }

      // Load Categories
      if (refresh || _uiCategories.length <= 1) {
        final categories = await _getAllCategoriesUseCase();
        _uiCategories = categories
            .map((c) => CategoryUiModel.fromEntity(c, isSelected: false))
            .toList();
        _uiCategories.insert(
          0,
          CategoryUiModel(
            category:
                const Category(id: _allCategoriesId, name: 'Tất cả', skills: []),
            isSelected: true,
          ),
        );
        _selectedCategoryId = _allCategoriesId;
      }

      // Load Jobs & Company Details
      // SỬA: _provinces bây giờ ĐÃ ĐƯỢC ĐẢM BẢO là đã tải
      final jobs = await _getAllJobsUseCase();
      final jobsWithCompany = await Future.wait(
        jobs.map((job) async {
          try {
            final company = await _getCompanyDetailsUseCase(job.companyId);
            String? provinceName;
            // ✅ Refined province extraction logic
            if (company.address != null && company.address!.isNotEmpty) {
              final parts =
                  company.address!.split(',').map((e) => e.trim()).toList();
              if (parts.isNotEmpty) {
                // Try matching the last part with loaded provinces
                final potentialProvince = parts.last;
                // SỬA: Logic này giờ sẽ hoạt động vì _provinces đã được tải
                final provinceExists =
                    _provinces.any((p) => p['province'] == potentialProvince); // SỬA 'name' -> 'province'
                if (provinceExists) {
                  provinceName = potentialProvince;
                } else if (parts.length > 1) {
                  // Fallback: try the second to last part if the last wasn't a province
                  final secondLast = parts[parts.length - 2];
                  final secondProvinceExists =
                      _provinces.any((p) => p['province'] == secondLast); // SỬA 'name' -> 'province'
                  if (secondProvinceExists) {
                    provinceName = secondLast;
                  }
                }
              } else {
                provinceName = company.address;
              }
            }

            return job.copyWith(
              companyName: company.name,
              logoUrl: company.logoUrl,
              locationProvince: provinceName, // Assign extracted province
            );
          } catch (e) {
            print("Error getting company details for job ${job.id}: $e");
            return job;
          }
        }),
      );

      _allJobs = jobsWithCompany;
      _filterJobs();
    } catch (e) {
      // Ném lỗi ra để _loadAllData có thể bắt
      print("Error in _loadInitialData: $e");
      rethrow;
    }
  }

  // SỬA: Hàm mới để điều phối
  Future<void> _loadAllData({bool refresh = false}) async {
    if (refresh || _allJobs.isEmpty) {
      if (mounted) setState(() => _isLoading = true);
    }

    try {
      // 1. LUÔN TẢI TỈNH TRƯỚC (vì _loadInitialData cần)
      await _loadProvinces();

      // 2. SAU ĐÓ TẢI DỮ LIỆU CÒN LẠI
      await _loadInitialData(refresh: refresh);

    } catch (e) {
      print("Error loading all data: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi tải dữ liệu: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // --- Filtering Logic ---
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

  void _filterJobs({String? query}) {
    if (query != null) _searchQuery = query;

    setState(() {
      _filteredJobs = _allJobs.where((job) {
        // Category
        final matchCategory = (_selectedCategoryId == null ||
            _selectedCategoryId == _allCategoriesId ||
            job.categoryIds.contains(_selectedCategoryId));

        // Search Query
        final cleanQuery = _searchQuery?.trim().toLowerCase();
        final matchQuery = (cleanQuery == null || cleanQuery.isEmpty)
            ? true
            : (job.title.trim().toLowerCase().contains(cleanQuery) ||
                (job.companyName?.trim().toLowerCase().contains(cleanQuery) ??
                    false));

        // Salary (Compare int with double?)
        final matchSalary = (_filterMinSalary == null ||
                job.salaryMin >= _filterMinSalary!) && // Direct int comparison is fine if filter is double
            (_filterMaxSalary == null || job.salaryMax <= _filterMaxSalary!);

        // SỬA: Logic lọc địa điểm chính xác hơn
        // Giờ chúng ta lọc dựa trên `locationProvince` đã được trích xuất
        final matchLocation = (_filterLocationProvince == null ||
                job.locationProvince == _filterLocationProvince) ||
            // Fallback nếu locationProvince bị null,
            // thì kiểm tra location thô
            (job.locationProvince == null &&
                job.location
                    .toLowerCase()
                    .contains(_filterLocationProvince!.toLowerCase()));

        // Job Type (Compare enum.name with String?)
        final matchJobType =
            (_filterJobType == null || job.jobType.name == _filterJobType);

        // Expiry Date (Compare DateTime with DateTime?)
        final matchExpiry = (_filterExpiryDateBefore == null ||
            !job.expiryDate.isAfter(_filterExpiryDateBefore!)); // expiry <= filterDate

        // Combine
        return matchCategory &&
            matchQuery &&
            matchSalary &&
            matchLocation &&
            matchJobType &&
            matchExpiry;
      }).toList();
    });
  }

  // --- Show Filter Bottom Sheet ---
  void _showFilterBottomSheet() {
    // SỬA: Không cần kiểm tra ở đây nữa vì _provinces đã được tải
    // if (_isLoadingProvinces && _provinces.isEmpty) _loadProvinces();

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
          jobType: _filterJobType, // Pass enum name string
          expiryDateBefore: _filterExpiryDateBefore,
        ),
        provinces: _provinces, // SỬA: Giờ _provinces đã đầy đủ
        jobTypeNames: _jobTypeNames, // Pass enum name strings
        // SỬA: _isLoadingProvinces sẽ là false sau khi _loadAllData chạy
        isLoadingProvinces: _isLoadingProvinces, 
      ),
    ).then((returnedFilters) {
      if (returnedFilters != null) {
        setState(() {
          _filterMinSalary = returnedFilters.minSalary;
          _filterMaxSalary = returnedFilters.maxSalary;
          _filterLocationProvince = returnedFilters.locationProvince;
          _filterJobType = returnedFilters.jobType; // Store enum name string
          _filterExpiryDateBefore = returnedFilters.expiryDateBefore;
        });
        _filterJobs();
      }
    });
  }

  // --- Build Method ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: AppPallete.backgroundGradient,
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: (_isLoading && _allJobs.isEmpty)
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                  // SỬA: Gọi hàm tải dữ liệu tổng hợp
                  onRefresh: () => _loadAllData(refresh: true),
                  color: AppPallete.primaryColor,
                  child: CustomScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    slivers: [
                      // --- Header ---
                      SliverAppBar(
                        pinned: false,
                        floating: true,
                        snap: false,
                        backgroundColor: Colors.transparent,
                        elevation: 0,
                        toolbarHeight: 0,
                        flexibleSpace: FlexibleSpaceBar(
                          background: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CustomAppBar(),
                              const SizedBox(height: 16),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 16),
                                child: Text(
                                  'Chúng tôi giúp bạn nhận được\ncông việc bạn xứng đáng!',
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineSmall
                                      ?.copyWith(
                                        fontWeight: FontWeight.w400,
                                        fontSize: 40,
                                        color: AppPallete.textColor,
                                        height: 1.3,
                                        fontFamily: 'Italianno',
                                      ),
                                ),
                              ),
                              const SizedBox(height: 18),
                              CustomSearchBar(
                                onSearchChanged: (query) =>
                                    _filterJobs(query: query),
                                onFilterPressed: _showFilterBottomSheet,
                              ),
                              const SizedBox(height: 20),
                            ],
                          ),
                        ),
                        expandedHeight: 300,
                      ),

                      // --- Main Content ---
                      SliverToBoxAdapter(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius:
                                const BorderRadius.vertical(top: Radius.circular(24)),
                            border: Border(
                                top: BorderSide(
                                    color: Colors.grey.shade200, width: 1)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 20),
                              // Categories
                              const Padding(
                                padding:
                                    EdgeInsets.symmetric(horizontal: 16),
                                child: Text('Danh mục',
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87)),
                              ),
                              const SizedBox(height: 12),
                              SizedBox(
                                height: 40,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12),
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

                              // Job List Title
                              const Padding(
                                padding:
                                    EdgeInsets.symmetric(horizontal: 16),
                                child: Text('Công việc phù hợp',
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87)),
                              ),
                              const SizedBox(height: 16),

                              // Job List or Empty/Loading State
                              _isLoading && _filteredJobs.isEmpty
                                  ? const Padding(
                                      padding:
                                          EdgeInsets.symmetric(vertical: 48),
                                      child: Center(
                                          child: CircularProgressIndicator()))
                                  : _filteredJobs.isEmpty
                                      ? Padding(
                                          padding:
                                              const EdgeInsets.symmetric(
                                                  vertical: 48,
                                                  horizontal: 24),
                                          child: Center(
                                            child: Text(
                                              'Không tìm thấy công việc nào phù hợp với bộ lọc của bạn.',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                  color: Colors.grey.shade600,
                                                  fontSize: 15),
                                            ),
                                          ),
                                        )
                                      : ListView.builder(
                                          shrinkWrap: true,
                                          physics:
                                              const NeverScrollableScrollPhysics(),
                                          itemCount: _filteredJobs.length,
                                          itemBuilder: (context, index) {
                                            return JobCard(
                                                job: _filteredJobs[index]);
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
    );
  }
}
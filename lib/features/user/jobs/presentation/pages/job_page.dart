import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:pbl6/core/theme/app_pallete.dart';
import 'package:pbl6/features/shared/category/domain/usecases/get_all_categories_usecase.dart';
import 'package:pbl6/features/shared/user/domain/usecases/get_my_info_usecase.dart';
import 'package:pbl6/features/user/jobs/domain/usecases/get_company_details_usecase.dart';

import '../../../../shared/widgets/custom_app_bar.dart';
import '../../domain/entities/job.dart';
import '../../domain/entities/user.dart';
import '../../domain/usecases/get_all_jobs_usecase.dart';
import '../models/category_ui_model.dart';
import '../widgets/category_chip.dart';
import '../widgets/job_card.dart';
import '../widgets/search_bar.dart';

class JobPage extends StatefulWidget {
  const JobPage({super.key});

  @override
  State<JobPage> createState() => _JobPageState();
}

class _JobPageState extends State<JobPage> {
  late final GetAllJobsUseCase _getAllJobsUseCase;
  late final GetAllCategoriesUseCase _getAllCategoriesUseCase;
  late final GetMyInfoUseCase _getMyInfoUseCase;
  late final GetCompanyDetailsUseCase _getCompanyDetailsUseCase;

  List<CategoryUiModel> _uiCategories = [];
  List<Job> _allJobs = [];
  List<Job> _filteredJobs = [];
  User? _loadedUser;

  String? _selectedCategory;
  String? _searchQuery;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _getAllJobsUseCase = GetIt.I<GetAllJobsUseCase>();
    _getAllCategoriesUseCase = GetIt.I<GetAllCategoriesUseCase>();
    _getMyInfoUseCase = GetIt.I<GetMyInfoUseCase>();
    _getCompanyDetailsUseCase = GetIt.I<GetCompanyDetailsUseCase>();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    setState(() => _isLoading = true);
    try {
      final userEntity = await _getMyInfoUseCase();
      _loadedUser = User.fromAuthEntity(userEntity);
      final categories = await _getAllCategoriesUseCase();
      final jobs = await _getAllJobsUseCase();

      final jobsWithCompany = await Future.wait(
        jobs.map((job) async {
          final company = await _getCompanyDetailsUseCase(job.companyId);
          return job.copyWith(
      companyName: company.name,
      logoUrl: company.logoUrl, // thêm dòng này
    );
        }),
      );

      _allJobs = jobsWithCompany;
      _filteredJobs = List.from(_allJobs);

      _uiCategories = categories
          .map((c) => CategoryUiModel.fromEntity(c, isSelected: false))
          .toList();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Lỗi tải dữ liệu: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _filterJobs({String? category, String? query}) {
    _selectedCategory = category ?? _selectedCategory;
    _searchQuery = query ?? _searchQuery;

    setState(() {
      _filteredJobs = _allJobs.where((job) {
        final matchCategory =
            (_selectedCategory == null ||
            _selectedCategory == 'Tất cả' ||
            job.categoryIds.contains(_selectedCategory));
        final matchQuery =
            (_searchQuery == null ||
            job.title.toLowerCase().contains(_searchQuery!.toLowerCase()));
        return matchCategory && matchQuery;
      }).toList();
    });
  }

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
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                  onRefresh: _loadInitialData,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (_loadedUser != null)
                          CustomAppBar(user: _loadedUser!)
                        else
                          const SizedBox(height: 60),
                        const SizedBox(height: 16),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'Chúng tôi giúp bạn nhận được\ncông việc bạn xứng đáng!',
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 24,
                                  color: AppPallete.textColor,
                                  height: 1.3,
                                ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        CustomSearchBar(
                          onSearchChanged: (query) => _filterJobs(query: query),
                        ),
                        const SizedBox(height: 20),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(24),
                              topRight: Radius.circular(24),
                            ),
                            border: Border.all(
                              color: Colors.grey.shade200,
                              width: 1,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 20),
                              const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 16),
                                child: Text(
                                  'Danh mục',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              SizedBox(
                                height: 44,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                  ),
                                  itemCount: _uiCategories.length,
                                  itemBuilder: (context, index) {
                                    final uiModel = _uiCategories[index];
                                    return CategoryChip(
                                      uiModel: uiModel,
                                      onSelected: (selected) {
                                        setState(() {
                                          for (
                                            var i = 0;
                                            i < _uiCategories.length;
                                            i++
                                          ) {
                                            _uiCategories[i] = _uiCategories[i]
                                                .copyWith(
                                                  isSelected:
                                                      _uiCategories[i] ==
                                                      selected,
                                                );
                                          }
                                        });
                                        _filterJobs(
                                          category: selected.category.id,
                                        );
                                      },
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(height: 24),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                child: Text(
                                  'Công việc phù hợp với bạn',
                                  style: Theme.of(context).textTheme.titleMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 15,
                                        color: Colors.black87,
                                      ),
                                ),
                              ),
                              const SizedBox(height: 12),

                              if (_filteredJobs.isEmpty)
                                Padding(
                                  padding: const EdgeInsets.all(32),
                                  child: Center(
                                    child: Text(
                                      'Không có công việc phù hợp.',
                                      style: TextStyle(
                                        color: Colors.grey.shade500,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                )
                              else
                                ..._filteredJobs
                                    .map((job) => JobCard(job: job))
                                    .toList(),
                              const SizedBox(height: 100),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}

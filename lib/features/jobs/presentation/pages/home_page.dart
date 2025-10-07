import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:pbl6/core/theme/app_pallete.dart';

import '../../domain/entities/company.dart';
import '../../domain/entities/job_post.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/job_repository.dart';
import '../../domain/usecases/get_categories_usecase.dart';
import '../../domain/usecases/get_jobs_usecase.dart';
import '../models/category_ui_model.dart';
import '../widgets/category_chip.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/custom_bottom_nav.dart';
import '../widgets/job_card.dart';
import '../widgets/search_bar.dart';

class HomePage extends StatefulWidget {
  final User user;

  const HomePage({super.key, required this.user});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final GetJobsUseCase _getJobsUseCase;
  late final GetCategoriesUseCase _getCategoriesUseCase;
  late final JobRepository _jobRepository;

  List<CategoryUiModel> _uiCategories = [];
  List<JobPost> _jobs = [];
  Map<String, Company> _companies = {};

  String? _selectedCategory;
  String? _searchQuery;
  bool _isLoading = true;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _getJobsUseCase = GetIt.I<GetJobsUseCase>();
    _getCategoriesUseCase = GetIt.I<GetCategoriesUseCase>();
    _jobRepository = GetIt.I<JobRepository>();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    setState(() => _isLoading = true);

    final categories = await _getCategoriesUseCase();
    final jobs = await _getJobsUseCase();

    _uiCategories = categories
        .map((entity) => CategoryUiModel.fromEntity(
              entity,
              isSelected: entity.name == 'All',
            ))
        .toList();

    _selectedCategory = 'All';
    _jobs = jobs;

    for (final job in jobs) {
      _companies[job.companyId] =
          await _jobRepository.getCompany(job.companyId);
    }

    setState(() => _isLoading = false);
  }

  Future<void> _loadFilteredJobs({String? category, String? query}) async {
    setState(() => _isLoading = true);

    _selectedCategory = category ?? _selectedCategory;
    _searchQuery = query ?? _searchQuery;

    _jobs = await _getJobsUseCase(
      category: _selectedCategory,
      searchQuery: _searchQuery,
    );

    for (final job in _jobs) {
      _companies[job.companyId] =
          await _jobRepository.getCompany(job.companyId);
    }

    setState(() => _isLoading = false);
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
                        /// --- Header ---
                        CustomAppBar(user: widget.user),

                        const SizedBox(height: 12),

                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'Let\'s get you hired for the job\nyou deserve!',
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 26,
                                  color: AppPallete.textColor,
                                  height: 1.3,
                                ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        CustomSearchBar(
                          onSearchChanged: (query) =>
                              _loadFilteredJobs(query: query),
                        ),

                        const SizedBox(height: 24),

                        /// --- Nền trắng cho phần Category trở xuống ---
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(28),
                              topRight: Radius.circular(28),
                            ),
                            border: Border.all(
                              color: Colors.grey.shade300,
                              width: 2,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 20),

                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 16),
                                child: const Text(
                                  'Danh mục',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),

                              const SizedBox(height: 12),

                              SizedBox(
                                height: 48,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 12),
                                  itemCount: _uiCategories.length,
                                  itemBuilder: (context, index) {
                                    final uiModel = _uiCategories[index];
                                    return CategoryChip(
                                      uiModel: uiModel,
                                      onSelected: (selectedModel) {
                                        setState(() {
                                          _uiCategories = _uiCategories.map((m) {
                                            return m.copyWith(
                                              isSelected: m.category.id ==
                                                  selectedModel.category.id,
                                            );
                                          }).toList();
                                        });
                                        _loadFilteredJobs(
                                            category:

                                                selectedModel.category.name);

                                      },
                                    );
                                  },
                                ),
                              ),

                              const SizedBox(height: 20),

                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 16),
                                child: Text(
                                  'Tin tuyển dụng phù hợp với bạn',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16,
                                        color: Colors.black87,
                                      ),
                                ),
                              ),

                              const SizedBox(height: 12),

                              if (_jobs.isEmpty)
                                const Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(24),
                                    child: Text(
                                      'Không có công việc phù hợp.',
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                  ),
                                )
                              else
                                ..._jobs.map((job) => JobCard(
                                      job: job,
                                      company: _companies[job.companyId] ??
                                          const Company(
                                            id: '',
                                            name: '',
                                            taxCode: '',
                                            address: '',
                                          ),
                                    )),

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

      // 🔹 Thanh điều hướng dưới cùng
      bottomNavigationBar: CustomBottomNav(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() => _currentIndex = index);
        },
      ),
    );
  }
}

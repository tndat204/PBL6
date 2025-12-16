import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:pbl6/core/theme/app_pallete.dart';
import 'package:pbl6/features/recruiter/job/domain/usecases/get_applications_for_job_usecase.dart';
import 'package:pbl6/features/recruiter/job/domain/usecases/get_my_posted_job_usecase.dart';
import 'package:pbl6/features/shared/application/domain/entities/application.dart';
import 'package:pbl6/features/shared/auth/domain/repositories/auth_repository.dart';
import 'package:pbl6/features/shared/job/domain/entities/job.dart';
import 'package:pbl6/features/shared/widgets/custom_app_bar.dart';
import 'package:pbl6/features/shared/widgets/kpi_card.dart';

// --- IMPORTS THỐNG KÊ MỚI ---
import '../../../../shared/statistic/domain/entities/statistic.dart';
import '../../../../shared/statistic/domain/usecases/get_location_stats_usecase.dart';
import '../../../../shared/statistic/domain/usecases/get_salary_stats_usecase.dart';
import '../../../../shared/statistic/domain/usecases/get_top_skills_usecase.dart';
import '../../../../shared/statistic/presentation/widgets/job_location_map_widget.dart';
import '../../../../shared/statistic/presentation/widgets/salary_insights_widget.dart';
import '../../../../shared/statistic/presentation/widgets/top_skills_widget.dart';

class RecruiterDashboardPage extends StatefulWidget {
  const RecruiterDashboardPage({super.key});

  @override
  State<RecruiterDashboardPage> createState() => _RecruiterDashboardPageState();
}

class _RecruiterDashboardPageState extends State<RecruiterDashboardPage> {
  // UseCases Tuyển dụng
  late final GetMyPostedJobsUseCase _getMyPostedJobsUseCase;
  late final GetApplicationsForJobUsecase _getApplicationsForJobUsecase;
  late final AuthRepository _authRepository;

  // UseCases Thống kê
  late final GetTopSkillsUseCase _getTopSkillsUseCase;
  late final GetSalaryStatsUseCase _getSalaryStatsUseCase;
  late final GetLocationStatsUseCase _getLocationStatsUseCase;

  bool _isLoading = true;
  String _errorMessage = '';

  // Data Tuyển dụng
  List<Job> _myJobs = [];
  List<Application> _allApplications = [];

  // Data Thống kê
  List<SkillStat> _topSkills = [];
  List<SalaryStat> _salaryStats = [];
  List<LocationStat> _locationStats = [];

  // KPI Counters
  int _totalJobsActive = 0;
  int _totalNewApplicants = 0;
  int _totalReviewed = 0;
  int _totalInterviewing = 0;
  int _totalHired = 0;
  int _totalRejected = 0;

  @override
  void initState() {
    super.initState();
    final sl = GetIt.I;
    // Injection
    _getMyPostedJobsUseCase = sl<GetMyPostedJobsUseCase>();
    _getApplicationsForJobUsecase = sl<GetApplicationsForJobUsecase>();
    _authRepository = sl<AuthRepository>();
    
    _getTopSkillsUseCase = sl<GetTopSkillsUseCase>();
    _getSalaryStatsUseCase = sl<GetSalaryStatsUseCase>();
    _getLocationStatsUseCase = sl<GetLocationStatsUseCase>();

    WidgetsBinding.instance.addPostFrameCallback((_) => _loadDashboardData());
  }

  Future<void> _loadDashboardData() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });
    }

    try {
      // 1. Lấy thông tin Công ty (Bắt buộc để load job)
      final companyId = await _authRepository.getCompanyId();
      if (companyId == null || companyId.isEmpty) {
        throw Exception("Không tìm thấy Company ID. Vui lòng đăng nhập lại.");
      }

      // 2. Chạy song song: Load việc làm của cty VÀ Load thống kê thị trường
      // Để tối ưu tốc độ, ta gom các Future lại
      
      // Future lấy Job
      final jobsFuture = _getMyPostedJobsUseCase(GetMyPostedJobsParams(companyId: companyId, status: null));
      
      // Future lấy Thống kê
      final topSkillsFuture = _getTopSkillsUseCase(limit: 5);
      final salaryFuture = _getSalaryStatsUseCase();
      final locationFuture = _getLocationStatsUseCase();

      // Chờ tất cả API quan trọng trả về
      final results = await Future.wait([
        jobsFuture,       // index 0
        topSkillsFuture,  // index 1
        salaryFuture,     // index 2
        locationFuture    // index 3
      ]);

      // Xử lý dữ liệu Job
      _myJobs = results[0] as List<Job>;
      _totalJobsActive = _myJobs.where((job) => job.status == JobStatus.ACTIVE).length;

      // Xử lý dữ liệu Thống kê
      _topSkills = results[1] as List<SkillStat>;
      _salaryStats = results[2] as List<SalaryStat>;
      _locationStats = results[3] as List<LocationStat>;

      // 3. Lấy chi tiết Application cho từng Job (Cái này phải chạy sau khi có list jobs)
      if (_myJobs.isNotEmpty) {
        final List<Future<List<Application>>> applicationFutures = _myJobs.map((job) {
          return _getApplicationsForJobUsecase(job.id).catchError((e) {
            debugPrint('Lỗi lấy Applications cho job ${job.id}: $e');
            return <Application>[];
          });
        }).toList();

        final List<List<Application>> allAppsNested = await Future.wait(applicationFutures);
        _allApplications = allAppsNested.expand((list) => list).toList();
        _calculateRecruiterKpi();
      } else {
        _allApplications = [];
        _calculateRecruiterKpi();
      }

    } catch (e) {
      if (mounted) {
        setState(() => _errorMessage = 'Lỗi khi tải dữ liệu: ${e.toString()}');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _calculateRecruiterKpi() {
    _totalNewApplicants = _allApplications.where((app) => app.status == ApplicationStatus.SUBMITTED).length;
    _totalReviewed = _allApplications.where((app) => app.status == ApplicationStatus.REVIEWED).length;
    _totalInterviewing = _allApplications.where((app) => app.status == ApplicationStatus.INTERVIEW).length;
    _totalHired = _allApplications.where((app) => app.status == ApplicationStatus.HIRED).length;
    _totalRejected = _allApplications.where((app) => app.status == ApplicationStatus.REJECTED).length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: AppPallete.mainGradient,
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
             CustomAppBar(), // AppBar dùng chung
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator(color: AppPallete.primaryColor))
                    : _errorMessage.isNotEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(_errorMessage, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white)),
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: _loadDashboardData,
                                  child: const Text('Thử lại'),
                                ),
                              ],
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: _loadDashboardData,
                            color: AppPallete.primaryColor,
                            child: SingleChildScrollView(
                              padding: const EdgeInsets.all(16),
                              physics: const AlwaysScrollableScrollPhysics(),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  
                                  _buildKpiGrid(),

                                  const SizedBox(height: 30),

                                 
                                 

                                  if (_topSkills.isNotEmpty) ...[
                                    TopSkillsWidget(skills: _topSkills),
                                    const SizedBox(height: 16),
                                  ],

                                  if (_salaryStats.isNotEmpty) ...[
                                    SalaryInsightsWidget(salaryStats: _salaryStats),
                                    const SizedBox(height: 16),
                                  ],

                                  if (_locationStats.isNotEmpty)
                                    JobLocationMapWidget(locations: _locationStats),

                                  // --- PHẦN GHI CHÚ (DISCLAIMER) ---
                                if (_topSkills.isNotEmpty ||
                                  _salaryStats.isNotEmpty ||
                                  _locationStats.isNotEmpty)
                                Container(
                                  margin: const EdgeInsets.only(top: 20),
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: Colors.white24),
                                  ),
                                  child: const Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Icon(
                                        Icons.info_outline,
                                        color: Color.fromARGB(179, 203, 13, 13),
                                        size: 20,
                                      ),
                                      SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          "Lưu ý: Dữ liệu thống kê (Kỹ năng, Lương, Bản đồ) được tổng hợp trực tiếp từ các tin tuyển dụng trên hệ thống ITJobHunt. Đây là số liệu tham khảo nội bộ và không đại diện cho toàn bộ thị trường lao động Việt Nam.",
                                          style: TextStyle(
                                            color: Colors.black54,
                                            fontSize: 12,
                                            fontStyle: FontStyle.italic,
                                            height: 1.4,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                  const SizedBox(height: 80), // Padding bottom
                                ],
                              ),
                            ),
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildKpiGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.0, // Giữ tỉ lệ vuông để tránh overflow
      children: [
        KpiCardWidget(
          title: 'Tin đang đăng',
          count: _totalJobsActive,
          icon: Icons.public,
          iconColor: AppPallete.primaryColor,
          onTap: () => context.go('/recruiter/jobs'),
        ),
        KpiCardWidget(
          title: 'Ứng viên mới',
          count: _totalNewApplicants,
          icon: Icons.person_add_alt_1,
          iconColor: Colors.blue.shade600,
          onTap: () {},
        ),
        KpiCardWidget(
          title: 'Đã xem xét',
          count: _totalReviewed,
          icon: Icons.rate_review,
          iconColor: Colors.purple.shade600,
          onTap: () {},
        ),
        KpiCardWidget(
          title: 'Đang phỏng vấn',
          count: _totalInterviewing,
          icon: Icons.groups,
          iconColor: Colors.orange.shade700,
          onTap: () {},
        ),
        KpiCardWidget(
          title: 'Đã tuyển dụng',
          count: _totalHired,
          icon: Icons.check_circle,
          iconColor: Colors.green.shade600,
          onTap: () {},
        ),
        KpiCardWidget(
          title: 'Đã từ chối',
          count: _totalRejected,
          icon: Icons.cancel,
          iconColor: Colors.red.shade600,
          onTap: () {},
        ),
      ],
    );
  }
}
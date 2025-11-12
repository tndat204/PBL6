import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:pbl6/core/theme/app_pallete.dart';
import 'package:pbl6/features/recruiter/dashboard/presentation/widgets/kpi_card.dart';
import 'package:pbl6/features/recruiter/job/domain/usecases/get_applications_for_job_usecase.dart';
import 'package:pbl6/features/recruiter/job/domain/usecases/get_my_posted_job_usecase.dart';
import 'package:pbl6/features/shared/application/domain/entities/application.dart';
import 'package:pbl6/features/shared/auth/domain/repositories/auth_repository.dart';
import 'package:pbl6/features/shared/job/domain/entities/job.dart';
import 'package:pbl6/features/shared/widgets/custom_app_bar.dart';

class RecruiterDashboardPage extends StatefulWidget {
  const RecruiterDashboardPage({super.key});

  @override
  State<RecruiterDashboardPage> createState() => _RecruiterDashboardPageState();
}

class _RecruiterDashboardPageState extends State<RecruiterDashboardPage> {
  late final GetMyPostedJobsUseCase _getMyPostedJobsUseCase;
  late final GetApplicationsForJobUsecase _getApplicationsForJobUsecase;
  late final AuthRepository _authRepository;

  bool _isLoading = true;
  String _errorMessage = '';

  List<Job> _myJobs = [];
  List<Application> _allApplications = [];

  int _totalJobsActive = 0;
  int _totalNewApplicants = 0;
  int _totalReviewed = 0;
  int _totalInterviewing = 0;
  int _totalHired = 0;
  int _totalRejected = 0;

  @override
  void initState() {
    super.initState();
    _getMyPostedJobsUseCase = GetIt.I<GetMyPostedJobsUseCase>();
    _getApplicationsForJobUsecase = GetIt.I<GetApplicationsForJobUsecase>();
    _authRepository = GetIt.I<AuthRepository>();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadDashboardData());
  }

  Future<void> _loadDashboardData() async {
    if (mounted) setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final companyId = await _authRepository.getCompanyId();
      if (companyId == null || companyId.isEmpty) {
        throw Exception("Không tìm thấy Company ID. Vui lòng đăng nhập lại.");
      }

      final jobsParams = GetMyPostedJobsParams(companyId: companyId, status: null);
      _myJobs = await _getMyPostedJobsUseCase(jobsParams);
      _totalJobsActive = _myJobs.where((job) => job.status == JobStatus.ACTIVE).length;

      final List<Future<List<Application>>> applicationFutures = _myJobs.map((job) {
        return _getApplicationsForJobUsecase(job.id).catchError((e) {
          debugPrint('Lỗi lấy Applications cho job ${job.id}: $e');
          return <Application>[];
        });
      }).toList();

      final List<List<Application>> allAppsNested = await Future.wait(applicationFutures);
      _allApplications = allAppsNested.expand((list) => list).toList();

      _totalNewApplicants =
          _allApplications.where((app) => app.status == ApplicationStatus.SUBMITTED).length;
      _totalReviewed =
          _allApplications.where((app) => app.status == ApplicationStatus.REVIEWED).length;
      _totalInterviewing =
          _allApplications.where((app) => app.status == ApplicationStatus.INTERVIEW).length;
      _totalHired =
          _allApplications.where((app) => app.status == ApplicationStatus.HIRED).length;
      _totalRejected =
          _allApplications.where((app) => app.status == ApplicationStatus.REJECTED).length;
    } catch (e) {
      if (mounted) setState(() {
        _errorMessage = 'Lỗi khi tải dữ liệu: ${e.toString()}';
      });
    } finally {
      if (mounted) setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _buildKpiGrid() {
    return RefreshIndicator(
      onRefresh: _loadDashboardData,
      color: AppPallete.primaryColor,
      child: GridView.count(
        padding: const EdgeInsets.all(16.0),
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.0,
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
      ),
    );
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
              CustomAppBar(),
              Expanded(
                child: Builder(
                  builder: (context) {
                    if (_isLoading) {
                      return const Center(
                        child: CircularProgressIndicator(color: AppPallete.primaryColor),
                      );
                    }

                    if (_errorMessage.isNotEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(_errorMessage, textAlign: TextAlign.center),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: _loadDashboardData,
                                child: const Text('Thử lại'),
                              )
                            ],
                          ),
                        ),
                      );
                    }

                    return _buildKpiGrid();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

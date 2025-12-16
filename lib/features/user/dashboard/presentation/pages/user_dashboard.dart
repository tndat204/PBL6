import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:pbl6/core/theme/app_pallete.dart';
import 'package:pbl6/features/shared/application/domain/entities/application.dart';
import 'package:pbl6/features/shared/widgets/custom_app_bar.dart';
import 'package:pbl6/features/shared/widgets/kpi_card.dart';
import 'package:pbl6/features/user/dashboard/domain/usecases/get_my_applications_usecase.dart';

import '../../../../shared/statistic/domain/entities/statistic.dart';
import '../../../../shared/statistic/domain/usecases/get_location_stats_usecase.dart';
import '../../../../shared/statistic/domain/usecases/get_salary_stats_usecase.dart';
import '../../../../shared/statistic/domain/usecases/get_top_skills_usecase.dart';
import '../../../../shared/statistic/presentation/widgets/job_location_map_widget.dart';
import '../../../../shared/statistic/presentation/widgets/salary_insights_widget.dart';
import '../../../../shared/statistic/presentation/widgets/top_skills_widget.dart';

class UserDashboard extends StatefulWidget {
  const UserDashboard({super.key});

  @override
  State<UserDashboard> createState() => _UserDashboardState();
}

class _UserDashboardState extends State<UserDashboard> {
  late final GetMyApplicationsUsecase _getMyApplicationsUseCase;
  late final GetTopSkillsUseCase _getTopSkillsUseCase;
  late final GetSalaryStatsUseCase _getSalaryStatsUseCase;
  late final GetLocationStatsUseCase _getLocationStatsUseCase;
  bool _isLoading = true;
  String _errorMessage = '';
  List<Application> _myApplications = [];
  List<SkillStat> _topSkills = [];
  List<SalaryStat> _salaryStats = [];
  List<LocationStat> _locationStats = [];

  int _totalApplied = 0;
  int _totalSubmitted = 0;
  int _totalReviewed = 0;
  int _totalInterviewing = 0;
  int _totalHired = 0;
  int _totalRejected = 0;

  @override
  void initState() {
    super.initState();
    final sl = GetIt.I;
    _getMyApplicationsUseCase = sl<GetMyApplicationsUsecase>();
    _getTopSkillsUseCase = sl<GetTopSkillsUseCase>();
    _getSalaryStatsUseCase = sl<GetSalaryStatsUseCase>();
    _getLocationStatsUseCase = sl<GetLocationStatsUseCase>();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadDashboardData());
  }

  Future<void> _loadDashboardData() async {
    if (mounted)
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });

    try {
      // Gọi song song 4 API cùng lúc để tối ưu thời gian
      final results = await Future.wait([
        _getMyApplicationsUseCase(),
        _getTopSkillsUseCase(limit: 5), // Lấy Top 5 skill
        _getSalaryStatsUseCase(),
        _getLocationStatsUseCase(),
      ]);

      // Gán dữ liệu trả về (cần cast kiểu vì Future.wait trả về List<dynamic>)
      _myApplications = results[0] as List<Application>;
      _topSkills = results[1] as List<SkillStat>;
      _salaryStats = results[2] as List<SalaryStat>;
      _locationStats = results[3] as List<LocationStat>;

      _calculateKpi();
    } catch (e) {
      if (mounted)
        setState(() => _errorMessage = 'Lỗi tải dữ liệu: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _calculateKpi() {
    _totalApplied = _myApplications.length;
    _totalSubmitted = _myApplications
        .where((a) => a.status == ApplicationStatus.SUBMITTED)
        .length;
    _totalReviewed = _myApplications
        .where((a) => a.status == ApplicationStatus.REVIEWED)
        .length;
    _totalInterviewing = _myApplications
        .where((a) => a.status == ApplicationStatus.INTERVIEW)
        .length;
    _totalHired = _myApplications
        .where((a) => a.status == ApplicationStatus.HIRED)
        .length;
    _totalRejected = _myApplications
        .where((a) => a.status == ApplicationStatus.REJECTED)
        .length;
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
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: AppPallete.primaryColor,
                        ),
                      )
                    : _errorMessage.isNotEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _errorMessage,
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Colors.white),
                            ),
                            TextButton(
                              onPressed: _loadDashboardData,
                              child: const Text(
                                "Thử lại",
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadDashboardData,
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
                              const SizedBox(height: 80),
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
      childAspectRatio: 1.0,
      children: [
        KpiCardWidget(
          title: 'Tổng đã nộp',
          count: _totalApplied,
          icon: Icons.send,
          iconColor: AppPallete.primaryColor,
          onTap: () {},
        ),
        KpiCardWidget(
          title: 'Chờ xem xét',
          count: _totalSubmitted,
          icon: Icons.access_time,
          iconColor: Colors.blue,
          onTap: () {},
        ),
        KpiCardWidget(
          title: 'Đã xem',
          count: _totalReviewed,
          icon: Icons.visibility,
          iconColor: Colors.purple,
          onTap: () {},
        ),
        KpiCardWidget(
          title: 'Phỏng vấn',
          count: _totalInterviewing,
          icon: Icons.calendar_month,
          iconColor: Colors.orange,
          onTap: () {},
        ),
        KpiCardWidget(
          title: 'Đã tuyển',
          count: _totalHired,
          icon: Icons.check_circle,
          iconColor: Colors.green,
          onTap: () {},
        ),
        KpiCardWidget(
          title: 'Bị từ chối',
          count: _totalRejected,
          icon: Icons.cancel,
          iconColor: Colors.red,
          onTap: () {},
        ),
      ],
    );
  }
}

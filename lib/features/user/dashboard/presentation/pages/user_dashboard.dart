import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:pbl6/core/theme/app_pallete.dart';
import 'package:pbl6/features/shared/application/domain/entities/application.dart';
import 'package:pbl6/features/shared/widgets/custom_app_bar.dart';
import 'package:pbl6/features/shared/widgets/kpi_card.dart';
import 'package:pbl6/features/user/dashboard/domain/usecases/get_my_applications_usecase.dart';

class UserDashboard extends StatefulWidget {
  const UserDashboard({super.key});

  @override
  State<UserDashboard> createState() => _UserDashboardState();
}

class _UserDashboardState extends State<UserDashboard> {
  late final GetMyApplicationsUsecase _getMyApplicationsUseCase;

  bool _isLoading = true;
  String _errorMessage = '';
  List<Application> _myApplications = [];

  int _totalApplied = 0;
  int _totalSubmitted = 0;
  int _totalReviewed = 0;
  int _totalInterviewing = 0;
  int _totalHired = 0;
  int _totalRejected = 0;

  @override
  void initState() {
    super.initState();
    _getMyApplicationsUseCase = GetIt.I<GetMyApplicationsUsecase>();
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
      _myApplications = await _getMyApplicationsUseCase();

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
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Lỗi khi tải dữ liệu: ${e.toString()}';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Widget _buildKpiGrid() {
    return RefreshIndicator(
      onRefresh: _loadDashboardData,
      color: AppPallete.primaryColor,
      child: GridView.count(
        padding: const EdgeInsets.all(16),
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.0,
        children: [
          KpiCardWidget(
            title: 'Tổng số đã nộp',
            count: _totalApplied,
            icon: Icons.send,
            iconColor: AppPallete.primaryColor,
            onTap: () {},
          ),
          KpiCardWidget(
            title: 'Chờ xem xét',
            count: _totalSubmitted,
            icon: Icons.access_time,
            iconColor: Colors.blue.shade600,
            onTap: () {},
          ),
          KpiCardWidget(
            title: 'Đã xem hồ sơ',
            count: _totalReviewed,
            icon: Icons.visibility,
            iconColor: Colors.purple.shade600,
            onTap: () {},
          ),
          KpiCardWidget(
            title: 'Đang phỏng vấn',
            count: _totalInterviewing,
            icon: Icons.calendar_month,
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
                        child: CircularProgressIndicator(
                            color: AppPallete.primaryColor),
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
                              ),
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

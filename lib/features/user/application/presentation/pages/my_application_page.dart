import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:pbl6/core/theme/app_pallete.dart';
import 'package:pbl6/features/shared/application/domain/entities/application.dart';
import 'package:pbl6/features/shared/widgets/custom_app_bar.dart';
// Import Card Widget mới
import 'package:pbl6/features/user/application/presentation/widgets/my_application_card.dart';
import 'package:pbl6/features/user/dashboard/domain/usecases/get_my_applications_usecase.dart';

// Import UseCase

class MyApplicationPage extends StatefulWidget {
  const MyApplicationPage({super.key});

  @override
  State<MyApplicationPage> createState() => _MyApplicationPageState();
}

class _MyApplicationPageState extends State<MyApplicationPage> {
  // UseCases
  late final GetMyApplicationsUsecase _getMyApplicationsUseCase;

  // State
  bool _isLoading = true;
  String? _errorMessage;
  List<Application> _allApplications = [];
  
  // Bộ lọc
  ApplicationStatus? _selectedStatusFilter;
  
  // Danh sách trạng thái (bỏ UNKNOWN)
  final List<ApplicationStatus> _statusOptions = ApplicationStatus.values
      .where((s) => s != ApplicationStatus.UNKNOWN)
      .toList();

  @override
  void initState() {
    super.initState();
    _getMyApplicationsUseCase = GetIt.I<GetMyApplicationsUsecase>();
    _loadMyApplications();
  }

  Future<void> _loadMyApplications({bool refresh = false}) async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      final applications = await _getMyApplicationsUseCase();
      if (mounted) {
        setState(() {
          _allApplications = applications;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Lỗi tải hồ sơ: $e';
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

  void _onStatusFilterChanged(ApplicationStatus? newStatus) {
    setState(() {
      if (_selectedStatusFilter == newStatus) {
        _selectedStatusFilter = null; // Bỏ chọn
      } else {
        _selectedStatusFilter = newStatus;
      }
    });
  }

  // Lọc danh sách
  List<Application> get _filteredApplications {
    if (_selectedStatusFilter == null) {
      return _allApplications;
    }
    return _allApplications
        .where((app) => app.status == _selectedStatusFilter)
        .toList();
  }

  // --- Utility Methods (Copy từ Recruiter Tab) ---
  Color _getStatusColor(ApplicationStatus status) {
    switch (status) {
      case ApplicationStatus.SUBMITTED: return Colors.blue.shade600;
      case ApplicationStatus.REVIEWED: return Colors.purple.shade600;
      case ApplicationStatus.INTERVIEW: return Colors.orange.shade600;
      case ApplicationStatus.HIRED: return Colors.green.shade600;
      case ApplicationStatus.REJECTED: return Colors.red.shade600;
      case ApplicationStatus.UNKNOWN: return Colors.grey.shade600;
    }
  }

  String _getStatusText(ApplicationStatus status) {
    switch (status) {
      case ApplicationStatus.SUBMITTED: return 'Mới nộp';
      case ApplicationStatus.REVIEWED: return 'Đã xem xét';
      case ApplicationStatus.INTERVIEW: return 'Đã hẹn PV';
      case ApplicationStatus.HIRED: return 'Đã tuyển';
      case ApplicationStatus.REJECTED: return 'Đã từ chối';
      case ApplicationStatus.UNKNOWN: return 'Không rõ';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        // Nền Gradient (giống JobPage)
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: AppPallete.mainGradient,
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: () => _loadMyApplications(refresh: true),
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
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'Công việc đã ứng tuyển', // Tiêu đề trang
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w400,
                              fontSize: 40,
                              color: AppPallete.textColor,
                              height: 1.3,
                              fontFamily: 'Italianno',
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                  expandedHeight: 200, // Chiều cao Header
                ),

                // --- Main Content (Bộ lọc + Danh sách) ---
                SliverToBoxAdapter(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                      border: Border(top: BorderSide(color: Colors.grey.shade200, width: 1)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20),
                        // --- Bộ lọc ChoiceChip ---
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'Lọc theo trạng thái',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 50,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: _statusOptions.length,
                            separatorBuilder: (context, index) => const SizedBox(width: 8),
                            itemBuilder: (context, index) {
                              final status = _statusOptions[index];
                              final isSelected = _selectedStatusFilter == status;
                              final color = _getStatusColor(status);

                              return ChoiceChip(
                                label: Text(_getStatusText(status)),
                                selected: isSelected,
                                selectedColor: color,
                                backgroundColor: Colors.white,
                                elevation: 0,
                                labelPadding: const EdgeInsets.symmetric(horizontal: 4),
                                labelStyle: TextStyle(
                                  color: isSelected ? Colors.white : color,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                  fontSize: 13,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  side: BorderSide(
                                    color: isSelected ? color : color.withOpacity(0.5),
                                    width: 1.5,
                                  ),
                                ),
                                onSelected: (selected) => _onStatusFilterChanged(selected ? status : null),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 24),
                        
                        // --- Danh sách Applications ---
                        _buildApplicationList(),
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

  Widget _buildApplicationList() {
    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 48),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
        child: Center(child: Text(_errorMessage!, textAlign: TextAlign.center)),
      );
    }

    if (_filteredApplications.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
        child: Center(
          child: Text(
            _selectedStatusFilter == null
                ? 'Bạn chưa ứng tuyển công việc nào.'
                : 'Không tìm thấy hồ sơ ở trạng thái "${_getStatusText(_selectedStatusFilter!)}".',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 15),
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _filteredApplications.length,
      padding: const EdgeInsets.only(bottom: 80),
      itemBuilder: (context, index) {
        final application = _filteredApplications[index];
        return MyApplicationCard(
          application: application,
          // (Chúng ta sẽ thêm Job/Company vào Card sau)
        );
      },
    );
  }
}
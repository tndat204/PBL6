import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:motion_toast/motion_toast.dart';
import 'package:pbl6/core/theme/app_pallete.dart';
import 'package:pbl6/features/recruiter/job/domain/usecases/get_applications_for_job_usecase.dart';
import 'package:pbl6/features/recruiter/job/domain/usecases/update_application_status_usecase.dart';
import 'package:pbl6/features/shared/application/domain/entities/application.dart';
import 'package:url_launcher/url_launcher.dart';

// Giả định bạn có định nghĩa cho UseCase này
// import 'package:pbl6/features/recruiter/job/domain/usecases/update_application_status_usecase.dart'; 


class RecruiterJobApplicantsTab extends StatefulWidget {
  final String jobId;

  const RecruiterJobApplicantsTab({super.key, required this.jobId});

  @override
  State<RecruiterJobApplicantsTab> createState() =>
      _RecruiterJobApplicantsTabState();
}

class _RecruiterJobApplicantsTabState extends State<RecruiterJobApplicantsTab> {
  // UseCases
  late final GetApplicationsForJobUsecase _getApplicationsForJobUsecase;
  late final UpdateApplicationStatusUsecase _updateApplicationStatusUsecase;

  // State
  bool _isLoading = true;
  String? _errorMessage;
  List<Application> _allApplicants = [];
  
  // Bộ lọc
  ApplicationStatus? _selectedStatusFilter;
  
  // Danh sách trạng thái hiển thị trong bộ lọc (Bỏ UNKNOWN)
  final List<ApplicationStatus> _statusOptions = ApplicationStatus.values
      .where((s) => s != ApplicationStatus.UNKNOWN)
      .toList();

  @override
  void initState() {
    super.initState();
    _getApplicationsForJobUsecase = GetIt.I<GetApplicationsForJobUsecase>();
    _updateApplicationStatusUsecase = GetIt.I<UpdateApplicationStatusUsecase>();
    _loadApplicants();
  }

  Future<void> _loadApplicants() async {
    if (mounted) setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final applicants = await _getApplicationsForJobUsecase(widget.jobId);
      if (mounted) {
        setState(() {
          _allApplicants = applicants;
        });
      }
    } catch (e) {
      if (mounted) setState(() {
        _errorMessage = 'Lỗi tải danh sách ứng viên: $e';
      });
    } finally {
      if (mounted) setState(() {
        _isLoading = false;
      });
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

  // Lọc danh sách theo trạng thái đã chọn
  List<Application> get _filteredApplicants {
    if (_selectedStatusFilter == null) {
      return _allApplicants;
    }
    return _allApplicants
        .where((app) => app.status == _selectedStatusFilter)
        .toList();
  }

  // --- Utility Methods ---

  Color _getStatusColor(ApplicationStatus status) {
    switch (status) {
      case ApplicationStatus.SUBMITTED:
        return Colors.blue.shade600;
      case ApplicationStatus.REVIEWED:
        return Colors.purple.shade600;
      case ApplicationStatus.INTERVIEW:
        return Colors.orange.shade600;
      case ApplicationStatus.HIRED:
        return Colors.green.shade600;
      case ApplicationStatus.REJECTED:
        return Colors.red.shade600;
      case ApplicationStatus.UNKNOWN:
        return Colors.grey.shade600;
    }
  }

  String _getStatusText(ApplicationStatus status) {
    switch (status) {
      case ApplicationStatus.SUBMITTED:
        return 'Mới nộp';
      case ApplicationStatus.REVIEWED:
        return 'Đã xem xét';
      case ApplicationStatus.INTERVIEW:
        return 'Đã hẹn PV';
      case ApplicationStatus.HIRED:
        return 'Đã tuyển';
      case ApplicationStatus.REJECTED:
        return 'Đã từ chối';
      case ApplicationStatus.UNKNOWN:
        return 'Không rõ';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(child: Text(_errorMessage!));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Bộ lọc trạng thái
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
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : Colors.black87,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(color: color.withOpacity(0.5)),
                ),
                onSelected: (selected) => _onStatusFilterChanged(selected ? status : null),
              );
            },
          ),
        ),
        
        const SizedBox(height: 16),
        
        // 2. Danh sách ứng viên
        Expanded(
          child: _filteredApplicants.isEmpty
              ? Center(
                  child: Text(
                      _selectedStatusFilter == null
                          ? 'Chưa có ứng viên nộp hồ sơ.'
                          : 'Không tìm thấy ứng viên ở trạng thái ${_getStatusText(_selectedStatusFilter!)}.',
                      style: const TextStyle(color: Colors.grey)),
                )
              : ListView.builder(
                  padding: const EdgeInsets.only(bottom: 20),
                  itemCount: _filteredApplicants.length,
                  itemBuilder: (context, index) {
                    final app = _filteredApplicants[index];
                    return ApplicantCard(
                      application: app,
                      onStatusUpdate: _updateStatus,
                      onRefresh: _loadApplicants, // Truyền hàm refresh
                    );
                  },
                ),
        ),
      ],
    );
  }

  // Hàm xử lý update trạng thái (gọi UseCase)
  Future<void> _updateStatus(
      String applicationId, ApplicationStatus newStatus) async {
    try {
      await _updateApplicationStatusUsecase(
        applicationId: applicationId,
        newStatus: newStatus,
      );
      if (mounted) {
        MotionToast.success(
          description: Text('Cập nhật trạng thái thành ${_getStatusText(newStatus)}'),
        ).show(context);
        // Tải lại dữ liệu sau khi update thành công
        _loadApplicants(); 
      }
    } catch (e) {
      if (mounted) {
        MotionToast.error(
          description: Text('Lỗi cập nhật trạng thái: $e'),
        ).show(context);
      }
    }
  }
}

// --- Applicant Card Widget ---

class ApplicantCard extends StatefulWidget {
  final Application application;
  final Function(String applicationId, ApplicationStatus newStatus) onStatusUpdate;
  final VoidCallback onRefresh;

  const ApplicantCard({
    super.key,
    required this.application,
    required this.onStatusUpdate,
    required this.onRefresh,
  });

  @override
  State<ApplicantCard> createState() => _ApplicantCardState();
}

class _ApplicantCardState extends State<ApplicantCard> {

  // Logic tải CV
  void _launchCV() async {
    final url = Uri.parse(widget.application.cvFileUrl);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if (mounted) {
         MotionToast.error(
          description: const Text('Không thể tải hoặc mở CV.'),
        ).show(context);
      }
    }
  }

  // --- Build ---
  @override
  Widget build(BuildContext context) {
    final applicant = widget.application.applicantInfo;
    final currentStatus = widget.application.status;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Info và Avatar ---
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: Colors.blueGrey.shade100,
                  backgroundImage: applicant.avatarUrl.isNotEmpty
                      ? NetworkImage(applicant.avatarUrl) as ImageProvider
                      : null,
                  child: applicant.avatarUrl.isEmpty
                      ? const Icon(Icons.person, color: Colors.blueGrey)
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        applicant.fullName,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        applicant.email,
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // --- Thông tin liên hệ ---
            _buildInfoRow(Icons.phone_outlined, applicant.phone),
            _buildInfoRow(Icons.location_on_outlined, applicant.address),

            const SizedBox(height: 16),

            // --- Nút Hành động và Trạng thái ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // 1. Dropdown Trạng thái
                _buildStatusDropdown(currentStatus),

                // 2. Nút Tải CV
                ElevatedButton.icon(
                  onPressed: widget.application.cvFileUrl.isNotEmpty ? _launchCV : null,
                  icon: const Icon(Icons.file_download_outlined, size: 18),
                  label: const Text('Tải CV'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppPallete.primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey.shade600),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 14))),
        ],
      ),
    );
  }

  Widget _buildStatusDropdown(ApplicationStatus currentStatus) {
    // Loại bỏ UNKNOWN khỏi danh sách tùy chọn
    final statusOptions = ApplicationStatus.values
        .where((s) => s != ApplicationStatus.UNKNOWN)
        .toList();

    return DropdownButtonHideUnderline(
      child: DropdownButton<ApplicationStatus>(
        value: currentStatus,
        hint: Text(_getStatusText(currentStatus)),
        items: statusOptions.map((status) {
          return DropdownMenuItem(
            value: status,
            child: Row(
              children: [
                Icon(
                  Icons.circle,
                  size: 10,
                  color: _getStatusColor(status),
                ),
                const SizedBox(width: 8),
                Text(
                  _getStatusText(status),
                  style: TextStyle(color: _getStatusColor(status)),
                ),
              ],
            ),
          );
        }).toList(),
        onChanged: (newStatus) {
          if (newStatus != null && newStatus != currentStatus) {
            widget.onStatusUpdate(widget.application.id, newStatus);
          }
        },
        style: TextStyle(
          color: _getStatusColor(currentStatus),
          fontWeight: FontWeight.bold,
        ),
        icon: Icon(Icons.arrow_drop_down, color: _getStatusColor(currentStatus)),
      ),
    );
  }

  Color _getStatusColor(ApplicationStatus status) {
    switch (status) {
      case ApplicationStatus.SUBMITTED:
        return Colors.blue.shade600;
      case ApplicationStatus.REVIEWED:
        return Colors.purple.shade600;
      case ApplicationStatus.INTERVIEW:
        return Colors.orange.shade600;
      case ApplicationStatus.HIRED:
        return Colors.green.shade600;
      case ApplicationStatus.REJECTED:
        return Colors.red.shade600;
      case ApplicationStatus.UNKNOWN:
        return Colors.grey.shade600;
    }
  }

  String _getStatusText(ApplicationStatus status) {
    switch (status) {
      case ApplicationStatus.SUBMITTED:
        return 'Mới nộp';
      case ApplicationStatus.REVIEWED:
        return 'Đã xem xét';
      case ApplicationStatus.INTERVIEW:
        return 'Đã hẹn PV';
      case ApplicationStatus.HIRED:
        return 'Đã tuyển';
      case ApplicationStatus.REJECTED:
        return 'Đã từ chối';
      case ApplicationStatus.UNKNOWN:
        return 'Không rõ';
    }
  }
}
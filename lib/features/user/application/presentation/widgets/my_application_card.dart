import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:pbl6/core/constants/api_constants.dart';
import 'package:pbl6/features/shared/application/domain/entities/application.dart';
import 'package:pbl6/features/shared/company/domain/entities/company.dart';
import 'package:pbl6/features/shared/company/domain/usecases/get_company_details_usecase.dart';
import 'package:pbl6/features/shared/job/domain/entities/job.dart';
import 'package:pbl6/features/shared/job/domain/usecases/get_job_details_usecase.dart';

class MyApplicationCard extends StatefulWidget {
  final Application application;

  const MyApplicationCard({super.key, required this.application});

  @override
  State<MyApplicationCard> createState() => _MyApplicationCardState();
}

class _MyApplicationCardState extends State<MyApplicationCard> {
  // UseCases
  late final GetJobDetailsUseCase _getJobDetailsUseCase;
  late final GetCompanyDetailsUseCase _getCompanyDetailsUseCase;

  // State
  Job? _job;
  Company? _company;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _getJobDetailsUseCase = GetIt.I<GetJobDetailsUseCase>();
    _getCompanyDetailsUseCase = GetIt.I<GetCompanyDetailsUseCase>();
    _loadJobAndCompany();
  }

  Future<void> _loadJobAndCompany() async {
    try {
      final job = await _getJobDetailsUseCase(widget.application.jobId);
      final company = await _getCompanyDetailsUseCase(job.companyId);
      
      if (mounted) {
        setState(() {
          _job = job;
          _company = company;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
      print('Lỗi tải Job/Company cho ApplicationCard: $e');
    }
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

  String _formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  @override
  Widget build(BuildContext context) {
    final status = widget.application.status;
    final statusColor = _getStatusColor(status);
    
    // Xử lý logoUrl (giống JobCard)
    final logoUrl = _company?.logoUrl;
    final imageUrl = (logoUrl != null && logoUrl.isNotEmpty)
        ? (logoUrl.startsWith('http') ? logoUrl : '${ApiConstants.baseUrl}$logoUrl')
        : null;
        
    return InkWell(
      onTap: () {
        if (_job != null) {
          // 💡 Điều hướng đến Job Detail và truyền tham số `hideApplyButton`
          context.push(
            '/user/jobs/${_job!.id}',
            extra: {'hideApplyButton': true}, // ⭐️ BÁO CHO TRANG DETAIL ẨN NÚT
          );
        }
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: _isLoading 
              ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
              : _job == null
                  ? const Center(child: Text("Lỗi tải thông tin Job", style: TextStyle(color: Colors.red)))
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // --- Job Info (Logo, Title, Company) ---
                        Row(
                          children: [
                            if (imageUrl != null)
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  imageUrl,
                                  width: 48, height: 48, fit: BoxFit.cover,
                                  errorBuilder: (c, e, s) => const Icon(Icons.business),
                                ),
                              )
                            else
                              Container(
                                width: 48, height: 48,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade200,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Icons.business, color: Colors.grey),
                              ),
                            
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _job!.title,
                                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                    maxLines: 1, overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    _company?.name ?? 'Đang tải...',
                                    style: TextStyle(color: Colors.grey.shade600),
                                    maxLines: 1, overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        
                        const Divider(height: 24),

                        // --- Application Info (Date, Notes) ---
                        _buildInfoRow(
                          Icons.calendar_today_outlined, 
                          'Ngày nộp: ${_formatDate(widget.application.appliedDate)}'
                        ),
                        
                        if (widget.application.notes.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: _buildInfoRow(
                              Icons.notes_outlined,
                              'Ghi chú: "${widget.application.notes}"',
                              isItalic: true
                            ),
                          ),

                        const SizedBox(height: 16),

                        // --- Status Chip ---
                        Align(
                          alignment: Alignment.centerRight,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: statusColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: statusColor, width: 1),
                            ),
                            child: Text(
                              _getStatusText(status),
                              style: TextStyle(
                                color: statusColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
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

  Widget _buildInfoRow(IconData icon, String text, {bool isItalic = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: Colors.grey.shade600),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text, 
            style: TextStyle(
              fontSize: 14, 
              fontStyle: isItalic ? FontStyle.italic : FontStyle.normal,
              color: isItalic ? Colors.grey.shade700 : Colors.black87
            ),
          )
        ),
      ],
    );
  }
}
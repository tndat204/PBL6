import 'package:flutter/material.dart';
import 'package:motion_toast/motion_toast.dart';
import 'package:pbl6/core/theme/app_pallete.dart';
import 'package:pbl6/features/ai_matching/domain/entities/ai_matching_entities.dart'; // Import MatchScore
import 'package:pbl6/features/shared/application/domain/entities/application.dart';
import 'package:url_launcher/url_launcher.dart';

class ApplicantCard extends StatefulWidget {
  final Application application;
  final Function(String, ApplicationStatus) onStatusUpdate;
  final VoidCallback onRefresh;
  final MatchScore? matchScore; 

  const ApplicantCard({
    super.key,
    required this.application,
    required this.onStatusUpdate,
    required this.onRefresh,
    this.matchScore,
  });

  @override
  State<ApplicantCard> createState() => _ApplicantCardState();
}

class _ApplicantCardState extends State<ApplicantCard> {
  
  void _launchCV() async {
    if (widget.application.cvFileUrl.isEmpty) return;
    final url = Uri.parse(widget.application.cvFileUrl);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        MotionToast.error(description: const Text('Không thể tải hoặc mở CV.')).show(context);
      }
    }
  }

  Color _getScoreColor(double score) {
    // Thang 100
    if (score >= 75) return Colors.green.shade700;
    if (score >= 50) return Colors.orange.shade700;
    return Colors.red.shade700;
  }

  // --- Helper Colors & Text ---
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
    final applicant = widget.application.applicantInfo;
    final currentStatus = widget.application.status;
    final double? totalScore = widget.matchScore?.totalScore;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar + Name
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
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(applicant.email, style: TextStyle(color: Colors.grey.shade600)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Info Rows
                _buildInfoRow(Icons.phone_outlined, applicant.phone),
                _buildInfoRow(Icons.location_on_outlined, applicant.address),
                
                if (widget.application.notes.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Text(
                      '"${widget.application.notes}"',
                      style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey.shade700, fontSize: 14),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                const SizedBox(height: 16),

                // Actions
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildStatusDropdown(currentStatus),
                    ElevatedButton.icon(
                      onPressed: widget.application.cvFileUrl.isNotEmpty ? _launchCV : null,
                      icon: const Icon(Icons.file_download_outlined, size: 18),
                      label: const Text('CV'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppPallete.primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // --- AI Score Badge ---
          if (totalScore != null)
            Positioned(
              top: 0,
              right: 0,
              child: Tooltip(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: Colors.black87, borderRadius: BorderRadius.circular(8)),
                textStyle: const TextStyle(color: Colors.white),
                message: "Technical: ${widget.matchScore?.technicalSkills.toStringAsFixed(1)}\n"
                         "Experience: ${widget.matchScore?.experience.toStringAsFixed(1)}\n"
                         "Education: ${widget.matchScore?.education.toStringAsFixed(1)}\n"
                         "Soft Skills: ${widget.matchScore?.softSkills.toStringAsFixed(1)}\n"
                         "Other: ${widget.matchScore?.other.toStringAsFixed(1)}",
                triggerMode: TooltipTriggerMode.tap,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getScoreColor(totalScore),
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(12),
                      bottomLeft: Radius.circular(12),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.auto_awesome, size: 14, color: Colors.white),
                      const SizedBox(width: 4),
                      Text(
                        "${totalScore.toStringAsFixed(1)}%",
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
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
    final statusOptions = ApplicationStatus.values.where((s) => s != ApplicationStatus.UNKNOWN).toList();
    return PopupMenuButton<ApplicationStatus>(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: _getStatusColor(currentStatus)),
          color: _getStatusColor(currentStatus).withOpacity(0.1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.circle, size: 10, color: _getStatusColor(currentStatus)),
            const SizedBox(width: 6),
            Text(
              _getStatusText(currentStatus),
              style: TextStyle(color: _getStatusColor(currentStatus), fontWeight: FontWeight.bold, fontSize: 13),
            ),
            const Icon(Icons.arrow_drop_down, size: 18),
          ],
        ),
      ),
      onSelected: (newStatus) {
        if(newStatus != currentStatus) widget.onStatusUpdate(widget.application.id, newStatus);
      },
      itemBuilder: (context) => statusOptions.map((s) => PopupMenuItem(
        value: s,
        child: Row(
          children: [
            Icon(Icons.circle, size: 10, color: _getStatusColor(s)),
            const SizedBox(width: 8),
            Text(_getStatusText(s)),
          ],
        ),
      )).toList(),
    );
  }
}
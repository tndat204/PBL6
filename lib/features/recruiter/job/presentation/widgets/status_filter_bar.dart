import 'package:flutter/material.dart';
import 'package:pbl6/core/theme/app_pallete.dart';
import 'package:pbl6/features/shared/application/domain/entities/application.dart';

class StatusFilterBar extends StatelessWidget {
  final ApplicationStatus? selectedStatus;
  final Function(ApplicationStatus?) onStatusChanged;
  final bool isAiFilterActive;
  final int topKOption;
  final VoidCallback onAiFilterPressed;
  final VoidCallback onClearAiFilter;

  const StatusFilterBar({
    super.key,
    required this.selectedStatus,
    required this.onStatusChanged,
    required this.isAiFilterActive,
    required this.topKOption,
    required this.onAiFilterPressed,
    required this.onClearAiFilter,
  });

  @override
  Widget build(BuildContext context) {
    final statusOptions = ApplicationStatus.values
        .where((s) => s != ApplicationStatus.UNKNOWN)
        .toList();

    return SizedBox(
      height: 50,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          // 1. Nút AI Filter
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ActionChip(
              avatar: Icon(
                Icons.tune_rounded, 
                color: isAiFilterActive ? Colors.white : AppPallete.primaryColor,
                size: 18,
              ),
              label: Text(isAiFilterActive ? "AI: Top $topKOption" : "Lọc AI"),
              backgroundColor: isAiFilterActive ? AppPallete.primaryColor : Colors.white,
              labelStyle: TextStyle(
                color: isAiFilterActive ? Colors.white : AppPallete.primaryColor,
                fontWeight: FontWeight.bold,
              ),
              side: BorderSide(color: AppPallete.primaryColor.withOpacity(0.5)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              onPressed: onAiFilterPressed,
            ),
          ),
          
          // Nút xóa AI Filter
          if (isAiFilterActive)
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: ActionChip(
                label: const Icon(Icons.close, size: 16, color: Colors.red),
                backgroundColor: Colors.red.shade50,
                side: BorderSide(color: Colors.red.shade200),
                shape: const CircleBorder(),
                onPressed: onClearAiFilter,
                padding: EdgeInsets.zero,
              ),
            ),

          Container(width: 1, height: 30, color: Colors.grey.shade300, margin: const EdgeInsets.only(right: 8)),

          // 2. Danh sách Status Chips
          ...statusOptions.map((status) {
            final isSelected = selectedStatus == status;
            final color = _getStatusColor(status);

            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(_getStatusText(status)),
                selected: isSelected,
                selectedColor: color,
                backgroundColor: Colors.white,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : color,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  fontSize: 13,
                ),
                side: BorderSide(
                  color: isSelected ? color : color.withOpacity(0.5),
                ),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                onSelected: (selected) => onStatusChanged(selected ? status : null),
              ),
            );
          }),
        ],
      ),
    );
  }
  
  // Helper functions (private)
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
}
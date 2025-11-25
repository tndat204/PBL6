import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:pbl6/core/theme/app_pallete.dart';
import 'package:pbl6/features/shared/auth/presentation/widgets/custom_text_field.dart';
import 'package:pbl6/features/shared/review/domain/entities/report_reason.dart';
import 'package:pbl6/features/shared/review/domain/usecases/get_report_reason_usecase.dart';

class ReportReviewModal extends StatefulWidget {
  final Function(String reason, String description) onSubmit;

  const ReportReviewModal({
    super.key,
    required this.onSubmit,
  });

  @override
  State<ReportReviewModal> createState() => _ReportReviewModalState();
}

class _ReportReviewModalState extends State<ReportReviewModal> {
  List<ReportReason> _reasons = [];
  bool _isLoading = true;
  late final GetReportReasonsUseCase _getReportReasonsUseCase;
  String? _selectedReasonKey;
  final TextEditingController _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _getReportReasonsUseCase = GetIt.I<GetReportReasonsUseCase>();
    _loadReasons();
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _loadReasons() async {
    try {
      final reasons = await _getReportReasonsUseCase();
      if (mounted) {
        setState(() {
          _reasons = reasons;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _handleSubmit() {
    if (_selectedReasonKey == null) return;

    final description =
        _selectedReasonKey == 'OTHER' ? _descriptionController.text.trim() : '';

    widget.onSubmit(_selectedReasonKey!, description);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.all(16),
      child: Container(
        constraints:
            BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          children: [
            // --- HEADER ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Báo cáo vi phạm",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Divider(height: 1, color: Colors.grey),
            const SizedBox(height: 8),

            // --- BODY ---
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _reasons.isEmpty
                      ? const Center(child: Text("Không tải được danh sách lý do."))
                      : ListView.builder(
                          itemCount: _reasons.length,
                          itemBuilder: (context, index) {
                            final reason = _reasons[index];
                            final isSelected = _selectedReasonKey == reason.key;
                            final isOther = reason.key == 'OTHER';

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // --- Lý do ---
                                  RadioListTile<String>(
                                    value: reason.key,
                                    groupValue: _selectedReasonKey,
                                    onChanged: (val) {
                                      setState(() {
                                        _selectedReasonKey = val;
                                        // Không gửi ngay
                                        if (!isOther) {
                                          _descriptionController.clear();
                                        }
                                      });
                                    },
                                    title: Text(
                                      reason.label,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w600),
                                    ),
                                    subtitle: Text(
                                      reason.description,
                                      style: TextStyle(
                                          color: Colors.grey[600], fontSize: 13),
                                    ),
                                    activeColor: AppPallete.primaryColor,
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 0),
                                  ),

                                  // --- TextField nếu chọn OTHER ---
                                  if (isOther && isSelected)
                                    Padding(
                                      padding:
                                          const EdgeInsets.symmetric(horizontal: 16),
                                      child: CustomTextField(
                                        label: "Nhập chi tiết vi phạm...",
                                        icon: Icons.report,
                                        obscureText: false,
                                        controller: _descriptionController,
                                        minLines: 3,
                                        maxLines: 4,
                                      ),
                                    ),
                                ],
                              ),
                            );
                          },
                        ),
            ),

            // --- BUTTON GỬI ---
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed:
                    _selectedReasonKey != null ? _handleSubmit : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppPallete.primaryColor,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.grey.shade300,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  "Gửi báo cáo",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

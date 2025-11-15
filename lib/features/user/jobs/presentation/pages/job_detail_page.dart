import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:motion_toast/motion_toast.dart';
import 'package:pbl6/core/theme/app_pallete.dart';
import 'package:pbl6/features/shared/company/domain/usecases/get_company_details_usecase.dart';
import 'package:pbl6/features/shared/job/domain/entities/job.dart';
import 'package:pbl6/features/shared/job/domain/usecases/get_job_details_usecase.dart';
import 'package:pbl6/features/user/jobs/domain/usecases/apply_job_usecase.dart';
import 'package:pbl6/features/user/jobs/presentation/widgets/job_review_tab.dart';

import '../../../../shared/category/domain/usecases/get_category_detail_usecase.dart';
import '../../../../shared/skill/domain/usecases/get_skill_detail_usecase.dart';
import '../widgets/apply_note_dialog.dart';
import '../widgets/job_company_tab.dart';
import '../widgets/job_description_tab.dart';
import '../widgets/job_detail_header.dart';

class JobDetailPage extends StatefulWidget {
  final String jobId;
  // 💡 THAM SỐ MỚI: Nhận từ GoRouter extra
  final bool hideApplyButton; 

  const JobDetailPage({
    super.key, 
    required this.jobId,
    this.hideApplyButton = false, // Mặc định là false
  });

  @override
  State<JobDetailPage> createState() => _JobDetailPageState();
}

class _JobDetailPageState extends State<JobDetailPage>
    with SingleTickerProviderStateMixin {
  late final GetJobDetailsUseCase _getJobDetailsUseCase;
  late final GetCompanyDetailsUseCase _getCompanyDetailsUseCase;
  late final GetSkillDetailUseCase _getSkillDetailUseCase;
  late final GetCategoryDetailUseCase _getCategoryDetailUseCase;
  late final ApplyJobUsecase _applyJobUsecase;

  Job? _job;
  bool _isLoading = true;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _getJobDetailsUseCase = GetIt.I<GetJobDetailsUseCase>();
    _getCompanyDetailsUseCase = GetIt.I<GetCompanyDetailsUseCase>();
    _getSkillDetailUseCase = GetIt.I<GetSkillDetailUseCase>();
    _getCategoryDetailUseCase = GetIt.I<GetCategoryDetailUseCase>();
    _applyJobUsecase = GetIt.I<ApplyJobUsecase>(); 
    _tabController = TabController(length: 3, vsync: this);
    _loadJob();
  }

  Future<void> _loadJob() async {
    try {
      final job = await _getJobDetailsUseCase(widget.jobId);
      final company = await _getCompanyDetailsUseCase(job.companyId);
      final jobWithCompanyInfo = job.copyWith(
        companyName: company.name,
        logoUrl: company.logoUrl,
      );
      setState(() => _job = jobWithCompanyInfo);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Lỗi tải job: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _job == null
          ? const Center(child: Text("Không tìm thấy công việc"))
          : SafeArea(
              child: Column(
                children: [
                  // --- Nút back + header ---
                  Padding(
                    padding: const EdgeInsets.only(top: 8, left: 12, right: 12),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.arrow_back_ios_new_rounded,
                            color: Colors.black87,
                          ),
                          // 💡 Sửa: Dùng GoRouter pop
                          onPressed: () => context.pop(), 
                        ),
                        Expanded(
                          child: Center(
                            child: const Text(
                              "Chi tiết công việc",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 48 + 12),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),

                  JobDetailHeader(job: _job!),
                  const SizedBox(height: 8),

                  Container(
                    height: 46,
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: TabBar(
                      controller: _tabController,
                      labelColor: Colors.white,
                      unselectedLabelColor: Colors.black87,
                      dividerColor: Colors.transparent,
                      overlayColor: const MaterialStatePropertyAll(
                        Colors.transparent,
                      ),
                      indicator: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      indicatorSize: TabBarIndicatorSize.tab, 
                      labelStyle: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                      unselectedLabelStyle: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                      tabs: const [
                        Tab(text: 'Mô tả'),
                        Tab(text: 'Công ty'),
                        Tab(text: 'Đánh giá'),
                      ],
                    ),
                  ),

                  // --- Nội dung tab ---
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      physics: const BouncingScrollPhysics(),
                      children: [
                        JobDescriptionTab(
                          job: _job!,
                          getSkillDetailUseCase: _getSkillDetailUseCase,
                          getCategoryDetailUseCase: _getCategoryDetailUseCase,
                        ),
                        JobCompanyTab(
                          companyId: _job!.companyId,
                          useCase: _getCompanyDetailsUseCase,
                        ),
                        JobReviewTab(
                          companyId: _job!.companyId,
                        ),
                      ],
                    ),
                  ),

                  // --- Nút Apply (CÓ ĐIỀU KIỆN) ---
                  if (!widget.hideApplyButton) // 💡 CHỈ HIỂN THỊ NẾU hideApplyButton LÀ FALSE
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppPallete.primaryColor,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () async {
                            final result = await showApplyNoteDialog(context);
                            if (result == null) return; 
                            
                            final notes = result['notes'];
                            final filePath = result['filePath']; 

                            try {
                              final applyResult = await _applyJobUsecase.call(
                                jobId: widget.jobId,
                                notes: notes,
                                filePath: filePath!.isEmpty ? null : filePath,
                              );

                              MotionToast.success(
                                title: const Text("Thành công"),
                                description: const Text(
                                  'Ứng tuyển thành công!',
                                ),
                                animationType: AnimationType.slideInFromLeft,
                                toastAlignment: Alignment.topLeft,
                              ).show(context);
                            } catch (e) {
                              MotionToast.error(
                                description: Text("Ứng tuyển thất bại: $e"),
                              ).show(context);
                            }
                          },
                          child: const Text(
                            "Ứng tuyển",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  
                  // 💡 HIỂN THỊ KHOẢNG ĐỆM NẾU NÚT BỊ ẨN
                  if (widget.hideApplyButton)
                    const SizedBox(height: 16),
                ],
              ),
            ),
    );
  }
}
// lib/features/recruiter/job/presentation/pages/recruiter_job_detail_page.dart
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:motion_toast/motion_toast.dart';
import 'package:pbl6/core/theme/app_pallete.dart';
import 'package:pbl6/features/recruiter/job/presentation/widgets/recruiter_job_description_tab.dart';
import 'package:pbl6/features/shared/category/domain/usecases/get_all_categories_usecase.dart'; // Dùng All thay vì Detail cho recruiter
import 'package:pbl6/features/shared/company/domain/usecases/get_company_details_usecase.dart';
import 'package:pbl6/features/shared/job/domain/entities/job.dart';
import 'package:pbl6/features/shared/job/domain/usecases/get_job_details_usecase.dart';
import 'package:pbl6/features/shared/skill/domain/usecases/get_all_skills_usecase.dart';
import 'package:pbl6/features/user/jobs/presentation/widgets/job_detail_header.dart'; // Re-use



class RecruiterJobDetailPage extends StatefulWidget {
  final String jobId;
  
  // Thêm callback khi job được chỉnh sửa thành công
  final VoidCallback? onJobUpdated;

  const RecruiterJobDetailPage({
    super.key,
    required this.jobId,
    this.onJobUpdated,
  });

  @override
  State<RecruiterJobDetailPage> createState() => _RecruiterJobDetailPageState();
}

class _RecruiterJobDetailPageState extends State<RecruiterJobDetailPage>
    with SingleTickerProviderStateMixin {
  // UseCases
  late final GetJobDetailsUseCase _getJobDetailsUseCase;
  late final GetCompanyDetailsUseCase _getCompanyDetailsUseCase;
  late final GetAllSkillsUseCase _getAllSkillsUseCase;
  late final GetAllCategoriesUseCase _getAllCategoriesUseCase;

  Job? _job;
  bool _isLoading = true;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _getJobDetailsUseCase = GetIt.I<GetJobDetailsUseCase>();
    _getCompanyDetailsUseCase = GetIt.I<GetCompanyDetailsUseCase>();
    _getAllSkillsUseCase = GetIt.I<GetAllSkillsUseCase>();
    _getAllCategoriesUseCase = GetIt.I<GetAllCategoriesUseCase>();
    
    // Chỉ có 2 tabs cho Recruiter
    _tabController = TabController(length: 2, vsync: this);
    _loadJob();
  }

  Future<void> _loadJob() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final job = await _getJobDetailsUseCase(widget.jobId);
      final company = await _getCompanyDetailsUseCase(job.companyId);
      
      final jobWithCompanyInfo = job.copyWith(
        companyName: company.name,
        logoUrl: company.logoUrl,
      );
      
      setState(() => _job = jobWithCompanyInfo);
    } catch (e) {
      if (mounted) {
        MotionToast.error(
          description: Text('Lỗi tải chi tiết tin tuyển dụng: $e'),
        ).show(context);
        Navigator.pop(context); // Quay lại nếu tải thất bại
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _navigateToEditPage() async {
    final result = await context.push(
      '/recruiter/jobs/upsert',
      extra: widget.jobId,
    );
    
    // Nếu trang chỉnh sửa trả về true (cập nhật thành công)
    if (result == true) {
      // Tải lại dữ liệu trang chi tiết
      await _loadJob();
      // Gọi callback để trang danh sách Jobs có thể refresh
      widget.onJobUpdated?.call();
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
                      // --- Nút back + header + Nút Edit ---
                      Padding(
                        padding: const EdgeInsets.only(
                            top: 8, left: 12, right: 12, bottom: 4),
                        child: Row(
                          children: [
                            // 1. Nút back
                            IconButton(
                              icon: const Icon(
                                Icons.arrow_back_ios_new_rounded,
                                color: Colors.black87,
                              ),
                              onPressed: () => Navigator.pop(context),
                            ),
                            const Expanded(
                              child: Center(
                                child: Text(
                                  "Chi tiết tin tuyển dụng",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                            // 2. Nút Edit
                            IconButton(
                              icon: const Icon(
                                Icons.edit,
                                color: AppPallete.primaryColor,
                              ),
                              onPressed: _navigateToEditPage,
                            ),
                          ],
                        ),
                      ),
                      
                      // --- Header công việc (tái sử dụng) ---
                      JobDetailHeader(job: _job!),
                      
                      const SizedBox(height: 8),

                      // --- Tabs (Mô tả & Ứng viên) ---
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
                            Tab(text: 'Ứng viên'),
                          ],
                        ),
                      ),

                      // --- Nội dung tab ---
                      Expanded(
                        child: TabBarView(
                          controller: _tabController,
                          physics: const BouncingScrollPhysics(),
                          children: [
                            // 1. Mô tả công việc (tái sử dụng/chỉnh sửa)
                            RecruiterJobDescriptionTab(
                              job: _job!,
                              getAllSkillsUseCase: _getAllSkillsUseCase,
                              getAllCategoriesUseCase: _getAllCategoriesUseCase,
                            ),
                            // 2. Danh sách ứng viên (placeholder)
                            const Center(
                              child: Text(
                                'Danh sách ứng viên nộp hồ sơ sẽ được hiển thị tại đây.',
                                style: TextStyle(color: Colors.black54),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Recruiter không cần nút Apply
                    ],
                  ),
                ),
    );
  }
}
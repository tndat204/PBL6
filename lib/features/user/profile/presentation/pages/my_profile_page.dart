// file: features/shared/profile/presentation/pages/my_profile_page.dart

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:motion_toast/motion_toast.dart';
import 'package:pbl6/core/theme/app_pallete.dart';
import 'package:pbl6/core/usecase/usecase.dart';
import 'package:pbl6/features/shared/skill/domain/usecases/get_all_skills_usecase.dart';
import 'package:pbl6/features/shared/widgets/custom_app_bar.dart';

import '../../domain/entities/profile_entity.dart';
import '../../domain/usecases/create_profile_usecase.dart';
import '../../domain/usecases/get_cv_url_usecase.dart';
import '../../domain/usecases/get_my_profile_usecase.dart';
import '../../domain/usecases/update_profile_usecase.dart';
import '../../domain/usecases/upload_cv_usecase.dart';
import '../widgets/profile_cv_tab.dart';
import '../widgets/profile_info_tab.dart';

class MyProfilePage extends StatefulWidget {
  const MyProfilePage({super.key});

  @override
  State<MyProfilePage> createState() => _MyProfilePageState();
}

class _MyProfilePageState extends State<MyProfilePage>
    with SingleTickerProviderStateMixin {
  late final GetMyProfileUseCase _getMyProfileUseCase;
  // ✅ BƯỚC 2 (PHẦN 1): KHAI BÁO USE CASE
  late final CreateProfileUseCase _createProfileUseCase;
  late final UpdateProfileUseCase _updateProfileUseCase;
  late final UploadCVUseCase _uploadCVUseCase;
  late final GetAllSkillsUseCase _getAllSkillsUseCase;
  late final GetCVUrlUseCase _getCVUrlUseCase;

  late TabController _tabController;
  bool _isLoading = true;
  String? _errorMessage;
  ProfileEntity? _profile;

  @override
  void initState() {
    super.initState();
    _getMyProfileUseCase = GetIt.I<GetMyProfileUseCase>();
    // ✅ BƯỚC 2 (PHẦN 2): KHỞI TẠO USE CASE
    _createProfileUseCase = GetIt.I<CreateProfileUseCase>();
    _updateProfileUseCase = GetIt.I<UpdateProfileUseCase>();
    _uploadCVUseCase = GetIt.I<UploadCVUseCase>();
    _getAllSkillsUseCase = GetIt.I<GetAllSkillsUseCase>();
    _getCVUrlUseCase = GetIt.I<GetCVUrlUseCase>();

    _tabController = TabController(length: 3, vsync: this);
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    // Không setState _isLoading = true ở đây vì finally sẽ xử lý
    // Chỉ cần đảm bảo trạng thái ban đầu là true
    _isLoading = true;
    _errorMessage = null;
    if (mounted) setState(() {}); // Trigger build để hiện loading

    final result = await _getMyProfileUseCase(NoParams());

    result.fold(
      (failure) {
        if (mounted) {
          setState(() => _errorMessage = failure.message);
          MotionToast.error(
            description: Text('Lỗi tải Profile: ${failure.message}'),
          ).show(context);
        }
      },
      (profileEntity) {
        if (mounted) {
          setState(() => _profile = profileEntity);
        }
      },
    );

    if (mounted) {
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
    // --- Phần Loading ---
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Colors.white, 
        body: Container(
          // Thêm Gradient nền khi loading
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: AppPallete.mainGradient,
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: const Center(child: CircularProgressIndicator()),
        ),
      );
    }

    // --- Phần Lỗi ---
    if (_errorMessage != null && _profile == null) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Container(
          // Thêm Gradient nền khi lỗi
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: AppPallete.mainGradient,
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: SafeArea(
            // Thêm SafeArea
            child: Column(
              children: [
                CustomAppBar(), // Vẫn hiển thị AppBar
                const Spacer(), // Đẩy lỗi xuống giữa
                Center(child: Text('Không thể tải Profile: $_errorMessage')),
                const Spacer(), // Đẩy lỗi xuống giữa
              ],
            ),
          ),
        ),
      );
    }

    // --- Phần Profile null (chưa tạo hoặc lỗi lạ) ---
    final profile = _profile;
    if (profile == null) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Container(
          // Thêm Gradient nền
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: AppPallete.mainGradient,
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: SafeArea(
            // Thêm SafeArea
            child: Column(
              children: [
                CustomAppBar(), // Vẫn hiển thị AppBar
                const Spacer(),
                const Center(
                  child: Text("Profile chưa được tạo hoặc lỗi dữ liệu."),
                ),
                const Spacer(),
                // Có thể thêm nút "Tạo Profile" ở đây
              ],
            ),
          ),
        ),
      );
    }

    // --- Hiển thị chính khi có Profile ---
    return Scaffold(
      backgroundColor: Colors.white, // Đặt màu nền chính là trắng
      body: Container(
        // Container ngoài cùng với Gradient
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: AppPallete.mainGradient,
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomAppBar(),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Hoàn thiện hồ sơ của bạn\n để tăng cơ hội việc làm!',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w400,
                    fontSize: 42,
                    color: AppPallete.textColor,
                    height: 1.3,
                    fontFamily: 'Italianno',
                  ),
                ),
              ),
              const SizedBox(height: 20), // Giữ khoảng cách
              // 💡 Container chứa TabBar và TabBarView với nền trắng
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white, // Nền trắng cho phần tab
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                    border: Border.all(color: Colors.grey.shade200, width: 1),
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 20), // Khoảng cách trên TabBar
                      // --- Tab bar ---
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
                          indicatorSize: TabBarIndicatorSize.tab,
                          indicator: BoxDecoration(
                            color: AppPallete.darkGradient,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          tabs: const [
                            Tab(text: 'Profile'),
                            Tab(text: 'CV & Tài liệu'),
                            Tab(text: 'Đánh giá'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),

                      // --- Nội dung tab ---
                      Expanded(
                        child: TabBarView(
                          controller: _tabController,
                          children: [
                            // 1. Profile Info Tab
                            ProfileInfoTab(
                              profile: profile,
                              // ✅ BƯỚC 3: TRUYỀN USE CASE VÀO WIDGET
                              createProfileUseCase: _createProfileUseCase,
                              updateProfileUseCase: _updateProfileUseCase,
                              getAllSkillsUseCase: _getAllSkillsUseCase,
                            ),
                            // 2. CV & Document Tab
                            ProfileCVTab(
                              cvFileUrl: profile.cvFile,
                              getCVUrlUseCase: _getCVUrlUseCase,
                              uploadCVUseCase: _uploadCVUseCase,
                            ),
                            // 3. Review Tab
                            const Center(
                              child: Text('Đánh giá sẽ được thêm sau.'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

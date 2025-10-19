import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:image_picker/image_picker.dart';
import 'package:motion_toast/motion_toast.dart';
import 'package:pbl6/core/theme/app_pallete.dart';
import 'package:pbl6/features/shared/user/presentation/widgets/my_info_avatar.dart';
import 'package:pbl6/features/shared/user/presentation/widgets/my_info_tab_personal.dart';

import '../../../auth/domain/entities/user_entity.dart';
import '../../domain/usecases/get_my_info_usecase.dart';
import '../../domain/usecases/update_my_info_usecase.dart';
import '../../domain/usecases/upload_avatar_usecase.dart';

class MyInfoPage extends StatefulWidget {
  const MyInfoPage({super.key});

  @override
  State<MyInfoPage> createState() => _MyInfoPageState();
}

class _MyInfoPageState extends State<MyInfoPage>
    with SingleTickerProviderStateMixin {
  late final GetMyInfoUseCase _getMyInfoUseCase;
  late final UpdateMyInfoUseCase _updateMyInfoUseCase;
  late final UploadAvatarUseCase _uploadAvatarUseCase;

  UserEntity? _user;
  bool _isLoading = true;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _getMyInfoUseCase = GetIt.I<GetMyInfoUseCase>();
    _updateMyInfoUseCase = GetIt.I<UpdateMyInfoUseCase>();
    _uploadAvatarUseCase = GetIt.I<UploadAvatarUseCase>();
    _tabController = TabController(length: 2, vsync: this);
    _loadUser();
  }

  Future<void> _loadUser() async {
    try {
      final user = await _getMyInfoUseCase();
      setState(() => _user = user);
    } catch (e) {
      MotionToast.error(
        description: Text('Không thể tải thông tin: $e'),
      ).show(context);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _pickAndUploadAvatar() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;

    try {
      final path = image.path;
      final uploadedUrl = await _uploadAvatarUseCase(path);
      MotionToast(
        icon: Icons.check_circle,
        primaryColor: AppPallete.lightGradient,
        secondaryColor: const Color.fromARGB(255, 74, 98, 138),
        title: const Text(
          "Thành công",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        description: const Text(
          "Cập nhật thành công",
          style: TextStyle(color: AppPallete.backgroundColor),
        ),
        animationType: AnimationType.slideInFromBottom, // 🔹 trượt từ dưới lên
        toastDuration: const Duration(seconds: 2),
        toastAlignment: Alignment.bottomCenter, // 🔹 vị trí ở dưới
        borderRadius: 12,
        width: 320,
        height: 90,
      ).show(context);

      setState(() {
        _user = _user?.copyWith(avatarUrl: uploadedUrl);
      });
    } catch (e) {
      MotionToast.error(description: Text('Upload thất bại: $e')).show(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: Column(
                children: [
                  // 🔹 Header có nút back
                  Padding(
                    padding: const EdgeInsets.only(top: 8, left: 8, right: 8),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back_ios_new_rounded),
                          onPressed: () => Navigator.pop(context),
                        ),
                        const Expanded(
                          child: Center(
                            child: Text(
                              'Thông tin cá nhân',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 48),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),

                  // 🔹 Ảnh đại diện
                  MyInfoAvatar(
                    avatarUrl: _user?.avatarUrl ?? '',
                    onTap: _pickAndUploadAvatar,
                  ),

                  const SizedBox(height: 20),

                  // 🔹 Tab bar
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
                        Tab(text: 'Thông tin cá nhân'),
                        Tab(text: 'Đổi mật khẩu'),
                      ],
                    ),
                  ),

                  // 🔹 Nội dung tab
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        MyInfoTabPersonal(
                          user: _user!,
                          onSave: (data) async {
                            try {
                              await _updateMyInfoUseCase(data);
                              MotionToast(
                                icon: Icons.check_circle,
                                primaryColor: AppPallete.lightGradient,
                                secondaryColor: const Color.fromARGB(
                                  255,
                                  74,
                                  98,
                                  138,
                                ),
                                title: const Text(
                                  "Thành công",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                description: const Text(
                                  "Cập nhật thành công",
                                  style: TextStyle(
                                    color: AppPallete.backgroundColor,
                                  ),
                                ),
                                animationType: AnimationType
                                    .slideInFromLeft, // 🔹 trượt từ dưới lên
                                toastDuration: const Duration(seconds: 2),
                                toastAlignment:
                                    Alignment.bottomCenter, // 🔹 vị trí ở dưới
                                borderRadius: 12,
                                width: 320,
                                height: 90,
                              ).show(context);
                            } catch (e) {
                              MotionToast.error(
                                description: Text('Lỗi cập nhật: $e'),
                              ).show(context);
                            }
                          },
                        ),
                        const Center(
                          child: Text('Tab Đổi mật khẩu — sẽ thêm sau'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

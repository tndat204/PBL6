// file: features/shared/profile/presentation/widgets/profile_info_tab.dart

import 'package:flutter/material.dart';
import 'package:motion_toast/motion_toast.dart';
import 'package:pbl6/core/theme/app_pallete.dart';
// 💡 Import CustomElevatedButton and CustomTextField from correct paths
import 'package:pbl6/features/shared/auth/presentation/widgets/custom_elevated_button.dart';
import 'package:pbl6/features/shared/auth/presentation/widgets/custom_text_field.dart';
// 💡 Correct imports for Skill and UseCase based on your structure
import 'package:pbl6/features/shared/skill/domain/entities/skill.dart';
import 'package:pbl6/features/shared/skill/domain/usecases/get_all_skills_usecase.dart';
import 'package:pbl6/features/user/profile/data/models/profile_models.dart';
import 'package:pbl6/features/user/profile/domain/entities/profile_entity.dart';
import 'package:pbl6/features/user/profile/domain/usecases/create_profile_usecase.dart';
import 'package:pbl6/features/user/profile/domain/usecases/update_profile_usecase.dart';

class ProfileInfoTab extends StatefulWidget {
  final ProfileEntity profile;
  final UpdateProfileUseCase updateProfileUseCase;
  final GetAllSkillsUseCase getAllSkillsUseCase;

  const ProfileInfoTab({
    super.key,
    required this.profile,
    required this.updateProfileUseCase,
    required this.getAllSkillsUseCase,
  });

  @override
  State<ProfileInfoTab> createState() => _ProfileInfoTabState();
}

class _ProfileInfoTabState extends State<ProfileInfoTab> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _headlineController;
  late TextEditingController _summaryController;
  late TextEditingController _linkedinController;
  late TextEditingController _portfolioController;
  late TextEditingController _salaryController;

  List<Skill> _availableSkills = []; // List Skill có thể chọn
  List<SkillEntity> _selectedSkills = []; // Skills hiện tại của User

  bool _isSaving = false;
  bool _isLoadingSkills = true;

  @override
  void initState() {
    super.initState();
    _headlineController = TextEditingController(text: widget.profile.headline);
    _summaryController = TextEditingController(text: widget.profile.summary);
    _linkedinController = TextEditingController(text: widget.profile.linkedinUrl);
    _portfolioController = TextEditingController(text: widget.profile.portfolioUrl);
    _salaryController =
        TextEditingController(text: widget.profile.desiredSalary.toString());
    _selectedSkills =
        List.from(widget.profile.skills.map((s) => s.skill)); // Lấy skills hiện tại
    _loadAvailableSkills();
  }

  Future<void> _loadAvailableSkills() async {
    // 💡 Assume GetAllSkillsUseCase uses NoParams or handle its params if needed
    // final result = await widget.getAllSkillsUseCase(NoParams());
    // result.fold(
    //    (failure) { /* Handle error */ },
    //    (skillsList) {
    //       setState(() => _availableSkills = skillsList);
    //    }
    // );
    // 💡 Temporary fix assuming it returns List<Skill> directly as per your previous code
    try {
      final result = await widget
          .getAllSkillsUseCase(); // Remove NoParams if not needed by your implementation
      if (result is List<Skill>) { // Or handle Either result
        setState(() => _availableSkills = result);
      }
    } catch (e) {
      // Handle error loading skills
      print("Error loading skills: $e");
    }
    setState(() => _isLoadingSkills = false);
  }

  Future<void> _handleUpdate() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    try {
      final requestModel = ProfileRequestModel(
        headline: _headlineController.text.trim(),
        summary: _summaryController.text.trim(),
        linkedinUrl: _linkedinController.text.trim(),
        portfolioUrl: _portfolioController.text.trim(),
        desiredSalary: int.tryParse(_salaryController.text.trim()) ?? 0,
        cvFile: widget.profile.cvFile, // Giữ nguyên CV file URL
        skills: _selectedSkills
            .map((s) => UserSkillRequest(
                  skillId: s.id,
                  experienceYears: 1, // Placeholder: Needs UI to input these
                  level: 'BEGINNER', // Placeholder: Needs UI to input these
                  isPrimary: true, // Placeholder: Needs UI to input these
                ))
            .toList(),
      );

      final result = await widget.updateProfileUseCase(
          ProfileRequestParams(requestModel: requestModel));

      result.fold(
        (failure) {
          MotionToast.error(
            title: const Text("Lỗi"),
            description: Text(failure.message),
            animationType: AnimationType.slideInFromLeft,
            toastAlignment: Alignment.topLeft,
          ).show(context);
        },
        (updatedProfile) {
          // You might want to update the profile state globally here if using a Provider
          setState(() =>
              _selectedSkills = updatedProfile.skills.map((s) => s.skill).toList());
          MotionToast.success(
            title: const Text("Thành công"),
            description: const Text('Cập nhật Profile thành công!'),
            animationType: AnimationType.slideInFromLeft,
            toastAlignment: Alignment.topLeft,
          ).show(context);
        },
      );
    } catch (e) {
      MotionToast.error(
        title: const Text("Lỗi"),
        description: Text('Lỗi cập nhật Profile: $e'),
        animationType: AnimationType.slideInFromLeft,
        toastAlignment: Alignment.topLeft,
      ).show(context);
    } finally {
      if (mounted) { // Check if the widget is still in the tree
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  void dispose() {
    _headlineController.dispose();
    _summaryController.dispose();
    _linkedinController.dispose();
    _portfolioController.dispose();
    _salaryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Basic Info Fields ---
            const Text('Thông tin cơ bản',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            CustomTextField(
              label: 'Vị trí mong muốn (Headline)',
              icon: Icons.work_outline,
              obscureText: false,
              controller: _headlineController,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              label: 'Tóm tắt bản thân (Summary)',
              icon: Icons.notes_outlined,
              obscureText: false,
              controller: _summaryController,
              keyboardType: TextInputType.multiline,
              // ❌ Removed maxLines: 4, as CustomTextField doesn't support it
            ),
            const SizedBox(height: 16),
            CustomTextField(
                label: 'Mức lương mong muốn (USD)',
                icon: Icons.attach_money,
                obscureText: false,
                controller: _salaryController,
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Vui lòng nhập lương';
                  if (int.tryParse(v) == null) return 'Vui lòng nhập số hợp lệ';
                  return null;
                }),
            const SizedBox(height: 24),

            // --- Links ---
            const Text('Liên kết',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            CustomTextField(
              label: 'Liên kết LinkedIn',
              icon: Icons.link,
              obscureText: false,
              controller: _linkedinController,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              label: 'Liên kết Portfolio',
              icon: Icons.web,
              obscureText: false,
              controller: _portfolioController,
            ),
            const SizedBox(height: 24),

            // --- Skills Selection ---
            // ✅ YÊU CẦU 1: Đưa nút "Thêm" lên cạnh tiêu đề "Kỹ năng"
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text('Kỹ năng',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                // Di chuyển nút "Thêm kỹ năng" lên đây
                ElevatedButton.icon(
                  // Vô hiệu hóa nút khi đang tải skills
                  onPressed: _isLoadingSkills ? null : _showSkillSelectionDialog,
                  icon: const Icon(Icons.add_circle_outline,
                      color: Colors.black54, size: 20),
                  // Có thể rút gọn text để vừa vặn hơn
                  label: const Text('Thêm'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey.shade100,
                    foregroundColor: Colors.black87,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                    elevation: 0,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12), // Khoảng cách giữa tiêu đề và chip
            _isLoadingSkills
                ? const Center(child: CircularProgressIndicator())
                // ✅ _buildSkillsChipInput() bây giờ chỉ hiển thị các chip
                : _buildSkillsChipInput(),
            const SizedBox(height: 32),

            // --- Save Button ---
            CustomElevatedButton(
              text: 'Cập nhật Profile',
              // ✅ Corrected onPressed to wrap async call
              onPressed: _isSaving ? null : () => _handleUpdate(),
              // ✅ Pass isLoading state
              isLoading: _isSaving,
            ),
            
            // ✅ YÊU CẦU 2: Thêm khoảng đệm ở dưới cùng
            // Giúp người dùng cuộn qua khỏi bottom bar để thấy nút
            const SizedBox(height: 100), 
          ],
        ),
      ),
    );
  }

  // ✅ YÊU CẦU 1 (Tiếp theo): Cập nhật widget này để CHỈ hiển thị Chip
  // Widget cho phần chọn và hiển thị Skills dưới dạng Chip
  Widget _buildSkillsChipInput() {
    // Thêm trường hợp nếu chưa chọn skill nào
    if (_selectedSkills.isEmpty && !_isLoadingSkills) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        alignment: Alignment.center,
        child: const Text(
          'Chưa có kỹ năng. Nhấn "Thêm" để chọn.',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }
    
    // Chỉ trả về Wrap, không có Column hay Button
    return Wrap(
      spacing: 8.0,
      runSpacing: 4.0,
      children: _selectedSkills
          .map((skill) => Chip(
                label: Text(skill.name),
                backgroundColor:
                    AppPallete.lightGradient, // Use a consistent theme color
                labelStyle: const TextStyle(color: Colors.white),
                deleteIcon:
                    const Icon(Icons.close, size: 18, color: Colors.white),
                onDeleted: () {
                  setState(() {
                    _selectedSkills.removeWhere((s) => s.id == skill.id);
                  });
                },
              ))
          .toList(),
    );
  }

  // Dialog cho phép người dùng chọn Skill từ danh sách
  void _showSkillSelectionDialog() {
    showDialog(
      context: context,
      builder: (context) {
        final availableToSelect = _availableSkills
            .where((availableSkill) => !_selectedSkills
                .any((selectedSkill) => selectedSkill.id == availableSkill.id))
            .toList();

        return AlertDialog(
          title: const Text('Chọn Kỹ năng'),
          content: availableToSelect.isEmpty
              ? const Text('Đã chọn hết tất cả kỹ năng.')
              : SizedBox(
                  width: double.maxFinite,
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: availableToSelect.length,
                    itemBuilder: (context, index) {
                      final skill = availableToSelect[index];
                      return ListTile(
                        title: Text(skill.name),
                        onTap: () {
                          setState(() {
                            // Make sure Skill and SkillEntity are compatible or map appropriately
                            _selectedSkills.add(
                                SkillEntity(id: skill.id, name: skill.name));
                          });
                          Navigator.pop(context); // Close the dialog
                        },
                      );
                    },
                  ),
                ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Đóng'),
            ),
          ],
        );
      },
    );
  }
}
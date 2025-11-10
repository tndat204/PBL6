import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:motion_toast/motion_toast.dart';
import 'package:pbl6/core/theme/app_pallete.dart';
import 'package:pbl6/features/shared/auth/presentation/widgets/custom_elevated_button.dart';
import 'package:pbl6/features/shared/auth/presentation/widgets/custom_text_field.dart';
import 'package:pbl6/features/shared/skill/domain/entities/skill.dart';
import 'package:pbl6/features/shared/skill/domain/usecases/get_all_skills_usecase.dart';
import 'package:pbl6/features/user/profile/data/models/profile_models.dart';
import 'package:pbl6/features/user/profile/domain/entities/profile_entity.dart';
import 'package:pbl6/features/user/profile/domain/usecases/update_profile_usecase.dart';

import '../../domain/usecases/create_profile_usecase.dart';

class ThousandsInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue.copyWith(text: '');
    }

    // Bỏ dấu phẩy cũ
    String newText = newValue.text.replaceAll(',', '');

    // Kiểm tra nếu không phải số thì trả về giá trị cũ
    if (int.tryParse(newText) == null) {
      return oldValue;
    }

    final formatter = NumberFormat('#,###');
    String formattedText = formatter.format(int.parse(newText));

    return newValue.copyWith(
      text: formattedText,
      selection: TextSelection.collapsed(offset: formattedText.length),
    );
  }
}

class ProfileInfoTab extends StatefulWidget {
  final ProfileEntity? profile;
  final CreateProfileUseCase createProfileUseCase;
  final UpdateProfileUseCase updateProfileUseCase;
  final GetAllSkillsUseCase getAllSkillsUseCase;

  const ProfileInfoTab({
    super.key,
    this.profile,
    required this.createProfileUseCase,
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
  List<UserSkillEntity> _selectedUserSkills = [];
  List<Skill> _availableSkills = [];

  bool _isSaving = false;
  bool _isLoadingSkills = true;
  bool _isCreating = false;

  final List<String> _skillLevels = [
    'BEGINNER',
    'INTERMEDIATE',
    'ADVANCED',
    'EXPERT',
  ];

  @override
  void initState() {
    super.initState();

    _isCreating = widget.profile == null;

    final formatter = NumberFormat('#,###');

    _headlineController = TextEditingController(
      text: widget.profile?.headline ?? '',
    );
    _summaryController = TextEditingController(
      text: widget.profile?.summary ?? '',
    );
    _linkedinController = TextEditingController(
      text: widget.profile?.linkedinUrl ?? '',
    );
    _portfolioController = TextEditingController(
      text: widget.profile?.portfolioUrl ?? '',
    );

    // ✅ YÊU CẦU 3: Định dạng lương ban đầu
    _salaryController = TextEditingController(
      text:
          widget.profile?.desiredSalary == null ||
              widget.profile?.desiredSalary == 0
          ? ''
          : formatter.format(widget.profile?.desiredSalary),
    );

    _selectedUserSkills = _isCreating ? [] : List.from(widget.profile!.skills);

    _loadAvailableSkills();
  }

  Future<void> _loadAvailableSkills() async {
    try {
      final result = await widget.getAllSkillsUseCase();
      if (result is List<Skill>) {
        setState(() => _availableSkills = result);
      }
    } catch (e) {
      print("Error loading skills: $e");
    }
    setState(() => _isLoadingSkills = false);
  }

  // ✅ YÊU CẦU 1: Hàm save chung
  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    if (_isCreating) {
      await _handleCreate();
    } else {
      await _handleUpdate();
    }
  }

  // ✅ YÊU CẦU 1: Logic tạo mới
  Future<void> _handleCreate() async {
    setState(() => _isSaving = true);

    try {
      // ✅ YÊU CẦU 3: Lấy giá trị salary đã loại bỏ dấu phẩy
      final salaryString = _salaryController.text.trim().replaceAll(',', '');

      final requestModel = ProfileRequestModel(
        headline: _headlineController.text.trim(),
        summary: _summaryController.text.trim(),
        linkedinUrl: _linkedinController.text.trim(),
        portfolioUrl: _portfolioController.text.trim(),
        desiredSalary: int.tryParse(salaryString) ?? 0,
        cvFile: '', // Khi tạo mới, chưa có UI upload file
        // ✅ YÊU CẦU 2: Map từ state _selectedUserSkills
        skills: _selectedUserSkills
            .map(
              (s) => UserSkillRequest(
                skillId: s.skill.id,
                experienceYears: s.experienceYears,
                level: s.level,
                isPrimary: s.isPrimary,
              ),
            )
            .toList(),
      );

      final result = await widget.createProfileUseCase(
        ProfileRequestParams(requestModel: requestModel),
      );

      result.fold(
        (failure) {
          MotionToast.error(
            title: const Text("Lỗi"),
            description: Text(failure.message),
            animationType: AnimationType.slideInFromLeft,
            toastAlignment: Alignment.topLeft,
          ).show(context);
        },
        (createdProfile) {
          setState(() {
            _selectedUserSkills = createdProfile.skills;
            _isCreating = false; // Chuyển sang chế độ update
          });
          MotionToast.success(
            title: const Text("Thành công"),
            description: const Text('Tạo Profile thành công!'),
            animationType: AnimationType.slideInFromLeft,
            toastAlignment: Alignment.topLeft,
          ).show(context);
        },
      );
    } catch (e) {
      MotionToast.error(
        title: const Text("Lỗi"),
        description: Text('Lỗi tạo Profile: $e'),
        animationType: AnimationType.slideInFromLeft,
        toastAlignment: Alignment.topLeft,
      ).show(context);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  // ✅ YÊU CẦU 1: Logic cập nhật (đã chỉnh sửa)
  Future<void> _handleUpdate() async {
    setState(() => _isSaving = true);

    try {
      // ✅ YÊU CẦU 3: Lấy giá trị salary đã loại bỏ dấu phẩy
      final salaryString = _salaryController.text.trim().replaceAll(',', '');

      final requestModel = ProfileRequestModel(
        headline: _headlineController.text.trim(),
        summary: _summaryController.text.trim(),
        linkedinUrl: _linkedinController.text.trim(),
        portfolioUrl: _portfolioController.text.trim(),
        desiredSalary: int.tryParse(salaryString) ?? 0,
        cvFile: widget.profile!.cvFile, // Giữ CV file cũ
        // ✅ YÊU CẦU 2: Map từ state _selectedUserSkills
        skills: _selectedUserSkills
            .map(
              (s) => UserSkillRequest(
                skillId: s.skill.id,
                experienceYears: s.experienceYears,
                level: s.level,
                isPrimary: s.isPrimary,
              ),
            )
            .toList(),
      );

      final result = await widget.updateProfileUseCase(
        ProfileRequestParams(requestModel: requestModel),
      );

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
          setState(() => _selectedUserSkills = updatedProfile.skills);
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
      if (mounted) setState(() => _isSaving = false);
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

  // Giao diện
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('Thông tin cơ bản'),
            const SizedBox(height: 16),
            CustomTextField(
              label: 'Vị trí mong muốn',
              semanticsLabel: "headlineField",
              icon: Icons.work_outline,
              obscureText: false,
              controller: _headlineController,
              minLines: 1,
              maxLines: 2,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Vị trí mong muốn không được để trống.';
                }
                if (value.trim().length > 200) {
                  return 'Vị trí mong muốn không được vượt quá 200 ký tự.';
                }
                final invalidChars = RegExp(
                  r'[!@#\$%\^&\*\(\)\=\+\{\}\[\];:"<>,\?/]',
                );
                if (invalidChars.hasMatch(value)) {
                  return 'Vị trí mong muốn chứa ký tự không hợp lệ.';
                }
                return null;
              },
            ),

            const SizedBox(height: 14),
            CustomTextField(
              semanticsLabel: "summaryField",
              label: 'Tóm tắt bản thân',
              icon: Icons.notes_outlined,
              obscureText: false,
              controller: _summaryController,
              keyboardType: TextInputType.multiline,
              minLines: 3,
              maxLines: 6,
              validator: (value) {
                if (value != null && value.trim().length > 500) {
                  return 'Tóm tắt không được vượt quá 500 ký tự.';
                }
                return null;
              },
            ),

            const SizedBox(height: 14),
            CustomTextField(
              semanticsLabel: "salaryField",
              label: 'Mức lương mong muốn (VNĐ)',
              icon: Icons.attach_money,
              obscureText: false,
              controller: _salaryController,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                ThousandsInputFormatter(),
              ],
            ),

            const SizedBox(height: 28),
            _buildSectionHeader('Liên kết'),
            const SizedBox(height: 16),
            CustomTextField(
              semanticsLabel: "linkedinField",
              label: 'Liên kết LinkedIn',
              icon: Icons.link,
              obscureText: false,
              controller: _linkedinController,
              validator: (value) {
                if (value == null || value.trim().isEmpty)
                  return null; // cho phép bỏ trống
                final regex = RegExp(
                  r'^(https?:\/\/)?([\w]+\.)?linkedin\.com\/.*$',
                  caseSensitive: false,
                );
                if (!regex.hasMatch(value.trim())) {
                  if (!value.contains('linkedin.com')) {
                    return 'Liên kết phải là đường dẫn LinkedIn.';
                  }
                  return 'Liên kết LinkedIn không hợp lệ.';
                }
                return null;
              },
            ),

            const SizedBox(height: 14),
            CustomTextField(
              semanticsLabel: "portfolioField",
              label: 'Liên kết Portfolio',
              icon: Icons.web,
              obscureText: false,
              controller: _portfolioController,
              validator: (value) {
                if (value == null || value.trim().isEmpty)
                  return null; // cho phép bỏ trống
                final regex = RegExp(
                  r'^(https?:\/\/)?([\w\-]+\.)+[a-zA-Z]{2,}(\/.*)?$',
                );
                if (!regex.hasMatch(value.trim())) {
                  return 'Liên kết Portfolio không hợp lệ.';
                }
                return null;
              },
            ),

            const SizedBox(height: 28),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildSectionHeader('Kỹ năng'),
                ElevatedButton.icon(
                  onPressed: _isLoadingSkills
                      ? null
                      : _showSkillSelectionDialog,
                  icon: const Icon(Icons.add_circle_outline, size: 20),
                  label: const Text('Thêm'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey.shade100,
                    foregroundColor: Colors.black87,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            _isLoadingSkills
                ? const Center(child: CircularProgressIndicator())
                : _buildSkillsChipInput(),
            const SizedBox(height: 36),
            Semantics(
              label: "saveProfileButton",
              button: true,
              child: ExcludeSemantics(
                child: CustomElevatedButton(
                  text: _isCreating ? 'Tạo Profile' : 'Cập nhật Profile',
                  onPressed: _isSaving ? null : _handleSave,
                  isLoading: _isSaving,
                ),
              ),
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
        letterSpacing: 0.3,
      ),
    );
  }

  // ✅ YÊU CẦU 2: Giao diện ListView được cải thiện
  Widget _buildSkillsChipInput() {
    if (_selectedUserSkills.isEmpty && !_isLoadingSkills) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 24),
        alignment: Alignment.center,
        child: const Text(
          'Chưa có kỹ năng nào. Nhấn "Thêm" để chọn.',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    // Dùng ListView.builder thay vì Wrap để có giao diện danh sách
    return ListView.builder(
      itemCount: _selectedUserSkills.length,
      shrinkWrap:
          true, // Quan trọng: Để ListView nằm trong SingleChildScrollView
      physics:
          const NeverScrollableScrollPhysics(), // Không cho ListView cuộn riêng
      itemBuilder: (context, index) {
        final userSkill = _selectedUserSkills[index];

        return Card(
          margin: const EdgeInsets.only(
            bottom: 10.0,
          ), // Khoảng cách giữa các item
          elevation: 2,
          shadowColor: Colors.grey.withOpacity(0.2),
          color: Colors.white, // Nền trắng sạch sẽ
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey.shade200), // Viền nhẹ
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              vertical: 10,
              horizontal: 16,
            ),

            // ✅ YÊU CẦU 2: Thêm icon đầu dòng
            leading: CircleAvatar(
              backgroundColor: AppPallete.primaryColor.withOpacity(
                0.1,
              ), // Màu nền nhẹ từ theme
              child: const Icon(
                Icons.star_border_rounded,
                color: AppPallete.primaryColor, // Màu icon từ theme
              ),
            ),

            // Tiêu đề: Tên kỹ năng
            title: Text(
              userSkill.skill.name,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: Colors.black87,
              ),
            ),

            // ✅ YÊU CẦU 2: Subtitle rõ ràng hơn với Row và Icon
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 6.0), // Thêm khoảng cách
              child: Row(
                mainAxisSize: MainAxisSize.min, // Không chiếm hết chiều ngang
                children: [
                  // Số năm
                  const Icon(
                    Icons.calendar_today_outlined,
                    size: 14,
                    color: Colors.black54,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${userSkill.experienceYears} năm',
                    style: const TextStyle(fontSize: 13, color: Colors.black54),
                  ),

                  // Dấu ngăn cách
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text('•', style: TextStyle(color: Colors.grey)),
                  ),

                  // Cấp độ
                  const Icon(
                    Icons.bar_chart_rounded,
                    size: 16,
                    color: Colors.black54,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    userSkill.level,
                    style: const TextStyle(fontSize: 13, color: Colors.black54),
                  ),
                ],
              ),
            ),

            trailing: IconButton(
              icon: const Icon(
                Icons.delete_outline_rounded,
                color: Colors.redAccent,
              ),
              tooltip: 'Xóa kỹ năng',
              onPressed: () {
                _showDeleteSkillConfirmationDialog(userSkill);
              },
            ),
          ),
        );
      },
    );
  }

  void _showDeleteSkillConfirmationDialog(UserSkillEntity userSkill) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Xác nhận xóa'),

          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'Bạn có chắc muốn xóa kỹ năng:',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                '${userSkill.skill.name}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Hủy'),
            ),
            TextButton(
              // Tô màu đỏ cho nút xóa
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              onPressed: () {
                Navigator.pop(context); // Đóng dialog
                // Thực thi xóa
                setState(() {
                  _selectedUserSkills.removeWhere(
                    (s) => s.skill.id == userSkill.skill.id,
                  );
                });
              },
              child: const Text('Xóa'),
            ),
          ],
        );
      },
    );
  }

  // Dialog chọn skill (vẫn như cũ)
  void _showSkillSelectionDialog() {
    showDialog(
      context: context,
      builder: (context) {
        // ✅ YÊU CẦU 2: Lọc dựa trên _selectedUserSkills
        final availableToSelect = _availableSkills
            .where(
              (availableSkill) => !_selectedUserSkills.any(
                (selectedSkill) => selectedSkill.skill.id == availableSkill.id,
              ),
            )
            .toList();

        return AlertDialog(
          title: const Text(
            "Chọn kĩ năng",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: Colors.black,
            ),
            textAlign: TextAlign.center,
          ),
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
                          Navigator.pop(context); // Đóng dialog chọn
                          // ✅ YÊU CẦU 2: Mở dialog nhập chi tiết
                          _showSkillDetailsDialog(skill);
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

  // ✅ YÊU CẦU 2, 3, 4: Dialog mới để nhập năm kinh nghiệm và level
  void _showSkillDetailsDialog(Skill skill) {
    int selectedYears = 0; // Mặc định 0 năm
    String selectedLevel = _skillLevels.first; // Mặc định là BEGINNER

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          // Dùng để cập nhật UI cho Năm và Cấp độ
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(
                'Chi tiết kỹ năng: ${skill.name}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
              // Giảm padding mặc định của content
              contentPadding: const EdgeInsets.symmetric(vertical: 16),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ✅ YÊU CẦU 3: Giao diện chọn Năm
                  const Text(
                    'Số năm kinh nghiệm',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline),
                        onPressed: () {
                          if (selectedYears > 0) {
                            setDialogState(() => selectedYears--);
                          }
                        },
                      ),
                      const SizedBox(width: 16),
                      Text(
                        '$selectedYears năm',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 16),
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline),
                        onPressed: () {
                          // Giới hạn 30 năm
                          if (selectedYears < 30) {
                            setDialogState(() => selectedYears++);
                          }
                        },
                      ),
                    ],
                  ),
                  const Divider(height: 24),

                  // ✅ YÊU CẦU 4: Giao diện chọn Cấp độ (dạng ListTile)
                  ListTile(
                    title: const Text(
                      'Cấp độ',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(selectedLevel),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      // Mở dialog chọn level
                      _showLevelSelectionDialog(context, (newLevel) {
                        setDialogState(() => selectedLevel = newLevel);
                      });
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Hủy'),
                ),
                ElevatedButton(
                  onPressed: () {
                    // Tạo UserSkillEntity (tạm thời, bạn cần thay bằng Entity thật)
                    // ** GIẢ ĐỊNH **: Bạn có một UserSkillEntity
                    final newUserSkill = UserSkillEntity(
                      skill: SkillEntity(id: skill.id, name: skill.name),
                      experienceYears: selectedYears,
                      level: selectedLevel,
                      isPrimary: true, // Mặc định là true
                    );

                    setState(() {
                      _selectedUserSkills.add(newUserSkill);
                    });
                    Navigator.pop(context); // Đóng dialog chi tiết
                  },
                  child: const Text('Thêm'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ✅ YÊU CẦU 4: Dialog CHỈ để chọn Level (giống chọn Skill)
  void _showLevelSelectionDialog(
    BuildContext dialogContext,
    ValueChanged<String> onLevelSelected,
  ) {
    showDialog(
      context: dialogContext, // Dùng context của dialog trước đó
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Chọn cấp độ',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: Colors.black,
            ),
            textAlign: TextAlign.center,
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _skillLevels.length,
              itemBuilder: (context, index) {
                final level = _skillLevels[index];
                return ListTile(
                  title: Text(level),
                  onTap: () {
                    onLevelSelected(level); // Trả kết quả về
                    Navigator.pop(context); // Đóng dialog chọn level
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

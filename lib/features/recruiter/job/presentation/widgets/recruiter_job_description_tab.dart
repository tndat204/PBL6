// lib/features/recruiter/job/presentation/pages/recruiter_job_description_tab.dart
import 'package:flutter/material.dart';
import 'package:pbl6/features/shared/category/domain/entities/category.dart';
import 'package:pbl6/features/shared/category/domain/usecases/get_all_categories_usecase.dart'; // Dùng GetAll
import 'package:pbl6/features/shared/job/domain/entities/job.dart';
import 'package:pbl6/features/shared/skill/domain/entities/skill.dart';
import 'package:pbl6/features/shared/skill/domain/usecases/get_all_skills_usecase.dart'; // Dùng GetAll

class RecruiterJobDescriptionTab extends StatefulWidget {
  final Job job;
  final GetAllSkillsUseCase getAllSkillsUseCase;
  final GetAllCategoriesUseCase getAllCategoriesUseCase;

  const RecruiterJobDescriptionTab({
    super.key,
    required this.job,
    required this.getAllSkillsUseCase,
    required this.getAllCategoriesUseCase,
  });

  @override
  State<RecruiterJobDescriptionTab> createState() =>
      _RecruiterJobDescriptionTabState();
}

class _RecruiterJobDescriptionTabState
    extends State<RecruiterJobDescriptionTab> {
  List<Skill> _allSkills = [];
  List<Category> _allCategories = [];
  List<Skill> _jobSkills = [];
  List<Category> _jobCategories = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadDetails();
  }

  Future<void> _loadDetails() async {
    try {
      final results = await Future.wait([
        widget.getAllSkillsUseCase(),
        widget.getAllCategoriesUseCase(),
      ]);

      _allSkills = results[0] as List<Skill>;
      _allCategories = results[1] as List<Category>;

      // Lọc ra các Skill và Category của Job hiện tại
      _jobSkills = _allSkills
          .where((s) => widget.job.skillIds.contains(s.id))
          .toList();
      _jobCategories = _allCategories
          .where((c) => widget.job.categoryIds.contains(c.id))
          .toList();
    } catch (e) {
      debugPrint('Lỗi tải kỹ năng/category cho Recruiter: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // Helper định dạng trình độ (Tái sử dụng)
  String _formatExperienceLevel(ExperienceLevel level) {
    switch (level) {
      case ExperienceLevel.INTERN:
        return 'Thực tập sinh';
      case ExperienceLevel.FRESHER:
        return 'Mới tốt nghiệp';
      case ExperienceLevel.JUNIOR:
        return 'Nhân viên (Junior)';
      case ExperienceLevel.SENIOR:
        return 'Chuyên viên (Senior)';
      case ExperienceLevel.PRINCIPAL:
        return 'Chuyên gia cao cấp (Principal)';
      case ExperienceLevel.MANAGER:
        return 'Quản lý / Trưởng nhóm';
      case ExperienceLevel.ANY:
        return 'Không yêu cầu kinh nghiệm';
    }
  }

  // Helper định dạng số năm kinh nghiệm (Tái sử dụng)
  String _formatYearsExperience(int min, int max) {
    if (min == 0 && max == 0) return 'Không yêu cầu';
    if (min == max) return '$min năm';
    if (max > 15) return 'Trên $min năm'; 
    return '$min - $max năm';
  }

  // Widget build tiêu đề (Tái sử dụng)
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: Colors.black87,
        letterSpacing: 0.3,
      ),
    );
  }

  // Widget build dòng thông tin (Tái sử dụng)
  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.grey.shade600),
        const SizedBox(width: 12),
        Text(
          '$label:',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ),
      ],
    );
  }

  // Widget build chip (Tái sử dụng)
  Widget _buildChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.grey.shade300, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.grey.shade700),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.black87,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Mục yêu cầu công việc
          _buildSectionTitle("Yêu cầu công việc"),
          const SizedBox(height: 16),
          _buildInfoRow(
            Icons.bar_chart_rounded,
            "Trình độ",
            _formatExperienceLevel(widget.job.experienceLevel),
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            Icons.work_history_rounded,
            "Kinh nghiệm",
            _formatYearsExperience(
              widget.job.requiredYearsOfExpMin,
              widget.job.requiredYearsOfExpMax,
            ),
          ),
          const SizedBox(height: 32),

          // --- Mục mô tả ---
          _buildSectionTitle("Mô tả công việc"),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Text(
              widget.job.description,
              style: const TextStyle(
                fontSize: 14,
                height: 1.6,
                color: Colors.black87,
              ),
            ),
          ),

          // --- Mục danh mục ---
          const SizedBox(height: 32),
          _buildSectionTitle("Danh mục"),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _jobCategories.isEmpty
                ? [const Text("Không có danh mục")]
                : _jobCategories
                    .map((c) => _buildChip(Icons.category_outlined, c.name))
                    .toList(),
          ),

          // --- Mục kỹ năng ---
          const SizedBox(height: 32),
          _buildSectionTitle("Kỹ năng yêu cầu"),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _jobSkills.isEmpty
                ? [const Text("Không có kỹ năng")]
                : _jobSkills.map((s) => _buildChip(Icons.code, s.name)).toList(),
          ),
        ],
      ),
    );
  }
}
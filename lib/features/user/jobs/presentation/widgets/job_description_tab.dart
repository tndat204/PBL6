import 'package:flutter/material.dart';
import 'package:pbl6/features/shared/category/domain/entities/category.dart';
import 'package:pbl6/features/shared/skill/domain/entities/skill.dart';
import 'package:pbl6/features/shared/skill/domain/usecases/get_skill_detail_usecase.dart';

import '../../../../shared/category/domain/usecases/get_category_detail_usecase.dart';
import '../../domain/entities/job.dart';

class JobDescriptionTab extends StatefulWidget {
  final Job job;
  final GetSkillDetailUseCase getSkillDetailUseCase;
  final GetCategoryDetailUseCase getCategoryDetailUseCase;

  const JobDescriptionTab({
    super.key,
    required this.job,
    required this.getSkillDetailUseCase,
    required this.getCategoryDetailUseCase,
  });

  @override
  State<JobDescriptionTab> createState() => _JobDescriptionTabState();
}

class _JobDescriptionTabState extends State<JobDescriptionTab> {
  List<Skill> _skills = [];
  List<Category> _categories = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadDetails();
  }

  Future<void> _loadDetails() async {
    try {
      final skillFutures = widget.job.skillIds
          .map((id) => widget.getSkillDetailUseCase(id))
          .toList();

      final categoryFutures = widget.job.categoryIds
          .map((id) => widget.getCategoryDetailUseCase(id))
          .toList();

      final results = await Future.wait([
        Future.wait(skillFutures),
        Future.wait(categoryFutures),
      ]);

      final List<Skill?> fetchedSkills = results[0] as List<Skill?>;
      final List<Category?> fetchedCategories = results[1] as List<Category?>;

      setState(() {
        _skills = fetchedSkills.whereType<Skill>().toList();
        _categories = fetchedCategories.whereType<Category>().toList();
      });
    } catch (e) {
      debugPrint('Lỗi tải kỹ năng/category: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  // THÊM: Helper định dạng trình độ
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

  // THÊM: Helper định dạng số năm kinh nghiệm
  String _formatYearsExperience(int min, int max) {
    if (min == 0 && max == 0) return 'Không yêu cầu';
    if (min == max) return '$min năm';
    if (max > 15) return 'Trên $min năm'; // Giả sử max là số lớn (vd: 99)
    return '$min - $max năm';
  }

  // THÊM: Widget build tiêu đề (để tái sử dụng)
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: Colors.black87,
        letterSpacing: 0.3,
      ),
    );
  }

  // THÊM: Widget build dòng thông tin (cho yêu cầu)
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
          // THÊM: Mục yêu cầu công việc
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
            children: _categories.isEmpty
                ? [const Text("Không có danh mục")]
                : _categories
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
            children: _skills.isEmpty
                ? [const Text("Không có kỹ năng")]
                : _skills.map((s) => _buildChip(Icons.code, s.name)).toList(),
          ),
        ],
      ),
    );
  }

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
}

import 'package:flutter/material.dart';
import 'package:pbl6/features/shared/category/domain/entities/category.dart';
import 'package:pbl6/features/shared/skill/domain/entities/skill.dart';
import 'package:pbl6/features/shared/skill/domain/usecases/get_skill_detail_usecase.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../shared/category/domain/usecases/get_category_detail_usecase.dart';
import '../../../../shared/job/domain/entities/job.dart';

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

  String _formatYearsExperience(int min, int max) {
    if (min == 0 && max == 0) return 'Không yêu cầu';
    if (min == max) return '$min năm';
    if (max > 15) return 'Trên $min năm';
    return '$min - $max năm';
  }

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

  Widget _buildJdFileSection() {
    final jdUrl = widget.job.jdFile.trim();
    if (jdUrl.isEmpty) return const SizedBox.shrink();

    final Uri url = Uri.parse(jdUrl);
    final fileName = jdUrl.split('/').last.split('?').first;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle("File JD"),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  fileName,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.remove_red_eye, color: Colors.blueAccent),
                tooltip: "Xem JD",
                onPressed: () async {
                  if (await canLaunchUrl(url)) {
                    await launchUrl(url, mode: LaunchMode.externalApplication);
                  } else if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Không thể mở file JD.')),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());

    final showDescription = widget.job.description.isNotEmpty;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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

          _buildSectionTitle("Mô tả công việc"),
          const SizedBox(height: 12),
          showDescription
              ? Text(
                  widget.job.description,
                  style: const TextStyle(fontSize: 14, height: 1.6, color: Colors.black87),
                )
              : Text(
                  "Thông tin mô tả công việc sẽ được cập nhật sau.",
                  style: TextStyle(color: Colors.grey.shade600, fontStyle: FontStyle.italic),
                ),
          const SizedBox(height: 32),

          if (widget.job.jdFile.isNotEmpty) _buildJdFileSection(),
          const SizedBox(height: 32),

          _buildSectionTitle("Danh mục"),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _categories.isEmpty
                ? [const Text("Không có danh mục")]
                : _categories.map((c) => _buildChip(Icons.category_outlined, c.name)).toList(),
          ),
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
          const SizedBox(height: 50),
        ],
      ),
    );
  }
}

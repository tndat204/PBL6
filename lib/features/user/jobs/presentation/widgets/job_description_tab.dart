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
          Text(
            "Mô tả công việc",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
              letterSpacing: 0.3,
            ),
          ),
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

          const SizedBox(height: 32),
          Text(
            "Danh mục",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
              letterSpacing: 0.3,
            ),
          ),
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

          const SizedBox(height: 32),
          Text(
            "Kỹ năng yêu cầu",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _skills.isEmpty
                ? [const Text("Không có kỹ năng")]
                : _skills
                    .map((s) => _buildChip(Icons.code, s.name))
                    .toList(),
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

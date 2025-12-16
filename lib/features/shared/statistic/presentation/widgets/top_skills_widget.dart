import 'package:flutter/material.dart';
import 'package:pbl6/core/theme/app_pallete.dart';

import '../../domain/entities/statistic.dart';
 

class TopSkillsWidget extends StatelessWidget {
  final List<SkillStat> skills;

  const TopSkillsWidget({super.key, required this.skills});

  @override
  Widget build(BuildContext context) {
    if (skills.isEmpty) return const SizedBox.shrink();

    // Tìm giá trị lớn nhất để tính % độ dài thanh
    int maxCount = skills.map((e) => e.jobCount).reduce((a, b) => a > b ? a : b);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
        const Row(
            children: [
              Icon(Icons.local_fire_department, color: Colors.orange, size: 24),
              SizedBox(width: 8),
              Text(
                "Top Kỹ Năng Đang Hot",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...skills.map((skill) {
            double percentage = maxCount > 0 ? skill.jobCount / maxCount : 0;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Row(
                children: [
                  SizedBox(
                    width: 80,
                    child: Text(
                      skill.skillName.toUpperCase(),
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: Colors.black54),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Stack(
                      children: [
                        Container(
                          height: 10,
                          decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(5)),
                        ),
                        FractionallySizedBox(
                          widthFactor: percentage,
                          child: Container(
                            height: 10,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(colors: [AppPallete.lightGradient, AppPallete.darkGradient]),
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    "${skill.jobCount}",
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppPallete.primaryColor),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}
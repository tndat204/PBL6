import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pbl6/core/theme/app_pallete.dart';

import '../../domain/entities/statistic.dart';


class SalaryInsightsWidget extends StatelessWidget {
  final List<SalaryStat> salaryStats;

  const SalaryInsightsWidget({super.key, required this.salaryStats});

  String formatCurrency(double amount) {
    final format = NumberFormat.compactCurrency(locale: 'vi', symbol: 'đ', decimalDigits: 0);
    return format.format(amount).replaceAll('T', 'Tr');
  }

  @override
  Widget build(BuildContext context) {
    if (salaryStats.isEmpty) return const SizedBox.shrink();

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
              Icon(Icons.monetization_on, color: Colors.amberAccent, size: 24),
              SizedBox(width: 8),
              Expanded( 
                child: Text(
                  "Mức Lương Theo Kinh Nghiệm",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...salaryStats.map((stat) => Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade200),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      stat.experienceLevel,
                      style: const TextStyle(fontWeight: FontWeight.bold, color: AppPallete.primaryColor),
                    ),
                    Text(
                      "${stat.jobCount} tin",
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(formatCurrency(stat.avgSalaryMin), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                    Expanded(
                      child: Container(
                        height: 6,
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(3),
                          gradient: LinearGradient(
                            colors: [Colors.green.withOpacity(0.3), Colors.green],
                          ),
                        ),
                      ),
                    ),
                    Text(formatCurrency(stat.avgSalaryMax), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                  ],
                )
              ],
            ),
          )).toList(),
        ],
      ),
    );
  }
}
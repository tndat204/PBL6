import 'package:flutter/material.dart';
import 'package:pbl6/core/theme/app_pallete.dart';
import 'package:pbl6/features/ai_matching/domain/entities/ai_matching_entities.dart'; // Import MatchWeights

class AiFilterBottomSheet extends StatefulWidget {
  final Function(MatchWeights weights, int topK) onApply;

  const AiFilterBottomSheet({super.key, required this.onApply});

  @override
  State<AiFilterBottomSheet> createState() => _AiFilterBottomSheetState();
}

class _AiFilterBottomSheetState extends State<AiFilterBottomSheet> {
  // Mặc định weights (nhân 100 để hiển thị trên Slider)
  double _techSkills = 30;
  double _softSkills = 30;
  double _experience = 25;
  double _education = 10;
  double _other = 5;

  int _selectedTopK = 0; // 0 = All

  double get _totalWeight => _techSkills + _softSkills + _experience + _education + _other;
  bool get _isValid => (_totalWeight - 100).abs() < 0.1; // So sánh double an toàn

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle Bar
          Center(
            child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
          ),
          const SizedBox(height: 16),
          const Text("Điều chỉnh bộ lọc AI", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text("Tùy chỉnh trọng số đánh giá và số lượng hồ sơ hiển thị.", style: TextStyle(color: Colors.grey)),
          const Divider(),

          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Chọn Top K
                  const Text("Hiển thị kết quả:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    children: [0, 3, 5, 10].map((k) {
                      final isSelected = _selectedTopK == k;
                      return ChoiceChip(
                        label: Text(k == 0 ? "Tất cả (Sắp xếp)" : "Top $k"),
                        selected: isSelected,
                        selectedColor: AppPallete.primaryColor, // Sử dụng màu primary
                        labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black),
                        checkmarkColor: Colors.white,
                        onSelected: (val) => setState(() => _selectedTopK = k),
                        backgroundColor: Colors.white,
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 24),
                  
                  // Điều chỉnh Weights
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Trọng số đánh giá:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      Text(
                        "Tổng: ${_totalWeight.toStringAsFixed(0)}%", 
                        style: TextStyle(
                          fontWeight: FontWeight.bold, 
                          color: _isValid ? Colors.green : Colors.red
                        ),
                      ),
                    ],
                  ),
                  if (!_isValid)
                    const Padding(
                      padding: EdgeInsets.only(top: 4),
                      child: Text("Tổng trọng số phải bằng 100%", style: TextStyle(color: Colors.red, fontSize: 12)),
                    ),
                  const SizedBox(height: 10),

                  _buildSlider("Kỹ năng chuyên môn", _techSkills, (v) => setState(() => _techSkills = v)),
                  _buildSlider("Kỹ năng mềm", _softSkills, (v) => setState(() => _softSkills = v)),
                  _buildSlider("Kinh nghiệm", _experience, (v) => setState(() => _experience = v)),
                  _buildSlider("Học vấn", _education, (v) => setState(() => _education = v)),
                  _buildSlider("Khác", _other, (v) => setState(() => _other = v)),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _isValid 
                ? () {
                    Navigator.pop(context);
                    final weights = MatchWeights(
                      technicalSkills: _techSkills / 100,
                      softSkills: _softSkills / 100,
                      experience: _experience / 100,
                      education: _education / 100,
                      other: _other / 100,
                    );
                    widget.onApply(weights, _selectedTopK);
                  }
                : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppPallete.primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text("Phân tích ngay", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSlider(String label, double value, Function(double) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 14)),
            Text("${value.toInt()}%", style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 4,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
          ),
          child: Slider(
            value: value,
            min: 0,
            max: 100,
            divisions: 20,
            activeColor: AppPallete.primaryColor,
            inactiveColor: Colors.grey[200],
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}
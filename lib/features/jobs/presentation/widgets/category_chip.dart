import 'package:flutter/material.dart';
import 'package:pbl6/core/theme/app_pallete.dart';

import '../models/category_ui_model.dart';

class CategoryChip extends StatelessWidget {
  final CategoryUiModel uiModel;
  final Function(CategoryUiModel)? onSelected;

  const CategoryChip({
    Key? key,
    required this.uiModel,
    this.onSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool selected = uiModel.isSelected;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: ChoiceChip(
        label: Text(
          uiModel.category.name,
          style: TextStyle(
            color: selected ? Colors.white : Colors.grey.shade800,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
            fontSize: 14,
          ),
        ),
        selected: selected,
        selectedColor: Colors.black, // nền khi chọn
        backgroundColor: Colors.grey.shade300, // nền khi không chọn
        checkmarkColor: Colors.white, // icon tick màu trắng
        showCheckmark: true, // hiển thị tick
        onSelected: (val) {
          final updated = uiModel.copyWith(isSelected: val);
          onSelected?.call(updated);
        },
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: AppPallete.borderColor,), // bỏ viền hoàn toàn
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      ),
    );
  }
}

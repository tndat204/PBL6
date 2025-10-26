// file: features/user/jobs/presentation/widgets/category_chip.dart
import 'package:flutter/material.dart';

// Remove AppPallete import if not needed for colors here
// import 'package:pbl6/core/theme/app_pallete.dart';

import '../models/category_ui_model.dart'; // Ensure this path is correct

class CategoryChip extends StatelessWidget {
  final CategoryUiModel uiModel;
  // Use ValueChanged for better type safety
  final ValueChanged<CategoryUiModel>? onSelected;

  const CategoryChip({
    Key? key,
    required this.uiModel,
    this.onSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool selected = uiModel.isSelected;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0), // Adjust spacing
      child: ChoiceChip(
        label: Text(
          // Use name from the actual Category object inside uiModel
          uiModel.category.name,
          style: TextStyle(
            // ✅ White text when selected, dark grey otherwise
            color: selected ? Colors.white : Colors.grey.shade700,
            // ✅ Slightly bolder when selected
            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
            fontSize: 14,
          ),
        ),
        selected: selected,
        // ✅ Black background when selected, light grey otherwise
        selectedColor: Colors.black,
        backgroundColor: Colors.grey.shade200,
        // ✅ Hide the checkmark
        showCheckmark: false,
        onSelected: (isSelected) {
          // Only trigger the callback if the chip is being *selected*
          if (isSelected) {
            onSelected?.call(uiModel);
          }
        },
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20), // Standard chip radius
          // ✅ No border
          side: BorderSide.none,
        ),
        // Adjust padding for a better look
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        // Remove elevation for a flatter look
        pressElevation: 0,
        elevation: 0,
      ),
    );
  }
}
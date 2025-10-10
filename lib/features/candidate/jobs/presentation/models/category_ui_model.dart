import '../../domain/entities/category.dart';

class CategoryUiModel {
  final Category category; // Wrap entity
  final bool isSelected; // UI state

  const CategoryUiModel({
    required this.category,
    this.isSelected = false,
  });

  // Factory để map từ entity (dùng khi load data)
  factory CategoryUiModel.fromEntity(Category entity, {bool isSelected = false}) {
    return CategoryUiModel(
      category: entity,
      isSelected: isSelected,
    );
  }

  // Factory để toggle selected
  CategoryUiModel copyWith({bool? isSelected}) {
    return CategoryUiModel(
      category: category,
      isSelected: isSelected ?? this.isSelected,
    );
  }
}
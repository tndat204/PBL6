class Skill {
  final String id; // UUID
  final String name;
  final String categoryId; // FK to Category

  const Skill({
    required this.id,
    required this.name,
    required this.categoryId,
  });
}
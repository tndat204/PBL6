class Skill {
  final String id;
  final String name;
  final String? categoryId;

  const Skill({
    required this.id,
    required this.name,
    this.categoryId,
  });

  factory Skill.fromJson(Map<String, dynamic> json) {
    return Skill(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      categoryId: json['categoryId'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'categoryId': categoryId,
      };
}

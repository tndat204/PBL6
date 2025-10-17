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
    // ✅ SỬA: Dùng Map.from() để ép kiểu an toàn cho đối tượng chính
    final rawData = json['result'] ?? json;
    final data = Map<String, dynamic>.from(rawData as Map); 

    return Skill(
      id: data['id'] ?? '',
      name: data['name'] ?? '',
      categoryId: data['categoryId'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'categoryId': categoryId,
  };
}
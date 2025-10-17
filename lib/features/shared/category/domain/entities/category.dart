import 'package:pbl6/features/shared/skill/domain/entities/skill.dart';

class Category {
  final String id;
  final String name;
  final String? description;
  final List<Skill> skills;

  const Category({
    required this.id,
    required this.name,
    this.description,
    required this.skills,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    // ✅ SỬA: Dùng Map.from() để ép kiểu an toàn cho đối tượng chính
    final rawData = json['result'] ?? json;
    final data = Map<String, dynamic>.from(rawData as Map); 

    return Category(
      id: data['id'] ?? '',
      name: data['name'] ?? '',
      description: data['description'],
      skills: (data['skills'] as List?)
          ?.map((e) {
            // ✅ SỬA: Dùng Map.from() để ép kiểu an toàn cho từng Skill bên trong list
            final skillJson = Map<String, dynamic>.from(e as Map); 
            return Skill.fromJson(skillJson);
          })
          .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'skills': skills.map((s) => s.toJson()).toList(),
  };
}
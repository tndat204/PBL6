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
    return Category(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'],
      skills: (json['skills'] as List<dynamic>?)
              ?.map((e) => Skill.fromJson(e))
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

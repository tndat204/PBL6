class ReportReason {
  final String key;
  final String label;
  final String description;

  ReportReason({
    required this.key,
    required this.label,
    required this.description,
  });

  factory ReportReason.fromJson(Map<String, dynamic> json) {
    return ReportReason(
      key: json['key'] as String? ?? '',
      label: json['label'] as String? ?? '',
      description: json['description'] as String? ?? '',
    );
  }
}
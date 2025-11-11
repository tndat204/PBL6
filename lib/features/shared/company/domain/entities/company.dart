class Company {
  final String id; // UUID trong DB
  final String name;
  final String taxCode; // Mã số thuế
  final String address;
  final String? phone;
  final String? email;
  final String? description;
  final bool active;
  final String? logoUrl;

  const Company({
    required this.id,
    required this.name,
    required this.taxCode,
    required this.address,
    this.phone,
    this.email,
    this.description,
    required this.active,
    this.logoUrl,
  });

  factory Company.fromJson(Map<String, dynamic> json) {
    return Company(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      taxCode: json['taxCode'] ?? '',
      address: json['address'] ?? '',
      phone: json['phone'],
      email: json['email'],
      description: json['description'],
      active: json['active'] ?? false,
      logoUrl: json['logoUrl'],
    );
  }
}

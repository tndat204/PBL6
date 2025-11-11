import 'package:equatable/equatable.dart';

class Company extends Equatable {
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

  /// [copyWith] để tạo bản sao của đối tượng với các giá trị được cập nhật
  Company copyWith({
    String? id,
    String? name,
    String? taxCode,
    String? address,
    String? phone,
    String? email,
    String? description,
    bool? active,
    String? logoUrl,
  }) {
    return Company(
      id: id ?? this.id,
      name: name ?? this.name,
      taxCode: taxCode ?? this.taxCode,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      description: description ?? this.description,
      active: active ?? this.active,
      logoUrl: logoUrl ?? this.logoUrl,
    );
  }

 
  factory Company.fromJson(Map<String, dynamic> json) {
   
    final data = (json.containsKey('result') && json['result'] is Map)
        ? json['result'] as Map<String, dynamic>
        : json;

    return Company(
      id: data['id'] ?? '',
      name: data['name'] ?? '',
      taxCode: data['taxCode'] ?? '',
      address: data['address'] ?? '',
      phone: data['phone'],
      email: data['email'],
      description: data['description'],
      active: data['active'] ?? false,
      logoUrl: data['logoUrl'],
    );
  }

  
  Map<String, dynamic> toJsonForUpdate() {
    return {
      "name": name,
      "taxCode": taxCode,
      "address": address,
      "phone": phone,
      "email": email,
      "description": description,
      // Lưu ý: 'id', 'active', 'logoUrl' không được gửi trong body update này
    };
  }

  @override
  List<Object?> get props => [
        id,
        name,
        taxCode,
        address,
        phone,
        email,
        description,
        active,
        logoUrl
      ];
}
class RegisterRequest {
  final String username;
  final String password;
  final String email;
  final String phone;
  final String fullName;
  final String address;
  final String taxCode;
  final String nameCompany;
  final String avatarUrl;
  final DateTime birthDate;

  RegisterRequest({
    required this.username,
    required this.password,
    required this.email,
    required this.phone,
    required this.fullName,
    required this.address,
    required this.taxCode,
    required this.nameCompany,
    required this.avatarUrl,
    required this.birthDate,
  });

  Map<String, dynamic> toJson() => {
        "username": username,
        "password": password,
        "email": email,
        "phone": phone,
        "fullName": fullName,
        "address": address,
        "taxCode": taxCode,
        "nameCompany": nameCompany,
        "avatarUrl": avatarUrl,
        "birthDate": birthDate.toIso8601String(),
      };
}

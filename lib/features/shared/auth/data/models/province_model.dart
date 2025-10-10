class Province {
  final String name;
  final int code;
  final String divisionType;
  final String codename;
  final int phoneCode;
  final List<dynamic> districts;

  Province({
    required this.name,
    required this.code,
    required this.divisionType,
    required this.codename,
    required this.phoneCode,
    required this.districts,
  });

  factory Province.fromJson(Map<String, dynamic> json) {
    return Province(
      name: json['name'],
      code: json['code'],
      divisionType: json['division_type'],
      codename: json['codename'],
      phoneCode: json['phone_code'],
      districts: json['districts'],
    );
  }
}

class Ward {
  final String name;
  final int code;

  Ward({required this.name, required this.code});

  factory Ward.fromJson(Map<String, dynamic> json) {
    return Ward(
      name: json['name'],
      code: json['code'],
    );
  }
}
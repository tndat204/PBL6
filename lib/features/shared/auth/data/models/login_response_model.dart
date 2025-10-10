class LoginResponse {
  final int code;
  final LoginResult? result;

  LoginResponse({required this.code, this.result});

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      code: json['code'],
      result: json['result'] != null ? LoginResult.fromJson(json['result']) : null,
    );
  }
}

class LoginResult {
  final String token;

  LoginResult({required this.token});

  factory LoginResult.fromJson(Map<String, dynamic> json) {
    return LoginResult(
      token: json['token'],
    );
  }
}

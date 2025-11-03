class LoginResponse {
  final int code;
  final String message;
  final LoginResult? result;

  LoginResponse({
    required this.code,
    required this.message,
    this.result,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      code: json['code'] ?? 0,
      message: json['message'] ?? '',
      result: json['result'] != null ? LoginResult.fromJson(json['result']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'message': message,
      'result': result?.toJson(),
    };
  }
}

class LoginResult {
  final String token;

  LoginResult({required this.token});

  factory LoginResult.fromJson(Map<String, dynamic> json) {
    return LoginResult(
      token: json['token'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'token': token,
    };
  }
}
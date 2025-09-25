class LoginResponse {
  final int code;
  final String? message;
  final LoginResult? result;

  LoginResponse({required this.code, this.message, this.result});

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      code: json['code'],
      message: json['message'],
      result: json['result'] != null ? LoginResult.fromJson(json['result']) : null,
    );
  }
}

class LoginResult {
  final String? token; 
  final bool? authenticated; 

  LoginResult({this.token, this.authenticated});

  factory LoginResult.fromJson(Map<String, dynamic> json) {
    return LoginResult(
      token: json['token'],
      authenticated: json['authenticated'],
    );
  }
}
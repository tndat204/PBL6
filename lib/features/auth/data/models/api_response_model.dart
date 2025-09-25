// features/auth/data/models/api_response_model.dart
class APIResponse<T> {
  final int code;
  final T? result;
  final String? message;

  APIResponse({required this.code, this.result, this.message});

  factory APIResponse.fromJson(Map<String, dynamic> json, T Function(dynamic) fromJsonT) {
    return APIResponse(
      code: json['code'],
      result: json['result'] != null ? fromJsonT(json['result']) : null,
      message: json['message'],
    );
  }
}
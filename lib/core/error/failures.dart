// file: core/error/failures.dart

import 'package:equatable/equatable.dart';

// Lớp cơ sở (Abstract class) cho tất cả các loại lỗi.
abstract class Failure extends Equatable {
  final String message;

  const Failure({required this.message});

  @override
  List<Object> get props => [message];
}

// Lỗi khi giao tiếp với máy chủ (API, Dio errors, HTTP status code 4xx/5xx).
class ServerFailure extends Failure {
  const ServerFailure({required String message}) : super(message: message);
}

// Lỗi khi không có kết nối internet (thường được xử lý ở Data Source).
class NetworkFailure extends Failure {
  const NetworkFailure({String message = 'Không có kết nối Internet'})
      : super(message: message);
}

// Lỗi khi dữ liệu cục bộ không tìm thấy hoặc bị lỗi.
class CacheFailure extends Failure {
  const CacheFailure({required String message}) : super(message: message);
}
// file: core/usecase/usecase.dart

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:pbl6/core/error/failures.dart';

abstract class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}

// Lớp dùng cho các Use Case không cần tham số.
class NoParams extends Equatable {
  @override
  List<Object> get props => [];
}
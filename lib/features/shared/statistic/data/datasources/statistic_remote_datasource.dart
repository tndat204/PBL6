import 'package:dio/dio.dart';
import 'package:pbl6/core/constants/api_constants.dart';

import '../../domain/entities/statistic.dart';


abstract class StatisticRemoteDataSource {
  Future<List<SkillStat>> getTopSkills({int limit = 10});

  Future<List<SalaryStat>> getSalaryStats();

  Future<List<LocationStat>> getLocationStats();
}


class StatisticRemoteDataSourceImpl implements StatisticRemoteDataSource {
  final Dio _dio;

  StatisticRemoteDataSourceImpl(this._dio) {
    _dio.options.baseUrl = ApiConstants.baseUrl;
  }

  @override
  Future<List<SkillStat>> getTopSkills({int limit = 10}) async {
    try {

      final response = await _dio.get(
        '${ApiConstants.statistics}/top-skills',
        queryParameters: {'limit': limit},
      );

      if (response.statusCode == 200 && response.data['result'] != null) {
        final List<dynamic> listData = response.data['result'];
        return listData.map((e) => SkillStat.fromJson(e)).toList();
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          message: "Dữ liệu trả về không hợp lệ",
        );
      }
    } on DioException {
      rethrow;
    } catch (e) {
      throw Exception('Lỗi không xác định: $e');
    }
  }

  @override
  Future<List<SalaryStat>> getSalaryStats() async {
    try {
      final response = await _dio.get('${ApiConstants.statistics}/salary');

      if (response.statusCode == 200 && response.data['result'] != null) {
        final List<dynamic> listData = response.data['result'];
        return listData.map((e) => SalaryStat.fromJson(e)).toList();
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          message: "Dữ liệu trả về không hợp lệ",
        );
      }
    } on DioException {
      rethrow;
    } catch (e) {
      throw Exception('Lỗi không xác định: $e');
    }
  }

  @override
  Future<List<LocationStat>> getLocationStats() async {
    try {
      final response = await _dio.get('${ApiConstants.statistics}/locations');

      if (response.statusCode == 200 && response.data['result'] != null) {
        final List<dynamic> listData = response.data['result'];
        return listData.map((e) => LocationStat.fromJson(e)).toList();
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          message: "Dữ liệu trả về không hợp lệ",
        );
      }
    } on DioException {
      rethrow;
    } catch (e) {
      throw Exception('Lỗi không xác định: $e');
    }
  }
}

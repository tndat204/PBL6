import 'package:dio/dio.dart';
import 'package:pbl6/core/constants/api_constants.dart';
import 'package:pbl6/features/shared/auth/data/models/api_response_model.dart';
import 'package:pbl6/features/shared/company/domain/entities/company.dart';

/// 🏢 DataSource thao tác với Company API
abstract class CompanyRemoteDataSource {
  /// Lấy danh sách tất cả công ty
  Future<List<Company>> fetchAllCompanies();

  /// Lấy chi tiết một công ty theo ID
  Future<Company> fetchCompanyDetails(String id);
   Future<Company> fetchMyCompany();
    Future<Company> updateCompanyDetails(String id, Company company);
     Future<APIResponse<String>> updateCompanyLogo(String companyId, String filePath);
}

class CompanyRemoteDataSourceImpl implements CompanyRemoteDataSource {

  final Dio _dio;

  CompanyRemoteDataSourceImpl( this._dio) {
    _dio.options.baseUrl = ApiConstants.baseUrl;
  }

  @override
  Future<List<Company>> fetchAllCompanies() async {
    try {
      final response = await _dio.get(ApiConstants.companies);
      final List<dynamic> data = response.data['result'];
      return data.map((json) => Company.fromJson(json)).toList();
    } catch (e) {
      print(" Lỗi fetchAllCompanies: $e");
      rethrow;
    }
  }

  @override
  Future<Company> fetchCompanyDetails(String id) async {
    try {
      final response = await _dio.get("${ApiConstants.companies}/$id");
      return Company.fromJson(response.data['result']);
    } catch (e) {
      print(" Lỗi fetchCompanyDetails: $e");
      rethrow;
    }
  }
  @override
  Future<Company> fetchMyCompany() async {
    try {
      final response = await _dio.get("${ApiConstants.companies}/me");
      return Company.fromJson(response.data['result']);
    } catch (e) {
      print(" Lỗi fetchMyCompany: $e");
      rethrow;
    }
  }

  @override
  Future<Company> updateCompanyDetails(String id, Company company) async {
    try {
      
      final response = await _dio.put(
        "${ApiConstants.companies}/$id",
        data: company.toJsonForUpdate(),
      );
     
      return Company.fromJson(response.data['result']);
    } catch (e) {
      print(" Lỗi updateCompanyDetails: $e");
      rethrow;
    }
  }

  @override
  Future<APIResponse<String>> updateCompanyLogo(
      String companyId, String filePath) async {
    try {
      
      String fileName = filePath.split('/').last;
      FormData formData = FormData.fromMap({
        "file": await MultipartFile.fromFile(filePath, filename: fileName),
      });

      final response = await _dio.put(
        "${ApiConstants.companies}/$companyId/logo",
        data: formData,
      );

      
      return APIResponse.fromJson(response.data, (json) => json.toString());
    } catch (e) {
      print(" Lỗi updateCompanyLogo: $e");
      rethrow;
    }
  }
}

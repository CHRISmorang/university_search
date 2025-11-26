import 'package:dio/dio.dart';
import '../models/university.dart';

class UniversityService {
  final Dio _dio = Dio();

  Future<List<University>> fetchUniversities(String country) async {
    if (country.isEmpty) return [];

    final url = "http://universities.hipolabs.com/search?country=$country";

    try {
      final response = await _dio.get(url);

      // Successful response
      if (response.statusCode == 200) {
        List data = response.data;

        return data.map((e) => University.fromJson(e)).toList();
      } else {
        throw Exception("Server error: ${response.statusCode}");
      }
    } on DioException catch (e) {
      throw Exception("Network Error: ${e.message}");
    } catch (e) {
      throw Exception("Unexpected Error: $e");
    }
  }
}

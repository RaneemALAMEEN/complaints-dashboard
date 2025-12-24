import 'package:dio/dio.dart';
import 'api_constants.dart';

class DioClient {
  final Dio dio = Dio(
    BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      headers: {
        'Content-Type': 'application/json',
        'accept': '*/*',
      },
    ),
  );
}

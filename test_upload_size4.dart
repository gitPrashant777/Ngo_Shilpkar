import 'dart:io';
import 'package:dio/dio.dart';

void main() async {
  final dio = Dio(
    BaseOptions(
      baseUrl: "https://ngo-project-r7cc.onrender.com/api",
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
    ),
  );
  
  final file1 = File('dummy_115kb.pdf');
  await file1.writeAsBytes(List.filled(115 * 1024, 0));

  try {
    print("Uploading 115kb file...");
    var formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(file1.path, filename: 'dummy_115kb.pdf'),
      'module': 'jobs',
    });
    var res = await dio.post("/uploads", data: formData);
    print("115kb success! Data: \${res.data}");
  } catch (e) {
    if (e is DioException) {
      print("115kb error! Status: \${e.response?.statusCode} Body: \${e.response?.data}");
    } else {
      print("115kb error! \$e");
    }
  }
}

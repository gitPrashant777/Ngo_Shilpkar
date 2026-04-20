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
  
  final file2 = File('dummy_500kb.pdf');
  await file2.writeAsBytes(List.filled(500 * 1024, 0));

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
      print("115kb error! Status: \${e.response?.statusCode}, Body: \${e.response?.data}");
    } else {
      print("115kb error! \$e");
    }
  }

  try {
    print("Uploading 500kb file...");
    var formData2 = FormData.fromMap({
      'file': await MultipartFile.fromFile(file2.path, filename: 'dummy_500kb.pdf'),
      'module': 'jobs',
    });
    var res2 = await dio.post("/uploads", data: formData2);
    print("500kb success! Data: \${res2.data}");
  } catch (e) {
      if (e is DioException) {
      print("500kb error! Status: \${e.response?.statusCode}, Body: \${e.response?.data}");
    } else {
      print("500kb error! \$e");
    }
  }
}

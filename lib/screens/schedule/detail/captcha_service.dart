// captcha_service.dart
import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
// import 'package:image/image.dart' as img;

class CaptchaService {
  static final String apiUrl = "http://192.168.2.3:8000/ocr/";

  static Future<String> recognizeCaptcha(Uint8List compressedBytes) async {
    // 1. 图像预处理：压缩图片以提升传输和识别效率
    // final compressedBytes = await _compressImage(imageFile);

    // 2. 创建 multipart 请求
    var request = http.MultipartRequest('POST', Uri.parse(apiUrl));
    request.files.add(
      http.MultipartFile.fromBytes(
        'image',
        compressedBytes,
        filename: 'captcha.png',
      ),
    );

    // 3. 发送请求并等待响应
    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      // 4. 解析服务器返回的 JSON 数据
      final Map<String, dynamic> result = json.decode(response.body);
      if (result['success']) {
        return result['data']; // 识别出的数字字符串
      } else {
        throw Exception('识别失败: ${result['message']}');
      }
    } else {
      throw Exception('HTTP 请求失败，状态码: ${response.statusCode}');
    }
  }

  // Future<Uint8List> _compressImage(File imageFile) async {
  //   // 读取原始图片
  //   final originalBytes = await imageFile.readAsBytes();
  //   final originalImage = img.decodeImage(originalBytes);

  //   if (originalImage == null) {
  //     throw Exception('无法解码图片');
  //   }

  //   // 缩放图片，将宽度限制为 500 像素，高度按比例缩放
  //   final resizedImage = img.copyResize(originalImage, width: 500);

  //   // 可选：添加灰度化等预处理步骤以提升识别准确率
  //   // final grayscaleImage = img.grayscale(resizedImage);

  //   // 以 JPEG 格式编码，质量为 85%，进一步减小体积
  //   final compressedBytes = img.encodeJpg(resizedImage, quality: 85);
  //   return Uint8List.fromList(compressedBytes);
  // }
}

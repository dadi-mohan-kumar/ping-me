import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

class ImageService {

  Future<String> uploadImage(
    File imageFile,
  ) async {

    final request =
        http.MultipartRequest(

      'POST',

      Uri.parse(
        'https://upload.imagekit.io/api/v1/files/upload',
      ),
    );

    request.headers['Authorization'] =
        'Basic cHJpdmF0ZV91am16REs0VE9VUGdZT1lQZFdQeE1scVpoaTA9Og==';

    request.fields['fileName'] =
        imageFile.path.split('/').last;

    request.files.add(

      await http.MultipartFile.fromPath(
        'file',
        imageFile.path,
      ),
    );

    final response =
        await request.send();

    final responseData =
        await response.stream.bytesToString();

    print(responseData);

    final data =
        jsonDecode(responseData);

    if (data['url'] == null) {

      throw Exception(
        data['message'] ??
        'Image upload failed',
      );
    }

    return data['url'];
  }
}
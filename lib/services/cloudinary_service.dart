import 'dart:io';

import 'package:cloudinary_public/cloudinary_public.dart';

class CloudinaryService {
  final CloudinaryPublic _cloudinaryPublic = CloudinaryPublic(
    'dajew8ge2', //Cloud name
    'devtrack', //Upload preset
    cache: false,
  );

  String? _errorMsg;

  Future<String?> uploadGambar(File gambar) async {
    try {
      CloudinaryResponse response = await _cloudinaryPublic.uploadFile(
        CloudinaryFile.fromFile(
          gambar.path,
          resourceType: CloudinaryResourceType.Image,
        ),
      );
      return response.secureUrl;
    } on CloudinaryException catch (e) {
      _errorMsg = e.message;
      return null;
    } catch (e) {
      _errorMsg = e.toString();
      return null;
    }
  }
}

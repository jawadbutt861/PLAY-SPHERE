import 'dart:io';
import 'package:cloudinary_public/cloudinary_public.dart';

class CloudinaryService {
  static const String _cloudName = 'dzv5xsabw';
  static const String _uploadPreset = 'ml_default';

  static final CloudinaryPublic _cloudinary = CloudinaryPublic(
    _cloudName,
    _uploadPreset,
    cache: false,
  );

  /// Upload a single image and return its secure URL
  static Future<String?> uploadImage(File imageFile, {String folder = 'profiles'}) async {
    try {
      final response = await _cloudinary.uploadFile(
        CloudinaryFile.fromFile(
          imageFile.path,
          folder: folder,
          resourceType: CloudinaryResourceType.Image,
        ),
      );
      return response.secureUrl;
    } catch (e) {
      return null;
    }
  }

  /// Upload multiple images and return list of secure URLs
  static Future<List<String>> uploadMultipleImages(
    List<File> imageFiles, {
    String folder = 'venues',
  }) async {
    final List<String> urls = [];
    for (final file in imageFiles) {
      final url = await uploadImage(file, folder: folder);
      if (url != null) urls.add(url);
    }
    return urls;
  }
}

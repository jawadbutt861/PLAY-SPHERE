import 'dart:io';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import '../config/app_config.dart';

class CloudinaryService {
  static final CloudinaryPublic _cloudinary = CloudinaryPublic(
    AppConfig.cloudinaryCloudName,
    AppConfig.cloudinaryUploadPreset,
    cache: false,
  );

  /// Compress image before upload (reduces size by ~70%)
  static Future<File?> _compressImage(File file) async {
    try {
      final dir = await getTemporaryDirectory();
      final targetPath =
          '${dir.path}/compressed_${DateTime.now().millisecondsSinceEpoch}.jpg';

      final result = await FlutterImageCompress.compressAndGetFile(
        file.absolute.path,
        targetPath,
        quality: 75,
        minWidth: 1024,
        minHeight: 1024,
      );

      return result != null ? File(result.path) : null;
    } catch (e) {
      return null;
    }
  }

  /// Upload a single image and return its secure URL
  static Future<String?> uploadImage(File imageFile,
      {String folder = 'profiles'}) async {
    try {
      // Compress first
      final compressed = await _compressImage(imageFile);
      final fileToUpload = compressed ?? imageFile;

      final response = await _cloudinary.uploadFile(
        CloudinaryFile.fromFile(
          fileToUpload.path,
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
    final urls = <String>[];
    for (final file in imageFiles) {
      final url = await uploadImage(file, folder: folder);
      if (url != null) urls.add(url);
    }
    return urls;
  }
}

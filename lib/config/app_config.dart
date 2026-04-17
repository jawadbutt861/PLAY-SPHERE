/// Compile-time configuration loaded via --dart-define.
/// Values can also be passed via --dart-define to override defaults.
///
/// Build command (optional override):
///   flutter run \
///     --dart-define=CLOUDINARY_CLOUD_NAME=dzv5xsabw \
///     --dart-define=CLOUDINARY_UPLOAD_PRESET=ml_default
class AppConfig {
  AppConfig._();

  static const String cloudinaryCloudName = String.fromEnvironment(
    'CLOUDINARY_CLOUD_NAME',
    defaultValue: 'dzv5xsabw',
  );

  static const String cloudinaryUploadPreset = String.fromEnvironment(
    'CLOUDINARY_UPLOAD_PRESET',
    defaultValue: 'ml_default',
  );

  /// Sanity check — call once at startup to catch missing config early.
  static void validate() {
    assert(
      cloudinaryCloudName.isNotEmpty,
      'CLOUDINARY_CLOUD_NAME is not set.',
    );
    assert(
      cloudinaryUploadPreset.isNotEmpty,
      'CLOUDINARY_UPLOAD_PRESET is not set.',
    );
  }
}

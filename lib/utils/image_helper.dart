import 'dart:io';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

class ImageHelper {
  /// Compresses file and returns a new [File] in the temporary directory.
  ///
  /// [quality] defaults to 85 (0-100).
  /// [minWidth] & [minHeight] default to 1080 to ensure good quality on mobile screens.
  static Future<File?> compressAndGetFile(
    File file, {
    int quality = 85,
    int minWidth = 1080,
    int minHeight = 1080,
  }) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final String targetPath = p.join(
        tempDir.path,
        'compressed_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );

      final result = await FlutterImageCompress.compressAndGetFile(
        file.absolute.path,
        targetPath,
        quality: quality,
        minWidth: minWidth,
        minHeight: minHeight,
      );

      if (result != null) {
        return File(result.path);
      }
      return null;
    } catch (e) {
      // Return original file or null if compression fails if preferred,
      // but returning null allows caller to decide (or use original)
      return null;
    }
  }
}

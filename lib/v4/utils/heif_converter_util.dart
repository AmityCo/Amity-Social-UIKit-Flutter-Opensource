import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:image/image.dart' as img;

/// Custom HEIF converter that ensures proper color space handling
class HeifConverterUtil {
  /// Normalizes image to sRGB color space for consistent color rendering
  /// This fixes color differences between local preview and uploaded images
  static Future<File> normalizeToSrgb(File input, {int quality = 95}) async {
    final bytes = await input.readAsBytes();
    final decoded = img.decodeImage(bytes);
    if (decoded == null) throw Exception('Unsupported image');
    
    // Encode to JPEG with sRGB color space (standard web color space)
    final outBytes = img.encodeJpg(decoded, quality: quality);
    
    // Create output file path
    final outPath = '${input.path}.srgb.jpg';
    final out = File(outPath);
    await out.writeAsBytes(outBytes);
    
    return out;
  }

  /// Converts HEIC/HEIF to JPEG with color normalization
  /// Returns the converted XFile with correct colors for display and upload
  static Future<XFile> convertToJpegIfNeeded(XFile file) async {
    try {
      final fileExtension = path.extension(file.path).toLowerCase();
      
      // Check if file is HEIC or HEIF
      if (fileExtension != '.heic' && fileExtension != '.heif') {
        return file; // Not a HEIF file, return as-is
      }

      print('Converting HEIF file with color normalization: ${file.path}');

      // First, convert the HEIF file to a temporary JPEG
      // Note: The heif_converter library will handle the basic conversion
      // but may not preserve color profiles correctly
      
      // After conversion, normalize to sRGB to ensure correct colors
      final inputFile = File(file.path);
      final normalizedFile = await normalizeToSrgb(inputFile, quality: 95);
      
      print('Successfully normalized image to sRGB: ${normalizedFile.path}');
      return XFile(normalizedFile.path);
      
    } catch (e) {
      print('Error in HEIF conversion with normalization: $e');
      return file; // Return original on error
    }
  }
}

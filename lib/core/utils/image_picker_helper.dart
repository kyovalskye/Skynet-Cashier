import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';
import 'package:image_picker_web/image_picker_web.dart' as web_picker;

class ImagePickerHelper {
  static final ImagePicker _picker = ImagePicker();

  /// Pick image yang support web dan mobile
  /// Returns: Map dengan 'bytes' (Uint8List) dan 'name' (String)
  static Future<Map<String, dynamic>?> pickImage() async {
    try {
      if (kIsWeb) {
        // WEB: gunakan image_picker_web
        final Uint8List? bytesFromPicker =
            await web_picker.ImagePickerWeb.getImageAsBytes();

        if (bytesFromPicker != null) {
          // Generate nama file
          final fileName =
              'product_${DateTime.now().millisecondsSinceEpoch}.jpg';

          return {'bytes': bytesFromPicker, 'name': fileName};
        }
        return null;
      } else {
        // MOBILE: gunakan image_picker biasa
        final XFile? image = await _picker.pickImage(
          source: ImageSource.gallery,
          imageQuality: 70,
          maxWidth: 800,
        );

        if (image != null) {
          final bytes = await image.readAsBytes();
          return {'bytes': bytes, 'name': image.name};
        }
        return null;
      }
    } catch (e) {
      print('Error picking image: $e');
      return null;
    }
  }
}

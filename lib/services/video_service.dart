// lib/services/video_service.dart

import 'package:image_picker/image_picker.dart';
import 'dart:io';

class VideoService {
  static final ImagePicker _picker = ImagePicker();

  // Record video using camera
  static Future<File?> recordVideo() async {
    try {
      final XFile? video = await _picker.pickVideo(
        source: ImageSource.camera,
        maxDuration: const Duration(minutes: 5),
        preferredCameraDevice: CameraDevice.rear,
      );

      if (video != null) {
        return File(video.path);
      }
    } catch (e) {
      print('❌ Error recording video: $e');
    }

    return null;
  }
}

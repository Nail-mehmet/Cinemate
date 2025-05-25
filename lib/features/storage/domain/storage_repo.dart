
import 'dart:typed_data';

abstract class StorageRepo {
  // upload pforile image on mobile
  Future<String?> uploadProfileImageMobile(String path, String fileName);

  // upload image on web platofr
  Future<String?> uploadProfileImageWeb(Uint8List fileBytes, String fileName);

    // upload post image on mobile
  Future<String?> uploadPostImageMobile(String path, String fileName);

  // upload post on web platofr
  Future<String?> uploadPostImageWeb(Uint8List fileBytes, String fileName);
}


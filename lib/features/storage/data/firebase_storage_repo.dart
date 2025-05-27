import 'dart:io';
import 'dart:typed_data';
import 'dart:math';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:Cinemate/features/storage/domain/storage_repo.dart';

class SupabaseStorageRepo implements StorageRepo {
  final SupabaseClient supabase = Supabase.instance.client;

  // Benzersiz dosya adı oluşturma
  String _generateUniqueFileName(String originalName) {
    final ext = originalName.split('.').last;
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = Random().nextInt(10000);
    return '${timestamp}_$random.$ext';
  }

  // Dosya türüne göre content type belirleme
  String _getContentType(String fileName) {
    final ext = fileName.split('.').last.toLowerCase();
    switch (ext) {
      case 'jpg':
      case 'jpeg': return 'image/jpeg';
      case 'png': return 'image/png';
      case 'gif': return 'image/gif';
      case 'webp': return 'image/webp';
      default: return 'application/octet-stream';
    }
  }

  // Ortak yükleme metodu
  Future<String?> _upload({
    required dynamic file,
    required String fileName,
    required String bucket,
    bool isWeb = false,
  }) async {
    try {
      final uniqueName = _generateUniqueFileName(fileName);
      final contentType = _getContentType(uniqueName);

      // Web ve mobile için farklı yükleme yöntemleri
      final uploadResponse = isWeb
          ? await supabase.storage
          .from(bucket)
          .uploadBinary(uniqueName, file as Uint8List, fileOptions: FileOptions(
        contentType: contentType,
        cacheControl: '3600',
        upsert: false,
      ))
          : await supabase.storage
          .from(bucket)
          .upload(uniqueName, file as File, fileOptions: FileOptions(
        contentType: contentType,
        cacheControl: '3600',
        upsert: false,
      ));

     /* if (uploadResponse.error != null) {
        throw Exception('Upload failed: ${uploadResponse.error!.message}');
      }*/

      return supabase.storage
          .from(bucket)
          .getPublicUrl(uniqueName);
    } catch (e) {
      print('Error uploading to $bucket: $e');
      rethrow;
    }
  }

  @override
  Future<String?> uploadProfileImageMobile(String filePath, String fileName) async {
    final file = File(filePath);
    return _upload(
      file: file,
      fileName: fileName,
      bucket: 'profileimages',
      isWeb: false,
    );
  }

  @override
  Future<String?> uploadProfileImageWeb(Uint8List fileBytes, String fileName) async {
    return _upload(
      file: fileBytes,
      fileName: fileName,
      bucket: 'profileimages',
      isWeb: true,
    );
  }

  @override
  Future<String?> uploadPostImageMobile(String filePath, String fileName) async {
    final file = File(filePath);
    return _upload(
      file: file,
      fileName: fileName,
      bucket: 'post-images',
      isWeb: false,
    );
  }

  @override
  Future<String?> uploadPostImageWeb(Uint8List fileBytes, String fileName) async {
    return _upload(
      file: fileBytes,
      fileName: fileName,
      bucket: 'post-images',
      isWeb: true,
    );
  }
}
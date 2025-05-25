import 'dart:io';
import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:Cinemate/features/storage/domain/storage_repo.dart';

class SupabaseStorageRepo implements StorageRepo {
  final SupabaseClient supabase = Supabase.instance.client;

  @override
  Future<String?> uploadProfileImageMobile(String filePath, String fileName) async {
    try {
      final file = File(filePath);
      final bytes = await file.readAsBytes();

      final storageResponse = await supabase.storage
          .from('profileimages')   // bucket ismi burada profileimages olarak örnek
          .uploadBinary('public/$fileName', bytes, fileOptions: FileOptions(cacheControl: '3600'));

      if (storageResponse == null) {
        print('Upload failed: null response');
        return null;
      }

      // Yüklenen dosyanın public URL'sini al
      final publicUrl = supabase.storage
          .from('profileimages')
          .getPublicUrl('public/$fileName');

      return publicUrl;
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  @override
  Future<String?> uploadProfileImageWeb(Uint8List fileBytes, String fileName) async {
    return _uploadFileBytes(fileBytes, fileName, 'profileimages');
  }

  @override
  Future<String?> uploadPostImageMobile(String path, String fileName) async {
    return _uploadFile(path, fileName, 'post_images');
  }

  @override
  Future<String?> uploadPostImageWeb(Uint8List fileBytes, String fileName) async {
    return _uploadFileBytes(fileBytes, fileName, 'post_images');
  }

  // Mobile için dosya yolundan yükleme
  Future<String?> _uploadFile(String path, String fileName, String bucket) async {
    try {
      final file = File(path);
      final bytes = await file.readAsBytes();

      final response = await supabase.storage.from(bucket).upload(
        fileName,
        bytes as File,
        fileOptions: FileOptions(cacheControl: '3600', upsert: false),
      );

      // Eğer hata varsa SupabaseException fırlatılır, o yüzden try-catch yeterli
      // Yükleme başarılıysa, public URL'i oluşturuyoruz
      final publicUrl = supabase.storage.from(bucket).getPublicUrl(fileName);
      return publicUrl;
    } catch (e) {
      print('Error uploading file: $e');
      return null;
    }
  }

  // Web için bytes doğrudan yükleme
  Future<String?> _uploadFileBytes(Uint8List fileBytes, String fileName, String bucket) async {
    try {
      final response = await supabase.storage.from(bucket).upload(
        fileName,
        fileBytes as File,
        fileOptions: FileOptions(cacheControl: '3600', upsert: false),
      );

      final publicUrl = supabase.storage.from(bucket).getPublicUrl(fileName);
      return publicUrl;
    } catch (e) {
      print('Error uploading bytes: $e');
      return null;
    }
  }
}

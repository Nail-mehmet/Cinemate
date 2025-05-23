/*import 'dart:io';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:home_widget/home_widget.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class WidgetHelper {
  static const String keyTitle = 'widget_title';
  static const String keyDescription = 'widget_description';
  static const String keyImagePath = 'widget_image_path';

  static Future<void> updateWidgetFromFirebase() async {
    try {
      final docSnapshot = await FirebaseFirestore.instance
          .collection('widgets')
          .doc('main')
          .get();

      if (!docSnapshot.exists) {
        print('Doküman bulunamadı');
        return;
      }

      final data = docSnapshot.data()!;
      final title = data['title'] ?? 'Başlık';
      final description = data['description'] ?? 'Açıklama';
      final imageUrl = data['image'] ?? '';

      String? localImagePath;

      if (imageUrl.isNotEmpty) {
        final imageBytes = await _downloadImage(imageUrl);
        if (imageBytes != null) {
          localImagePath = await _saveImageToFile(imageBytes);
          if (localImagePath != null) {
            await HomeWidget.saveWidgetData(keyImagePath, localImagePath);
          }
        }
      }

      await HomeWidget.saveWidgetData(keyTitle, title);
      await HomeWidget.saveWidgetData(keyDescription, description);

      await HomeWidget.updateWidget(
        androidName: 'com.example.nail.CinemateWidget',
        iOSName: 'CinemateWidget',
      );
    } catch (e) {
      print('Widget güncelleme hatası: $e');
    }
  }

  static Future<Uint8List?> _downloadImage(String url) async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        return response.bodyBytes;
      }
    } catch (e) {
      print('Resim indirme hatası: $e');
    }
    return null;
  }

  static Future<String?> _saveImageToFile(Uint8List bytes) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/widget_image.jpg';
      final file = File(filePath);
      await file.writeAsBytes(bytes);
      return file.path;
    } catch (e) {
      print('Dosya kaydetme hatası: $e');
    }
    return null;
  }
}
*/
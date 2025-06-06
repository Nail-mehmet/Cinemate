import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:Cinemate/features/post/presentation/pages/second_step_to_post.dart';
import 'package:Cinemate/themes/font_theme.dart';

class PhotoSelectionPage extends StatefulWidget {
  const PhotoSelectionPage({super.key});

  @override
  State<PhotoSelectionPage> createState() => _PhotoSelectionPageState();
}

class _PhotoSelectionPageState extends State<PhotoSelectionPage> {
  XFile? selectedImage;
  Uint8List? webImage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Fotoğraf Seç',
          style: AppTextStyles.semiBold,
        ),
        actions: [
          if (selectedImage != null)
            IconButton(
              icon: const Icon(Icons.arrow_forward),
              onPressed: () {
                if (kIsWeb) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PostDetailsPage(
                        webImage: webImage,
                      ),
                    ),
                  );
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PostDetailsPage(
                        imagePath: selectedImage!.path,
                      ),
                    ),
                  );
                }
              },
            ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (selectedImage != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: InteractiveViewer(
                      child: kIsWeb
                          ? Image.memory(webImage!)
                          : Image.file(File(selectedImage!.path)),
                    ),
                  ),
                )
              else
                Text(
                  'Fotoğraf seçilmedi',
                  style: AppTextStyles.medium.copyWith(fontSize: 14),
                ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 50.0),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 48),
                    backgroundColor: Theme.of(context).colorScheme.primary,
                  ),
                  onPressed: () => _showImagePickerBottomSheet(context),
                  child: Text(
                    'Fotoğraf Seç',
                    style: AppTextStyles.bold.copyWith(
                      color: Theme.of(context).colorScheme.tertiary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showImagePickerBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.photo_library),
            title: Text(
              'Galeriden Seç',
              style: AppTextStyles.medium.copyWith(
                  color: Theme.of(context).colorScheme.primary),
            ),
            onTap: () {
              Navigator.pop(context);
              _pickImage(ImageSource.gallery);
            },
          ),
          if (!kIsWeb)
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: Text('Kamera ile Çek',
                  style: AppTextStyles.medium.copyWith(
                      color: Theme.of(context).colorScheme.primary)),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
        ],
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: source);

      if (image != null) {
        setState(() {
          selectedImage = image;
          if (kIsWeb) {
            image.readAsBytes().then((bytes) {
              setState(() {
                webImage = bytes;
              });
            });
          }
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Fotoğraf seçerken hata oluştu: $e')),
      );
    }
  }
}

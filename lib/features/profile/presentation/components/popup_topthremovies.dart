import 'dart:ui' as ui;
import 'dart:typed_data';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:Cinemate/themes/font_theme.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class FavoriteMoviesPopup extends StatefulWidget {
  final List<int?> topThreeMovies;
  final Widget Function(int movieId, {double aspectRatio}) buildMovieItem;

  const FavoriteMoviesPopup({
    Key? key,
    required this.topThreeMovies,
    required this.buildMovieItem,
  }) : super(key: key);

  @override
  _FavoriteMoviesPopupState createState() => _FavoriteMoviesPopupState();
}

class _FavoriteMoviesPopupState extends State<FavoriteMoviesPopup> {
  final GlobalKey _globalKey = GlobalKey();
  bool _isSaving = false;

  Future<void> _saveImage() async {
    setState(() {
      _isSaving = true;
    });

    try {
      var status = await Permission.storage.request();
      if (!status.isGranted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Depolama izni gerekli")),
        );
        return;
      }

      RenderRepaintBoundary boundary =
          _globalKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      Uint8List pngBytes = byteData!.buffer.asUint8List();

      final directory = Directory('/storage/emulated/0/Pictures');
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }

      final String fileName = 'favorite_movies_${DateTime.now().millisecondsSinceEpoch}.png';
      final String filePath = '${directory.path}/$fileName';
      File file = File(filePath);
      await file.writeAsBytes(pngBytes);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Galeriye kaydedildi:\n$filePath")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Hata oluştu: $e")),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final movies = widget.topThreeMovies;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // The main popup content
          RepaintBoundary(
            key: _globalKey,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF0A1A3A),
                    Color(0xFF1A3A6E),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 20,
                    spreadRadius: 2,
                  )
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset("assets/images/cinemate.png", fit: BoxFit.cover),
                  const SizedBox(height: 25),
                  Text(
                    "En İyi Üçlemem",
                    style: AppTextStyles.bold.copyWith(fontSize: 30, color: Colors.white),
                  ),
                  const SizedBox(height: 16),
                  if (movies.isNotEmpty && movies[0] != null)
                    Container(
                      height: 200,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.4),
                            blurRadius: 10,
                            spreadRadius: 2,
                          )
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: widget.buildMovieItem(movies[0]!, aspectRatio: 2 / 3),
                      ),
                    ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (movies.length > 1 && movies[1] != null)
                        Container(
                          width: 130,
                          height: 180,
                          margin: const EdgeInsets.symmetric(horizontal: 8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 8,
                                spreadRadius: 1,
                              )
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: widget.buildMovieItem(movies[1]!, aspectRatio: 2 / 3),
                          ),
                        ),
                      if (movies.length > 2 && movies[2] != null)
                        Container(
                          width: 130,
                          height: 180,
                          margin: const EdgeInsets.symmetric(horizontal: 8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 8,
                                spreadRadius: 1,
                              )
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: widget.buildMovieItem(movies[2]!, aspectRatio: 2 / 3),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          // Save button positioned below the popup
          if (!_isSaving) ...[
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _saveImage,
              icon: const Icon(Icons.save_alt, size: 20),
              label: const Text("Kaydet"),
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                backgroundColor: Color(0xFF2A5CB5),
                foregroundColor: Colors.white,
                textStyle: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
                elevation: 3,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:Cinemate/themes/font_theme.dart';

class SwapPosterDialog extends StatefulWidget {
  final Map<String, dynamic> newMovie;
  final List<Map<String, dynamic>> currentMovies;
  final Function(int) onConfirm;
  final VoidCallback onCancel;

  const SwapPosterDialog({
    Key? key,
    required this.newMovie,
    required this.currentMovies,
    required this.onConfirm,
    required this.onCancel,
  }) : super(key: key);

  @override
  State<SwapPosterDialog> createState() => _SwapPosterDialogState();
}

class _SwapPosterDialogState extends State<SwapPosterDialog> {
  int? selectedMovieId;

  String getPosterUrl(String path) {
    return 'https://image.tmdb.org/t/p/w500$path';
  }

  @override
  Widget build(BuildContext context) {
    final newPosterUrl = getPosterUrl(widget.newMovie['poster_path']);

    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.7),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: selectedMovieId == null
                  ? Image.network(newPosterUrl,
                      key: const ValueKey('new'), height: 200)
                  : Image.network(
                      getPosterUrl(
                        widget.currentMovies.firstWhere((movie) =>
                            movie['id'] == selectedMovieId)['poster_path'],
                      ),
                      key: ValueKey(selectedMovieId),
                      height: 200,
                    ),
            ),
            SizedBox(height: 25,),
            Text(
              "En iyi Üçlemen",
              style: AppTextStyles.regular.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: widget.currentMovies.map((movie) {
                final isSelected = selectedMovieId == movie['id'];
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedMovieId = movie['id'];
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: isSelected
                          ? [
                              const BoxShadow(
                                  color: Colors.amber, blurRadius: 12)
                            ]
                          : [],
                    ),
                    child: Image.network(
                      selectedMovieId == movie['id']
                          ? newPosterUrl
                          : getPosterUrl(movie['poster_path']),
                      height: 150,
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: selectedMovieId != null
                  ? () {
                      widget.onConfirm(selectedMovieId!);
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
                textStyle: AppTextStyles.regular.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              child: const Text("Güncelle"),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: widget.onCancel,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey.shade300,
                foregroundColor: Colors.black87,
                padding:
                    const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              child: const Text("İptal"),
            ),
          ],
        ),
      ),
    );
  }
}

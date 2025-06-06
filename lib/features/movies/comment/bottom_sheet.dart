import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter/services.dart';
import 'package:Cinemate/themes/font_theme.dart';
import 'comment_service.dart';

class CommentBottomSheet extends StatefulWidget {
  final int movieId;
  final String movieTitle;
  final String posterPath;

  const CommentBottomSheet({
    Key? key,
    required this.movieId,
    required this.movieTitle,
    required this.posterPath,
  }) : super(key: key);

  @override
  State<CommentBottomSheet> createState() => _CommentBottomSheetState();
}
class _CommentBottomSheetState extends State<CommentBottomSheet> {
  double _rating = 3;
  final _controller = TextEditingController();
  bool _isSubmitting = false;
  bool _containsSpoiler = false;


  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Poster ve Başlık
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  'https://image.tmdb.org/t/p/w185${widget.posterPath}',
                  height: 100,
                  width: 70,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Image.asset(
                    'assets/fallback_image.jpg',
                    height: 100,
                    width: 70,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  widget.movieTitle,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Rating ve Spoiler ikonu
          LayoutBuilder(
            builder: (context, constraints) {
              // Ekran genişliği
              final width = constraints.maxWidth;

              // Responsive boyutlar (örnek)
              final starSize = width * 0.06; // ekran genişliğinin %6'sı, max 32 olacak şekilde sınırla
              final horizontalPadding = width * 0.007; // küçük padding
              final spacing = width * 0.02; // aradaki boşluk
              final fontSize = width * 0.035; // font büyüklüğü

              return Row(
                children: [
                  Expanded(
                    child: RatingBar.builder(
                      initialRating: _rating,
                      minRating: 1,
                      direction: Axis.horizontal,
                      allowHalfRating: true,
                      itemCount: 5,
                      itemPadding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                      itemBuilder: (context, _) => Icon(
                        Icons.star_rounded,
                        color: Colors.amber,
                        size: starSize.clamp(16, 32), // minimum 16, maksimum 32
                      ),
                      onRatingUpdate: (rating) {
                        HapticFeedback.lightImpact();
                        setState(() => _rating = rating);
                      },
                    ),
                  ),
                  SizedBox(width: spacing.clamp(8, 20)),
                  GestureDetector(
                    onTap: () {
                      setState(() => _containsSpoiler = !_containsSpoiler);
                    },
                    child: Column(
                      children: [
                        Icon(
                          _containsSpoiler ? Icons.visibility_off : Icons.visibility,
                          color: _containsSpoiler ? Colors.red : Theme.of(context).colorScheme.primary,
                          size: starSize.clamp(16, 32),
                        ),
                        Text(
                          _containsSpoiler ? 'Spoiler içerir' : 'Spoiler içermez',
                          style: AppTextStyles.medium.copyWith(
                            fontSize: fontSize.clamp(10, 16),
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),


          const SizedBox(height: 24),

          // Yorum kutusu
          TextField(
            controller: _controller,
            maxLines: 5,
            decoration: InputDecoration(
              hintText: 'Yorumunuzu buraya yazın...',
              hintStyle: AppTextStyles.medium
                  .copyWith(color: Theme.of(context).colorScheme.primary),
              filled: true,
              fillColor: Theme.of(context).colorScheme.tertiary,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Gönder butonu
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isSubmitting
                  ? null
                  : () async {
                      setState(() => _isSubmitting = true);
                      await CommentService().addComment(
                        movieId: widget.movieId.toString(),
                        commentText: _controller.text,
                        rating: _rating,
                        movieTitle: widget.movieTitle,
                        spoiler: _containsSpoiler,
                      );
                      Navigator.pop(context);
                    },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Theme.of(context).colorScheme.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: _isSubmitting
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text(
                      'Gönder',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'dart:math';
import 'package:flutter/material.dart';

import '../../../../themes/font_theme.dart';

class FlamingButton extends StatefulWidget {
  final VoidCallback onPressed;
  final String text;

  const FlamingButton({super.key, required this.onPressed, required this.text});

  @override
  State<FlamingButton> createState() => _FlamingButtonState();
}

class _FlamingButtonState extends State<FlamingButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final double buttonWidth = 120; // Genişliği küçülttük
  final double buttonHeight = 30; // Yüksekliği küçülttük

  @override
  void initState() {
    super.initState();
    
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 2))
          ..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final tertiary = Theme.of(context).colorScheme.tertiary;

    return Stack(
      alignment: Alignment.center,
      children: [
        // Alevli çerçeve (daha ince)
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return CustomPaint(
              painter: FlamingBorderPainter(
                animationValue: _controller.value,
                color: primary,
                width: buttonWidth,
                height: buttonHeight,
              ),
              child: SizedBox(width: buttonWidth, height: buttonHeight),
            );
          },
        ),

        // Buton (daha ince)
        ElevatedButton(
          onPressed: widget.onPressed,
          style: ElevatedButton.styleFrom(
            fixedSize: Size(buttonWidth, buttonHeight),
            backgroundColor: primary,
            padding: const EdgeInsets.symmetric(horizontal: 8), // Padding'i azalttık
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10), // Köşe yuvarlaklığını azalttık
            ),
          ),
          child: Text(
            widget.text,
            style: AppTextStyles.bold.copyWith(color: Theme.of(context).colorScheme.tertiary)
          ),
        ),
      ],
    );
  }
}

class FlamingBorderPainter extends CustomPainter {
  final double animationValue;
  final Color color;
  final double width;
  final double height;

  FlamingBorderPainter({
    required this.animationValue,
    required this.color,
    required this.width,
    required this.height,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..shader = SweepGradient(
        colors: [
          color.withOpacity(0.0),
          Colors.blue,
          Colors.cyan,
          Colors.red,
          color.withOpacity(0.0),
        ],
        stops: [0.0, 0.3, 0.5, 0.7, 1.0],
        transform: GradientRotation(2 * pi * animationValue),
      ).createShader(Rect.fromLTWH(0, 0, width, height))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5; // Çizgi kalınlığını azalttık

    final RRect rRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, width, height),
      const Radius.circular(12), // Köşe yuvarlaklığını butonla uyumlu hale getirdik
    );
    canvas.drawRRect(rRect, paint);
  }

  @override
  bool shouldRepaint(covariant FlamingBorderPainter oldDelegate) =>
      oldDelegate.animationValue != animationValue ||
      oldDelegate.color != color ||
      oldDelegate.width != width ||
      oldDelegate.height != height;
}
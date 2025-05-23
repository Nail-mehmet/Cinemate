import 'package:flutter/material.dart';

class ExpandableText extends StatefulWidget {
  final String text;
  final TextStyle? style;

  const ExpandableText({
    Key? key,
    required this.text,
    this.style,
  }) : super(key: key);

  @override
  State<ExpandableText> createState() => _ExpandableTextState();
}

class _ExpandableTextState extends State<ExpandableText>
    with TickerProviderStateMixin {
  bool _isExpanded = false;

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    final defaultStyle = widget.style ??
        TextStyle(
          fontWeight: FontWeight.w500,
          color: Theme.of(context).colorScheme.primary,
          height: 1.5,
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: _toggleExpanded,
          child: AnimatedSize(
            duration: const Duration(milliseconds: 1000),
            curve: Curves.easeInOut,
            child: ConstrainedBox(
              constraints: _isExpanded
                  ? const BoxConstraints()
                  : const BoxConstraints(maxHeight: 75), // yaklaşık 3 satır
              child: Text(
                widget.text,
                style: defaultStyle,
                softWrap: true,
                overflow: TextOverflow.fade,
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        GestureDetector(
          onTap: _toggleExpanded,
          child: Text(
            _isExpanded ? 'Daha az' : 'Daha fazla',
            style: const TextStyle(
              color: Colors.blueAccent,
              fontWeight: FontWeight.bold,
            ),
          ),
        )
      ],
    );
  }
}

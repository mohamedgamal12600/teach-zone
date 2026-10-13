// color_dot.dart
import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';

class ColorDot extends StatelessWidget {
  const ColorDot({
    super.key,
    required this.color,
    this.size = 20,
    this.selected = false,
  });

  final Color color;
  final double size;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(size * 0.3),
        border: Border.all(
          color: selected ? Colors.white : AppColors.outline,
          width: selected ? 2 : 1,
        ),
      ),
    );
  }
}

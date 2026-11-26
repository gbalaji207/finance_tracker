import 'dart:math' as math;

import 'package:flutter/material.dart';

class ResponsiveWrap extends StatelessWidget {
  const ResponsiveWrap({
    super.key,
    required this.children,
    required this.minItemWidth,
    this.spacing = 16,
    this.maxColumns,
  });

  final List<Widget> children;
  final double minItemWidth;
  final double spacing;
  final int? maxColumns;

  @override
  Widget build(BuildContext context) {
    if (children.isEmpty) return const SizedBox.shrink();
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final columns = ((w + spacing) / (minItemWidth + spacing))
            .floor()
            .clamp(1, math.min(children.length, maxColumns ?? children.length));
        final itemWidth = (w - spacing * (columns - 1)) / columns;
        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            for (final child in children)
              SizedBox(width: itemWidth, child: child),
          ],
        );
      },
    );
  }
}

import 'package:flutter/material.dart';

class TwoPane extends StatelessWidget {
  const TwoPane({
    super.key,
    required this.primary,
    required this.secondary,
    this.primaryMin = 520,
    this.secondaryMin = 280,
    this.primaryFlex = 2,
    this.secondaryFlex = 1,
    this.secondaryWidth,
    this.gap = 16,
  });

  final Widget primary;
  final Widget secondary;
  final double primaryMin;
  final double secondaryMin;
  final int primaryFlex;
  final int secondaryFlex;
  final double? secondaryWidth;
  final double gap;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final fixed = secondaryWidth;
        if (fixed != null) {
          if (w >= primaryMin + gap + fixed) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: primary),
                SizedBox(width: gap),
                SizedBox(width: fixed, child: secondary),
              ],
            );
          }
        } else if (w >= primaryMin + gap + secondaryMin) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: primaryFlex, child: primary),
              SizedBox(width: gap),
              Expanded(flex: secondaryFlex, child: secondary),
            ],
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: gap,
          children: [primary, secondary],
        );
      },
    );
  }
}

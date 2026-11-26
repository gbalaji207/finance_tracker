import 'package:finance_tracker/core/theme/app_spacing.dart';
import 'package:flutter/material.dart';

/// Scrolling, padded body for a page inside [AppShell].
///
/// The scroll view lives inside each routed page (below the shell's nested
/// Navigator), so the Navigator's Overlay gets bounded constraints. Putting
/// the scroll view above the Navigator breaks tooltips and freezes the UI.
class PageBody extends StatelessWidget {
  const PageBody({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.pageV,
        horizontal: AppSpacing.pageH,
      ),
      child: SizedBox(width: double.infinity, child: child),
    );
  }
}

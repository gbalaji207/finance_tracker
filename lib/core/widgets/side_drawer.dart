import 'dart:math' as math;

import 'package:finance_tracker/core/theme/app_colors.dart';
import 'package:finance_tracker/core/theme/app_spacing.dart';
import 'package:flutter/material.dart';

/// Opens [builder]'s widget (normally a [SideDrawer]) in a panel that slides in
/// from the right, over a dimmed barrier. Esc and a click on the barrier close
/// it. The future completes when the drawer closes, however it closed.
///
/// The drawer is its own route, so anything it needs from the page's
/// `BlocProvider`s must be passed on inside [builder].
Future<T?> showSideDrawer<T>(
  BuildContext context, {
  required WidgetBuilder builder,
}) {
  return showGeneralDialog<T>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Close',
    barrierColor: AppColors.scrim.withValues(alpha: 0.35),
    transitionDuration: const Duration(milliseconds: 220),
    pageBuilder: (context, _, _) =>
        Align(alignment: Alignment.centerRight, child: builder(context)),
    transitionBuilder: (context, animation, _, child) => SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(1, 0),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
      child: child,
    ),
  );
}

/// The panel itself: full height, scrolls its [child], with a close button in
/// the top right corner. A title inside [child] should keep [titleGap] free on
/// the right so it does not run under that button.
class SideDrawer extends StatelessWidget {
  const SideDrawer({super.key, required this.child});

  static const double maxWidth = 480;

  /// Right padding for a title, so it clears the close button.
  static const titleGap = EdgeInsets.only(right: 40);

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final width = math.min(maxWidth, MediaQuery.sizeOf(context).width);
    return Material(
      color: AppColors.surface,
      elevation: 8,
      child: Container(
        width: width,
        height: double.infinity,
        decoration: const BoxDecoration(
          border: Border(left: BorderSide(color: AppColors.cardBorder)),
        ),
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.s24),
              child: child,
            ),
            Positioned(
              top: AppSpacing.s12,
              right: AppSpacing.s12,
              child: IconButton(
                tooltip: 'Close',
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

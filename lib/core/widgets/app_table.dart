import 'dart:math' as math;
import 'dart:ui' show PointerDeviceKind;

import 'package:finance_tracker/core/theme/app_colors.dart';
import 'package:finance_tracker/core/theme/app_spacing.dart';
import 'package:finance_tracker/core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';

class AppTableColumn {
  const AppTableColumn(
    this.title, {
    this.flex = 1,
    this.width,
    this.align = TextAlign.left,
  });

  final String title;
  final double flex;
  final double? width;
  final TextAlign align;
}

class AppTableRow {
  const AppTableRow(this.cells, {this.highlight = false, this.background});

  final List<Widget> cells;
  final bool highlight;

  /// Paints the whole row with this color. [highlight] wins when both are set.
  final Color? background;
}

class AppTableText extends StatelessWidget {
  const AppTableText(
    this.text, {
    super.key,
    this.bold = false,
    this.color,
    this.secondary = false,
    this.maxLines,
  });

  final String text;
  final bool bold;
  final Color? color;
  final bool secondary;

  /// Limits the text to this many lines and ends it with an ellipsis. Null
  /// (the default) lets the text wrap.
  final int? maxLines;

  @override
  Widget build(BuildContext context) {
    var style = secondary ? AppTextStyles.bodySecondary : AppTextStyles.body;
    if (bold) style = style.copyWith(fontWeight: FontWeight.w600);
    if (color != null) style = style.copyWith(color: color);
    final limit = maxLines;
    if (limit == null) return Text(text, style: style, softWrap: true);
    return Tooltip(
      message: text,
      waitDuration: const Duration(milliseconds: 500),
      child: Text(
        text,
        style: style,
        maxLines: limit,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

class AppTable extends StatelessWidget {
  const AppTable({
    super.key,
    required this.columns,
    required this.rows,
    this.minWidth,
  });

  final List<AppTableColumn> columns;
  final List<AppTableRow> rows;
  final double? minWidth;

  static const _border = BorderSide(color: AppColors.divider);

  @override
  Widget build(BuildContext context) {
    final table = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [_headerRow(), for (final row in rows) _bodyRow(row)],
    );

    final min = minWidth;
    if (min == null) return table;
    return LayoutBuilder(
      builder: (context, constraints) => _HorizontalScroll(
        child: SizedBox(
          width: math.max(min, constraints.maxWidth),
          child: table,
        ),
      ),
    );
  }

  Widget _headerRow() => Container(
    padding: const EdgeInsets.only(
      top: AppSpacing.s4,
      bottom: AppSpacing.s12,
      left: AppSpacing.s4,
      right: AppSpacing.s4,
    ),
    decoration: const BoxDecoration(border: Border(bottom: _border)),
    child: _cellRow([
      for (final c in columns)
        Text(c.title, style: AppTextStyles.label, textAlign: c.align),
    ]),
  );

  Widget _bodyRow(AppTableRow row) => Container(
    constraints: const BoxConstraints(minHeight: AppSpacing.controlHeight),
    padding: const EdgeInsets.symmetric(
      vertical: AppSpacing.s12,
      horizontal: AppSpacing.s4,
    ),
    decoration: row.highlight
        ? BoxDecoration(
            color: AppColors.pageBg,
            borderRadius: BorderRadius.circular(AppSpacing.radiusControl),
          )
        : BoxDecoration(
            color: row.background,
            border: const Border(bottom: _border),
          ),
    child: _cellRow(row.cells),
  );

  Widget _cellRow(List<Widget> cells) => Row(
    spacing: AppSpacing.s12,
    children: [
      for (var i = 0; i < columns.length; i++) _cell(columns[i], cells[i]),
    ],
  );

  Widget _cell(AppTableColumn column, Widget child) {
    final aligned = Align(
      alignment: column.align == TextAlign.right
          ? Alignment.centerRight
          : Alignment.centerLeft,
      child: child,
    );
    if (column.width != null) {
      return SizedBox(width: column.width, child: aligned);
    }
    return Expanded(
      flex: math.max(1, (column.flex * 10).round()),
      child: aligned,
    );
  }
}

/// Horizontal scroller for wide tables.
///
/// Flutter web does not scroll with a mouse drag by default and shows no
/// scrollbar, so a wide table looked stuck on desktop browsers. This enables
/// mouse (and trackpad) dragging and shows a visible scrollbar whenever the
/// content is wider than the viewport.
class _HorizontalScroll extends StatefulWidget {
  const _HorizontalScroll({required this.child});

  final Widget child;

  @override
  State<_HorizontalScroll> createState() => _HorizontalScrollState();
}

class _HorizontalScrollState extends State<_HorizontalScroll> {
  final _controller = ScrollController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(
        dragDevices: {
          PointerDeviceKind.touch,
          PointerDeviceKind.mouse,
          PointerDeviceKind.trackpad,
          PointerDeviceKind.stylus,
        },
        scrollbars: false,
      ),
      child: Scrollbar(
        controller: _controller,
        thumbVisibility: true,
        child: SingleChildScrollView(
          controller: _controller,
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.only(bottom: AppSpacing.s12),
          child: widget.child,
        ),
      ),
    );
  }
}

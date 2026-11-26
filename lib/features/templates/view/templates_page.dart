import 'package:finance_tracker/core/theme/app_spacing.dart';
import 'package:finance_tracker/core/widgets/page_header.dart';
import 'package:finance_tracker/core/widgets/section_placeholder.dart';
import 'package:flutter/material.dart';

class TemplatesPage extends StatelessWidget {
  const TemplatesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: AppSpacing.s24,
      children: [
        PageHeader(
          title: 'Templates and copy last month',
          subtitle: 'Sample data',
        ),
        SectionPlaceholder(name: 'Page content'),
      ],
    );
  }
}

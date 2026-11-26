import 'package:finance_tracker/core/theme/app_theme.dart';
import 'package:finance_tracker/dev/design_system_preview.dart';
import 'package:flutter/material.dart';

void main() => runApp(MaterialApp(
      theme: AppTheme.light(),
      home: const DesignSystemPreview(),
      debugShowCheckedModeBanner: false,
      title: 'Money Tracker',
    ));

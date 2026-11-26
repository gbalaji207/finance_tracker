import 'package:finance_tracker/core/theme/app_theme.dart';
import 'package:finance_tracker/dev/shell_demo.dart';
import 'package:flutter/material.dart';

void main() => runApp(MaterialApp(
      theme: AppTheme.light(),
      home: const ShellDemo(),
      debugShowCheckedModeBanner: false,
      title: 'Money Tracker',
    ));

import 'package:finance_tracker/core/theme/app_theme.dart';
import 'package:finance_tracker/dev/component_gallery.dart';
import 'package:flutter/material.dart';

void main() => runApp(MaterialApp(
      theme: AppTheme.light(),
      home: const ComponentGallery(),
      debugShowCheckedModeBanner: false,
      title: 'Money Tracker',
    ));

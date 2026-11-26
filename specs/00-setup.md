# 00: Project setup

**Goal:** a new Flutter web project with the packages and folder structure every later spec expects. The app shows only the text "Money Tracker".

**Prerequisites:** Flutter 3.27+ (`flutter --version`) and Chrome installed.

## Steps

1. Create the project where you want it to live:
   ```bash
   flutter create --platforms web --org com.example finance_tracker
   cd finance_tracker
   ```
2. Add packages (let `flutter pub add` choose versions):
   ```bash
   flutter pub add flutter_bloc equatable go_router google_fonts intl
   flutter pub add flutter_web_plugins --sdk=flutter
   ```
3. Delete the counter demo: remove `test/widget_test.dart` (it tests the counter app).
4. Create this folder structure under `lib/` and `specs/`. Put an empty `.gitkeep` in every folder that has no file yet.
   ```
   lib/
     main.dart
     app/
     core/
       theme/
       utils/
       models/
       data/
       widgets/
     dev/                      temporary preview pages (design system, gallery)
     features/
       dashboard/    cubit/ view/ widgets/
       transactions/ cubit/ view/ widgets/
       monthly_report/ cubit/ view/ widgets/
       source_report/  cubit/ view/ widgets/
       templates/    cubit/ view/ widgets/
       settings/     view/
   test/
     core/
   specs/                      the spec files (copy them here)
   ```
5. Replace `lib/main.dart` with:
   ```dart
   import 'package:flutter/material.dart';

   void main() => runApp(const MaterialApp(
         debugShowCheckedModeBanner: false,
         title: 'Money Tracker',
         home: Scaffold(body: Center(child: Text('Money Tracker'))),
       ));
   ```
6. Set the browser tab title: in `web/index.html` change `<title>` to `Money Tracker`; in `web/manifest.json` set `name` and `short_name` to `Money Tracker`.
7. Keep the default `analysis_options.yaml` (it includes `flutter_lints`).
8. `git init`, add everything, commit with message `spec 00: setup`.

## Do not

- Add packages beyond the list above, or create any widgets yet.
- Rename the project: later specs import `package:finance_tracker/...`.

## Verify

- [ ] `flutter analyze` reports no issues.
- [ ] `flutter run -d chrome --web-port=5000` opens a page showing "Money Tracker" and the tab title is "Money Tracker".
- [ ] The folder tree above exists and `specs/` contains these files.
- [ ] `pubspec.yaml` lists exactly: flutter_bloc, equatable, go_router, google_fonts, intl, flutter_web_plugins (sdk: flutter).

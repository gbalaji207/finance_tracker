import 'package:finance_tracker/app/app.dart';
import 'package:finance_tracker/core/config/app_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  usePathUrlStrategy();
  if (AppConfig.useSupabase) {
    if (!AppConfig.isConfigured) {
      runApp(const _MissingConfigApp());
      return;
    }
    await Supabase.initialize(
      url: AppConfig.supabaseUrl,
      publishableKey: AppConfig.supabaseAnonKey,
    );
  }
  runApp(const App());
}

class _MissingConfigApp extends StatelessWidget {
  const _MissingConfigApp();

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              'Supabase is switched on but SUPABASE_URL or SUPABASE_ANON_KEY '
              'is missing. Run with --dart-define-from-file=env/dev.json.',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}

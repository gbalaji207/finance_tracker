import 'package:finance_tracker/core/config/app_config.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Debug-only page that shows the connection state.
class SupabaseCheckPage extends StatelessWidget {
  const SupabaseCheckPage({super.key});

  @override
  Widget build(BuildContext context) {
    final lines = <String>[
      AppConfig.useSupabase ? 'Mode: Supabase' : 'Mode: Sample data',
    ];
    if (AppConfig.useSupabase) {
      final email = Supabase.instance.client.auth.currentSession?.user.email;
      lines
        ..add('URL host: ${Uri.parse(AppConfig.supabaseUrl).host}')
        ..add('Session: ${email ?? 'none'}');
    }
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 8,
          children: [for (final l in lines) SelectableText(l)],
        ),
      ),
    );
  }
}

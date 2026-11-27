import 'package:finance_tracker/core/config/app_config.dart';

/// When true, the router sends signed-out users to `/login`.
/// Follows the mode: on with Supabase, off with sample data.
const bool kRequireLogin = AppConfig.useSupabase;

/// The account shown as signed in while login is not required.
const String kMockAccountEmail = 'your-email@example.com';

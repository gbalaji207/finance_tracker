import 'package:finance_tracker/app/router.dart';
import 'package:finance_tracker/core/data/finance_repository.dart';
import 'package:finance_tracker/core/data/mock_finance_repository.dart';
import 'package:finance_tracker/core/theme/app_theme.dart';
import 'package:finance_tracker/features/auth/cubit/auth_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  // The router needs the AuthCubit for its redirects, so both are created
  // once here and the cubit is provided to the tree below.
  late final AuthCubit _auth;
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _auth = AuthCubit();
    _router = createRouter(_auth);
  }

  @override
  void dispose() {
    _router.dispose();
    _auth.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AuthCubit>.value(
      value: _auth,
      child: RepositoryProvider<FinanceRepository>(
        create: (_) => const MockFinanceRepository(),
        child: MaterialApp.router(
          title: 'Money Tracker',
          theme: AppTheme.light(),
          routerConfig: _router,
          debugShowCheckedModeBanner: false,
        ),
      ),
    );
  }
}

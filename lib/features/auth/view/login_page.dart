import 'package:finance_tracker/app/routes.dart';
import 'package:finance_tracker/core/theme/app_colors.dart';
import 'package:finance_tracker/core/theme/app_spacing.dart';
import 'package:finance_tracker/core/theme/app_text_styles.dart';
import 'package:finance_tracker/core/widgets/app_button.dart';
import 'package:finance_tracker/core/widgets/app_card.dart';
import 'package:finance_tracker/core/widgets/app_text_field.dart';
import 'package:finance_tracker/core/widgets/app_text_link.dart';
import 'package:finance_tracker/features/auth/cubit/auth_cubit.dart';
import 'package:finance_tracker/features/auth/cubit/auth_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _email = TextEditingController();
  final _password = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _submit() {
    final auth = context.read<AuthCubit>();
    auth.signIn(_email.text, _password.text);
    // Covers the case where the user was already signed in (login not
    // required): signing in again emits an identical state, so the listener
    // below would not fire.
    final state = auth.state;
    if (state.status == AuthStatus.signedIn && state.errorMessage == null) {
      context.go(AppRoutes.dashboard);
    }
  }

  void _notWired() {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(content: Text('Not wired yet (sample data)')),
      );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listenWhen: (previous, current) =>
          previous.status != AuthStatus.signedIn &&
          current.status == AuthStatus.signedIn,
      listener: (context, state) => context.go(AppRoutes.dashboard),
      child: Scaffold(
        backgroundColor: AppColors.pageBg,
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.s24,
              vertical: AppSpacing.s40,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                spacing: 20,
                children: [
                  Column(
                    children: [
                      Text('Money Tracker', style: AppTextStyles.brandLarge),
                      const SizedBox(height: AppSpacing.s4),
                      Text(
                        'Income, spending and savings by source',
                        style: AppTextStyles.subtitle,
                      ),
                    ],
                  ),
                  _formCard(),
                  Text(
                    'Private app. Only the owner can sign in; '
                    'sign-ups are turned off.',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.caption,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _formCard() {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.s24),
      child: AutofillGroup(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: AppSpacing.s16,
          children: [
            Semantics(
              header: true,
              child: Text('Sign in', style: AppTextStyles.dialogTitle),
            ),
            AppTextField(
              label: 'Email',
              hintText: 'your-email@example.com',
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.username],
            ),
            AppTextField(
              label: 'Password',
              hintText: 'Your password',
              controller: _password,
              obscureText: true,
              textInputAction: TextInputAction.done,
              autofillHints: const [AutofillHints.password],
              onSubmitted: (_) => _submit(),
            ),
            BlocBuilder<AuthCubit, AuthState>(
              buildWhen: (previous, current) =>
                  previous.errorMessage != current.errorMessage,
              builder: (context, state) {
                final message = state.errorMessage;
                if (message == null) return const SizedBox.shrink();
                return Semantics(
                  liveRegion: true,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: AppSpacing.s12,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.expenseBg,
                      borderRadius:
                          BorderRadius.circular(AppSpacing.radiusControl),
                    ),
                    child: Text(
                      message,
                      style: AppTextStyles.buttonSmall
                          .copyWith(color: AppColors.expenseFg),
                    ),
                  ),
                );
              },
            ),
            AppButton(
              label: 'Sign in',
              size: AppButtonSize.large,
              expand: true,
              onPressed: _submit,
            ),
            Center(
              child: AppTextLink(
                label: 'Forgot password?',
                onPressed: _notWired,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'dart:ui';

import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:fortify/config/theme/admin_colors.dart';
import 'package:fortify/config/theme/admin_theme.dart';
import 'package:fortify/controllers/auth_controller.dart';
import 'package:fortify/state/auth_state.dart';

/// Password reset page. Sends a reset link to the provided email address.
class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({super.key});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  late final AuthController _authController = Inject.get<AuthController>();
  bool _submitted = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _sendResetLink(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;
    await _authController.resetPassword(email: _emailController.text.trim());
    if (context.mounted) {
      final AuthState authState = context.read<AuthState>();
      if (authState.error == null) {
        setState(() => _submitted = true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthState>(
      builder: (BuildContext context, AuthState authState, Widget? child) {
        return Scaffold(
          backgroundColor: AdminColors.background,
          body: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: _ResetPasswordCard(
                authState: authState,
                formKey: _formKey,
                emailController: _emailController,
                submitted: _submitted,
                onSubmit: () => _sendResetLink(context),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ResetPasswordCard extends StatelessWidget {
  final AuthState authState;
  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final bool submitted;
  final VoidCallback onSubmit;

  const _ResetPasswordCard({
    required this.authState,
    required this.formKey,
    required this.emailController,
    required this.submitted,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          width: 400,
          padding: const EdgeInsets.all(40),
          decoration: BoxDecoration(
            color: AdminColors.surfaceContainer.withValues(alpha: 0.85),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AdminColors.surfaceBorder),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              _ResetPasswordHeader(),
              const SizedBox(height: 32),
              if (submitted)
                _SuccessView(onBack: () => context.go('/login'))
              else ...<Widget>[
                if (authState.error != null) ...<Widget>[
                  _ErrorBanner(message: authState.error!),
                  const SizedBox(height: 16),
                ],
                if (authState.isLoading)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: CircularProgressIndicator(color: AdminColors.primary),
                  )
                else
                  _ResetForm(
                    formKey: formKey,
                    emailController: emailController,
                    onSubmit: onSubmit,
                    onBack: () => context.go('/login'),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ResetPasswordHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Text('FORTIFY', style: AdminTheme.orbitronStyle(fontSize: 32, fontWeight: FontWeight.w900)),
        const SizedBox(height: 8),
        const Text('Reset your password', style: TextStyle(color: AdminColors.onSurfaceVariant, fontSize: 14)),
      ],
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  final String message;

  const _ErrorBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AdminColors.error.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AdminColors.error.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: <Widget>[
          const Icon(Icons.error_outline, color: AdminColors.error, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(message, style: const TextStyle(color: AdminColors.error, fontSize: 13)),
          ),
        ],
      ),
    );
  }
}

class _ResetForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final VoidCallback onSubmit;
  final VoidCallback onBack;

  const _ResetForm({
    required this.formKey,
    required this.emailController,
    required this.onSubmit,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          const Text(
            'Enter your email address and we\'ll send you a link to reset your password.',
            style: TextStyle(color: AdminColors.onSurfaceVariant, fontSize: 14, height: 1.5),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          TextFormField(
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            style: const TextStyle(color: AdminColors.onSurface),
            decoration: const InputDecoration(labelText: 'Email'),
            validator: (String? value) {
              if (value == null || value.trim().isEmpty) return 'Email is required';
              if (!value.contains('@')) return 'Enter a valid email address';
              return null;
            },
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: onSubmit,
            style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
            child: const Text('Send Reset Link'),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: onBack,
            child: const Text('Back to login', style: TextStyle(color: AdminColors.onSurfaceVariant, fontSize: 13)),
          ),
        ],
      ),
    );
  }
}

class _SuccessView extends StatelessWidget {
  final VoidCallback onBack;

  const _SuccessView({required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: AdminColors.success.withValues(alpha: 0.15),
            shape: BoxShape.circle,
            border: Border.all(color: AdminColors.success.withValues(alpha: 0.4)),
          ),
          child: const Icon(Icons.check, color: AdminColors.success, size: 32),
        ),
        const SizedBox(height: 20),
        const Text(
          'Check your email',
          style: TextStyle(color: AdminColors.onSurface, fontSize: 20, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        const Text(
          'We\'ve sent a password reset link to your email address.',
          style: TextStyle(color: AdminColors.onSurfaceVariant, fontSize: 14, height: 1.5),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 28),
        TextButton(
          onPressed: onBack,
          child: const Text('Back to login', style: TextStyle(color: AdminColors.primary, fontSize: 14)),
        ),
      ],
    );
  }
}

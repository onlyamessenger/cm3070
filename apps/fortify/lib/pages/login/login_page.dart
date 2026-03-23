import 'dart:ui';

import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:fortify/config/theme/admin_colors.dart';
import 'package:fortify/config/theme/admin_theme.dart';
import 'package:fortify/controllers/auth_controller.dart';
import 'package:fortify/state/auth_state.dart';

/// Unified login page with social and email/password authentication options.
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  late final AuthController _authController = Inject.get<AuthController>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handlePostAuth(BuildContext context, AuthState authState) {
    if (!authState.isAuthenticated) return;
    if (authState.isAdmin) {
      context.go('/admin/dashboard');
    } else {
      context.go('/');
    }
  }

  Future<void> _submitEmailLogin(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;
    await _authController.loginWithEmail(email: _emailController.text.trim(), password: _passwordController.text);
    if (context.mounted) {
      final AuthState authState = context.read<AuthState>();
      _handlePostAuth(context, authState);
    }
  }

  Future<void> _loginWithGoogle(BuildContext context) async {
    await _authController.loginWithGoogle();
    if (context.mounted) {
      final AuthState authState = context.read<AuthState>();
      _handlePostAuth(context, authState);
    }
  }

  Future<void> _loginWithApple(BuildContext context) async {
    await _authController.loginWithApple();
    if (context.mounted) {
      final AuthState authState = context.read<AuthState>();
      _handlePostAuth(context, authState);
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
              child: _LoginCard(
                authState: authState,
                formKey: _formKey,
                emailController: _emailController,
                passwordController: _passwordController,
                onToggleEmailForm: () => _authController.toggleEmailForm(),
                onSubmitEmailLogin: () => _submitEmailLogin(context),
                onLoginWithGoogle: () => _loginWithGoogle(context),
                onLoginWithApple: () => _loginWithApple(context),
                onRegister: () => context.go('/register'),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _LoginCard extends StatelessWidget {
  final AuthState authState;
  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final VoidCallback onToggleEmailForm;
  final VoidCallback onSubmitEmailLogin;
  final VoidCallback onLoginWithGoogle;
  final VoidCallback onLoginWithApple;
  final VoidCallback onRegister;

  const _LoginCard({
    required this.authState,
    required this.formKey,
    required this.emailController,
    required this.passwordController,
    required this.onToggleEmailForm,
    required this.onSubmitEmailLogin,
    required this.onLoginWithGoogle,
    required this.onLoginWithApple,
    required this.onRegister,
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
              _LoginHeader(),
              const SizedBox(height: 32),
              if (authState.error != null) ...<Widget>[
                _ErrorBanner(message: authState.error!),
                const SizedBox(height: 16),
              ],
              if (authState.isLoading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: CircularProgressIndicator(color: AdminColors.primary),
                )
              else if (authState.showEmailForm)
                _EmailForm(
                  formKey: formKey,
                  emailController: emailController,
                  passwordController: passwordController,
                  onSubmit: onSubmitEmailLogin,
                  onBack: onToggleEmailForm,
                )
              else
                _SocialButtons(
                  onGoogle: onLoginWithGoogle,
                  onApple: onLoginWithApple,
                  onEmailToggle: onToggleEmailForm,
                  onRegister: onRegister,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LoginHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Text('FORTIFY', style: AdminTheme.orbitronStyle(fontSize: 32, fontWeight: FontWeight.w900)),
        const SizedBox(height: 8),
        const Text('Sign in to continue', style: TextStyle(color: AdminColors.onSurfaceVariant, fontSize: 14)),
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

class _SocialButtons extends StatelessWidget {
  final VoidCallback onGoogle;
  final VoidCallback onApple;
  final VoidCallback onEmailToggle;
  final VoidCallback onRegister;

  const _SocialButtons({
    required this.onGoogle,
    required this.onApple,
    required this.onEmailToggle,
    required this.onRegister,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        OutlinedButton.icon(
          onPressed: onGoogle,
          icon: const Icon(Icons.g_mobiledata, size: 22),
          label: const Text('Sign in with Google'),
          style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: onApple,
          icon: const Icon(Icons.apple, size: 22),
          label: const Text('Sign in with Apple'),
          style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
        ),
        const SizedBox(height: 24),
        const Divider(color: AdminColors.surfaceBorderSubtle),
        const SizedBox(height: 16),
        TextButton(
          onPressed: onEmailToggle,
          child: const Text('Sign in with email', style: TextStyle(color: AdminColors.primary)),
        ),
        const SizedBox(height: 8),
        TextButton(
          onPressed: onRegister,
          child: const Text('Create an account', style: TextStyle(color: AdminColors.primary, fontSize: 13)),
        ),
      ],
    );
  }
}

class _EmailForm extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final VoidCallback onSubmit;
  final VoidCallback onBack;

  const _EmailForm({
    required this.formKey,
    required this.emailController,
    required this.passwordController,
    required this.onSubmit,
    required this.onBack,
  });

  @override
  State<_EmailForm> createState() => _EmailFormState();
}

class _EmailFormState extends State<_EmailForm> {
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          TextFormField(
            controller: widget.emailController,
            keyboardType: TextInputType.emailAddress,
            style: const TextStyle(color: AdminColors.onSurface),
            decoration: const InputDecoration(labelText: 'Email'),
            validator: (String? value) {
              if (value == null || value.trim().isEmpty) return 'Email is required';
              if (!value.contains('@')) return 'Enter a valid email address';
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: widget.passwordController,
            obscureText: _obscurePassword,
            style: const TextStyle(color: AdminColors.onSurface),
            decoration: InputDecoration(
              labelText: 'Password',
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                  color: AdminColors.onSurfaceVariant,
                  size: 20,
                ),
                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
              ),
            ),
            validator: (String? value) {
              if (value == null || value.isEmpty) return 'Password is required';
              return null;
            },
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () => context.push('/login/reset-password'),
              child: const Text(
                'Forgot password?',
                style: TextStyle(color: AdminColors.onSurfaceVariant, fontSize: 13),
              ),
            ),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: widget.onSubmit,
            style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
            child: const Text('Sign in'),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: widget.onBack,
            child: const Text(
              'Back to social login',
              style: TextStyle(color: AdminColors.onSurfaceVariant, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}

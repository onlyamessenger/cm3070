import 'dart:convert';
import 'dart:ui';

import 'package:appwrite/appwrite.dart';
import 'package:appwrite/enums.dart';
import 'package:appwrite/models.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:fortify/config/theme/admin_colors.dart';
import 'package:fortify/config/theme/admin_theme.dart';
import 'package:fortify/controllers/auth_controller.dart';

/// Registration page for new player accounts.
class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  late final AuthController _authController = Inject.get<AuthController>();
  late final Functions _functions = Inject.get<Functions>();

  bool _isLoading = false;
  String? _error;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final Execution result = await _functions.createExecution(
        functionId: 'player',
        body: jsonEncode(<String, String>{
          'name': _nameController.text.trim(),
          'email': _emailController.text.trim(),
          'password': _passwordController.text,
        }),
        path: '/register',
        method: ExecutionMethod.pOST,
      );

      if (result.responseStatusCode >= 400) {
        final Map<String, dynamic> responseBody = jsonDecode(result.responseBody) as Map<String, dynamic>;
        final String message = responseBody['message'] as String? ?? 'Registration failed';
        setState(() {
          _error = message;
          _isLoading = false;
        });
        return;
      }

      await _authController.loginWithEmail(email: _emailController.text.trim(), password: _passwordController.text);

      if (mounted) {
        context.go('/');
      }
    } on Exception catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AdminColors.background,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ClipRRect(
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
                    Text('FORTIFY', style: AdminTheme.orbitronStyle(fontSize: 32, fontWeight: FontWeight.w900)),
                    const SizedBox(height: 8),
                    const Text(
                      'Create your account',
                      style: TextStyle(color: AdminColors.onSurfaceVariant, fontSize: 14),
                    ),
                    const SizedBox(height: 32),
                    if (_error != null) ...<Widget>[_ErrorBanner(message: _error!), const SizedBox(height: 16)],
                    if (_isLoading)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: CircularProgressIndicator(color: AdminColors.primary),
                      )
                    else
                      _RegisterForm(
                        formKey: _formKey,
                        nameController: _nameController,
                        emailController: _emailController,
                        passwordController: _passwordController,
                        confirmPasswordController: _confirmPasswordController,
                        obscurePassword: _obscurePassword,
                        obscureConfirmPassword: _obscureConfirmPassword,
                        onTogglePassword: () => setState(() => _obscurePassword = !_obscurePassword),
                        onToggleConfirmPassword: () =>
                            setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                        onSubmit: _submit,
                        onSignIn: () => context.go('/login'),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
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

class _RegisterForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final bool obscurePassword;
  final bool obscureConfirmPassword;
  final VoidCallback onTogglePassword;
  final VoidCallback onToggleConfirmPassword;
  final VoidCallback onSubmit;
  final VoidCallback onSignIn;

  const _RegisterForm({
    required this.formKey,
    required this.nameController,
    required this.emailController,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.obscurePassword,
    required this.obscureConfirmPassword,
    required this.onTogglePassword,
    required this.onToggleConfirmPassword,
    required this.onSubmit,
    required this.onSignIn,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          TextFormField(
            controller: nameController,
            style: const TextStyle(color: AdminColors.onSurface),
            decoration: const InputDecoration(labelText: 'Name'),
            validator: (String? value) {
              if (value == null || value.trim().isEmpty) return 'Name is required';
              return null;
            },
          ),
          const SizedBox(height: 16),
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
          const SizedBox(height: 16),
          TextFormField(
            controller: passwordController,
            obscureText: obscurePassword,
            style: const TextStyle(color: AdminColors.onSurface),
            decoration: InputDecoration(
              labelText: 'Password',
              suffixIcon: IconButton(
                icon: Icon(
                  obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                  color: AdminColors.onSurfaceVariant,
                  size: 20,
                ),
                onPressed: onTogglePassword,
              ),
            ),
            validator: (String? value) {
              if (value == null || value.isEmpty) return 'Password is required';
              if (value.length < 8) return 'Password must be at least 8 characters';
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: confirmPasswordController,
            obscureText: obscureConfirmPassword,
            style: const TextStyle(color: AdminColors.onSurface),
            decoration: InputDecoration(
              labelText: 'Confirm password',
              suffixIcon: IconButton(
                icon: Icon(
                  obscureConfirmPassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                  color: AdminColors.onSurfaceVariant,
                  size: 20,
                ),
                onPressed: onToggleConfirmPassword,
              ),
            ),
            validator: (String? value) {
              if (value == null || value.isEmpty) return 'Please confirm your password';
              if (value != passwordController.text) return 'Passwords do not match';
              return null;
            },
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: onSubmit,
            style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
            child: const Text('Create account'),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: onSignIn,
            child: const Text(
              'Already have an account? Sign in',
              style: TextStyle(color: AdminColors.primary, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}

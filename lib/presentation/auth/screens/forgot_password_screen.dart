import 'package:flutter/material.dart';
import 'package:syncsphere/core/theme/design_tokens.dart';
import 'package:syncsphere/core/widgets/reusable_widgets.dart';
import 'package:syncsphere/presentation/auth/providers/auth_provider.dart';
import 'package:provider/provider.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  bool _isLoading = false;
  bool _isSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _resetPassword() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your email address.'),
          backgroundColor: DesignTokens.error,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await context.read<AuthProvider>().resetPassword(email);
      if (mounted) {
        setState(() {
          _isSent = true;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: DesignTokens.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(DesignTokens.spacingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Reset Password',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: DesignTokens.spacingS),
            const Text(
              'Enter your email address and we\'ll send you a reset link.',
              style: TextStyle(
                fontSize: 16,
                color: DesignTokens.textSecondary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: DesignTokens.spacingXL),
            if (_isSent) ...[
              Container(
                padding: const EdgeInsets.all(DesignTokens.spacingM),
                decoration: BoxDecoration(
                  color: DesignTokens.success.withValues(alpha: 0.1),
                  borderRadius: DesignTokens.radiusM,
                  border: Border.all(color: DesignTokens.success),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, color: DesignTokens.success),
                    const SizedBox(width: DesignTokens.spacingM),
                    Expanded(
                      child: Text(
                        'If an account exists for ${_emailController.text}, a reset link has been sent.',
                        style: const TextStyle(color: DesignTokens.success),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: DesignTokens.spacingL),
              SyncSphereButton(
                label: 'Back to Sign In',
                onPressed: () => Navigator.pop(context),
              ),
            ] else ...[
              SyncSphereInputField(
                label: 'Email Address',
                hint: 'Enter your email',
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: DesignTokens.spacingL),
              SyncSphereButton(
                label: 'Send Reset Link',
                onPressed: _resetPassword,
                isLoading: _isLoading,
              ),
              const SizedBox(height: DesignTokens.spacingM),
              Center(
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Back to Sign In',
                    style: TextStyle(color: DesignTokens.textSecondary),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl    = TextEditingController();
  final _passCtrl     = TextEditingController();
  final _nameCtrl     = TextEditingController();
  final _confirmCtrl  = TextEditingController();

  bool _isLogin  = true;
  bool _obscure  = true;

  @override
  void dispose() {
    _emailCtrl.dispose(); _passCtrl.dispose();
    _nameCtrl.dispose();  _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final state = context.read<AppState>();

    final err = _isLogin
        ? await state.signIn(_emailCtrl.text, _passCtrl.text)
        : await state.signUp(_nameCtrl.text, _emailCtrl.text, _passCtrl.text);

    if (err != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(err),
          backgroundColor: const Color(0xFFC0392B),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final loading = context.watch<AppState>().loading;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Logo / title
                  const SizedBox(height: 24),
                  Container(
                    width: 52, height: 52,
                    decoration: BoxDecoration(
                      color: AppColors.dark,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.medication_rounded,
                        color: AppColors.background, size: 28),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    _isLogin ? 'Welcome back' : 'Create account',
                    style: const TextStyle(
                        fontSize: 26, fontWeight: FontWeight.w300,
                        color: AppColors.textPrimary, letterSpacing: -0.5),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _isLogin
                        ? 'Sign in to your Pill Pal account'
                        : 'Start tracking your medications',
                    style: const TextStyle(
                        fontSize: 14, color: AppColors.textMuted),
                  ),
                  const SizedBox(height: 36),

                  // Name (sign up only)
                  if (!_isLogin) ...[
                    _label('Full Name'),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _nameCtrl,
                      textCapitalization: TextCapitalization.words,
                      style: const TextStyle(fontSize: 15),
                      decoration: const InputDecoration(hintText: 'Muhammad Ali'),
                      validator: (v) => (!_isLogin && (v == null || v.trim().isEmpty))
                          ? 'Name is required' : null,
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Email
                  _label('Email'),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    style: const TextStyle(fontSize: 15),
                    decoration: const InputDecoration(hintText: 'you@example.com'),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Email is required';
                      if (!v.contains('@')) return 'Enter a valid email';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Password
                  _label('Password'),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _passCtrl,
                    obscureText: _obscure,
                    style: const TextStyle(fontSize: 15),
                    decoration: InputDecoration(
                      hintText: '••••••••',
                      suffixIcon: IconButton(
                        icon: Icon(_obscure
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                            size: 20, color: AppColors.textMuted),
                        onPressed: () => setState(() => _obscure = !_obscure),
                      ),
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Password is required';
                      if (v.length < 6) return 'Minimum 6 characters';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Confirm password (sign up only)
                  if (!_isLogin) ...[
                    _label('Confirm Password'),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _confirmCtrl,
                      obscureText: true,
                      style: const TextStyle(fontSize: 15),
                      decoration: const InputDecoration(hintText: '••••••••'),
                      validator: (v) => (!_isLogin && v != _passCtrl.text)
                          ? 'Passwords do not match' : null,
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Forgot password
                  if (_isLogin)
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () => _showForgotPassword(context),
                        child: const Text('Forgot password?',
                            style: TextStyle(fontSize: 13,
                                color: AppColors.textSecondary)),
                      ),
                    ),

                  const SizedBox(height: 24),

                  // Submit button
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: loading ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.dark,
                        foregroundColor: AppColors.background,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        textStyle: const TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w600,
                            letterSpacing: 0.3),
                      ),
                      child: loading
                          ? const SizedBox(
                              width: 20, height: 20,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: AppColors.background))
                          : Text(_isLogin ? 'Sign In' : 'Create Account'),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Toggle login/signup
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _isLogin
                            ? "Don't have an account? "
                            : 'Already have an account? ',
                        style: const TextStyle(
                            fontSize: 13, color: AppColors.textMuted),
                      ),
                      GestureDetector(
                        onTap: () => setState(() => _isLogin = !_isLogin),
                        child: Text(
                          _isLogin ? 'Sign Up' : 'Sign In',
                          style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showForgotPassword(BuildContext context) {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.background,
        title: const Text('Reset Password',
            style: TextStyle(fontWeight: FontWeight.w500, fontSize: 17)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Enter your email and we\'ll send a reset link.',
                style: TextStyle(fontSize: 13, color: AppColors.textMuted)),
            const SizedBox(height: 14),
            TextFormField(
              controller: ctrl,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(hintText: 'Email address'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel',
                style: TextStyle(color: AppColors.textMuted)),
          ),
          ElevatedButton(
            onPressed: () async {
              await context.read<AppState>().authService
                  .sendPasswordReset(ctrl.text);
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('Reset email sent!'),
                  behavior: SnackBarBehavior.floating,
                ));
              }
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.dark,
                foregroundColor: AppColors.background,
                elevation: 0),
            child: const Text('Send Link'),
          ),
        ],
      ),
    );
  }

  Widget _label(String t) => Text(t.toUpperCase(),
      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700,
          color: AppColors.textMuted, letterSpacing: 1.0));
}

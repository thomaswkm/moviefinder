import 'package:flutter/material.dart';

import '../controllers/register_controller.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({
    super.key,
    required this.controller,
    required this.onRegistered,
    this.onLoginRequested,
  });

  final RegisterController controller;
  final VoidCallback onRegistered;
  final VoidCallback? onLoginRequested;

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onControllerChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerChanged);
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _onControllerChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _submit() async {
    final success = await widget.controller.register(
      email: _emailController.text,
      password: _passwordController.text,
      confirmPassword: _confirmPasswordController.text,
    );

    if (success && mounted) {
      widget.onRegistered();
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 42, vertical: 36),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.sizeOf(context).height - 72,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 72),
                const Text(
                  '¡Unete y encuentra\ntus peliculas!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 34,
                    height: 1.15,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 84),
                _RegisterTextField(
                  controller: _emailController,
                  hintText: 'Email',
                  keyboardType: TextInputType.emailAddress,
                  errorText: controller.fieldErrors['email'],
                ),
                const SizedBox(height: 24),
                _RegisterTextField(
                  controller: _passwordController,
                  hintText: 'Password',
                  obscureText: true,
                  errorText: controller.fieldErrors['password'],
                ),
                const SizedBox(height: 24),
                _RegisterTextField(
                  controller: _confirmPasswordController,
                  hintText: 'Confirm Password',
                  obscureText: true,
                  errorText: controller.fieldErrors['confirmPassword'],
                ),
                if (controller.message != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    controller.message!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Color(0xFFFF8A80)),
                  ),
                ],
                const SizedBox(height: 60),
                SizedBox(
                  height: 66,
                  child: FilledButton(
                    onPressed: controller.isLoading ? null : _submit,
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF8CF241),
                      foregroundColor: Colors.black,
                      disabledBackgroundColor: const Color(
                        0xFF8CF241,
                      ).withValues(alpha: 0.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(32),
                      ),
                    ),
                    child: controller.isLoading
                        ? const SizedBox.square(
                            dimension: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.black,
                            ),
                          )
                        : const Text('Sign up', style: TextStyle(fontSize: 18)),
                  ),
                ),
                const SizedBox(height: 70),
                const Text(
                  '-Or sign in with-',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Color(0xFF9E9E9E), fontSize: 18),
                ),
                const SizedBox(height: 22),
                Center(
                  child: OutlinedButton.icon(
                    onPressed: null,
                    style: OutlinedButton.styleFrom(
                      disabledForegroundColor: Colors.white.withValues(
                        alpha: 0.45,
                      ),
                      side: BorderSide(
                        color: Colors.white.withValues(alpha: 0.45),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                    ),
                    icon: const _GoogleMark(),
                    label: const Text('Google'),
                  ),
                ),
                const SizedBox(height: 40),
                if (widget.onLoginRequested != null)
                  TextButton(
                    onPressed: widget.onLoginRequested,
                    child: const Text(
                      'Already have an account? Sign in',
                      style: TextStyle(color: Color(0xFF8CF241)),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RegisterTextField extends StatelessWidget {
  const _RegisterTextField({
    required this.controller,
    required this.hintText,
    this.keyboardType,
    this.obscureText = false,
    this.errorText,
  });

  final TextEditingController controller;
  final String hintText;
  final TextInputType? keyboardType;
  final bool obscureText;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      style: const TextStyle(color: Colors.white, fontSize: 18),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: Color(0xFF9E9E9E)),
        errorText: errorText,
        errorStyle: const TextStyle(color: Color(0xFFFF8A80)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 20,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF8CF241), width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFFF8A80)),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFFF8A80), width: 1.5),
        ),
      ),
    );
  }
}

class _GoogleMark extends StatelessWidget {
  const _GoogleMark();

  @override
  Widget build(BuildContext context) {
    return const Text(
      'G',
      style: TextStyle(
        color: Color(0xFF4285F4),
        fontSize: 22,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

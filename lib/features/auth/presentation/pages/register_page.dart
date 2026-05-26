import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../controllers/register_controller.dart';
import '../widgets/auth_background_mark.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/google_sign_in_button.dart';

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
    final screenHeight = MediaQuery.sizeOf(context).height;

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final contentWidth = constraints.maxWidth.clamp(0.0, 420.0);
            final logoSize = contentWidth * 0.95;

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: 420,
                    minHeight: screenHeight - 48,
                  ),
                  child: Stack(
                    alignment: Alignment.topCenter,
                    children: [
                      Positioned(
                        top: 205,
                        child: AuthBackgroundMark(size: logoSize),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          SizedBox(height: screenHeight < 720 ? 46 : 78),
                          Text(
                            '¡Únete y encuentra\ntus películas!',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.headlineLarge,
                          ),
                          const SizedBox(height: 84),
                          AuthTextField(
                            controller: _emailController,
                            hintText: 'Email',
                            keyboardType: TextInputType.emailAddress,
                            errorText: controller.fieldErrors['email'],
                          ),
                          const SizedBox(height: 24),
                          AuthTextField(
                            controller: _passwordController,
                            hintText: 'Password',
                            obscureText: true,
                            errorText: controller.fieldErrors['password'],
                          ),
                          const SizedBox(height: 24),
                          AuthTextField(
                            controller: _confirmPasswordController,
                            hintText: 'Confirm Password',
                            obscureText: true,
                            errorText:
                                controller.fieldErrors['confirmPassword'],
                          ),
                          if (controller.message != null) ...[
                            const SizedBox(height: 16),
                            Text(
                              controller.message!,
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: AppColors.error),
                            ),
                          ],
                          const SizedBox(height: 60),
                          FilledButton(
                            onPressed: controller.isLoading ? null : _submit,
                            child: controller.isLoading
                                ? const SizedBox.square(
                                    dimension: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.black,
                                    ),
                                  )
                                : const Text('Sign up'),
                          ),
                          const SizedBox(height: 70),
                          const Text(
                            '-Or sign in with-',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: AppColors.secondaryText,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 22),
                          const Center(child: GoogleSignInButton()),
                          if (widget.onLoginRequested != null) ...[
                            const SizedBox(height: 36),
                            TextButton(
                              onPressed: widget.onLoginRequested,
                              child: const Text(
                                'Already have an account? Sign in',
                                style: TextStyle(color: AppColors.primary),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

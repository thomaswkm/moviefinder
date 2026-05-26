import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/theme_controller.dart';
import '../../../../shared/widgets/theme_mode_toggle.dart';
import '../controllers/login_controller.dart';
import '../widgets/auth_background_mark.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/google_sign_in_button.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({
    super.key,
    required this.controller,
    required this.themeController,
    required this.onLoggedIn,
    required this.onRegisterRequested,
  });

  final LoginController controller;
  final ThemeController themeController;
  final VoidCallback onLoggedIn;
  final VoidCallback onRegisterRequested;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

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
    super.dispose();
  }

  void _onControllerChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _submit() async {
    final success = await widget.controller.login(
      email: _emailController.text,
      password: _passwordController.text,
    );

    if (success && mounted) {
      widget.onLoggedIn();
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    final textTheme = Theme.of(context).textTheme;
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
                        top: 190,
                        child: AuthBackgroundMark(size: logoSize),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Align(
                            alignment: Alignment.centerRight,
                            child: ThemeModeToggle(
                              controller: widget.themeController,
                            ),
                          ),
                          SizedBox(height: screenHeight < 720 ? 40 : 70),
                          Text(
                            '¡Bienvenido!',
                            textAlign: TextAlign.center,
                            style: textTheme.headlineLarge,
                          ),
                          const SizedBox(height: 76),
                          Text(
                            'Login to your Account',
                            style: textTheme.titleLarge,
                          ),
                          const SizedBox(height: 30),
                          AuthTextField(
                            controller: _emailController,
                            hintText: 'Email',
                            keyboardType: TextInputType.emailAddress,
                            errorText: controller.fieldErrors['email'],
                          ),
                          const SizedBox(height: 44),
                          AuthTextField(
                            controller: _passwordController,
                            hintText: 'Password',
                            obscureText: true,
                            errorText: controller.fieldErrors['password'],
                          ),
                          if (controller.message != null) ...[
                            const SizedBox(height: 16),
                            Text(
                              controller.message!,
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: AppColors.error),
                            ),
                          ],
                          const SizedBox(height: 70),
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
                                : const Text('Sign In'),
                          ),
                          const SizedBox(height: 46),
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
                          const SizedBox(height: 72),
                          TextButton(
                            key: const Key('go_to_register_button'),
                            onPressed: widget.onRegisterRequested,
                            child: Text.rich(
                              TextSpan(
                                text: "Don't have an account? ",
                                style: TextStyle(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface,
                                  fontSize: 16,
                                ),
                                children: const [
                                  TextSpan(
                                    text: 'Sign up',
                                    style: TextStyle(color: AppColors.primary),
                                  ),
                                ],
                              ),
                            ),
                          ),
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

import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'core/theme/theme_controller.dart';
import 'core/storage/token_storage.dart';
import 'features/auth/data/datasources/auth_mock_data_source.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/entities/authenticated_user.dart';
import 'features/auth/domain/usecases/login_user.dart';
import 'features/auth/domain/usecases/register_user.dart';
import 'features/auth/presentation/controllers/login_controller.dart';
import 'features/auth/presentation/controllers/register_controller.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/auth/presentation/pages/register_page.dart';
import 'features/intro/presentation/pages/intro_page.dart';

void main() {
  runApp(const MovieFinderApp());
}

class MovieFinderApp extends StatefulWidget {
  const MovieFinderApp({super.key});

  @override
  State<MovieFinderApp> createState() => _MovieFinderAppState();
}

class _MovieFinderAppState extends State<MovieFinderApp> {
  late final TokenStorage _tokenStorage;
  late final ThemeController _themeController;
  late final LoginController _loginController;
  late final RegisterController _registerController;

  AppScreen _screen = AppScreen.intro;
  AuthenticatedUser? _authenticatedUser;

  @override
  void initState() {
    super.initState();
    _tokenStorage = TokenStorage();
    _themeController = ThemeController();
    final authRepository = AuthRepositoryImpl(
      const AuthMockDataSource(),
      _tokenStorage,
    );
    _loginController = LoginController(LoginUser(authRepository));
    _registerController = RegisterController(RegisterUser(authRepository));
  }

  @override
  void dispose() {
    _themeController.dispose();
    _loginController.dispose();
    _registerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _themeController,
      builder: (context, _) {
        return MaterialApp(
          title: 'MovieFinder',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: _themeController.themeMode,
          home: AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            transitionBuilder: (child, animation) {
              final offsetAnimation = Tween<Offset>(
                begin: const Offset(0, 0.03),
                end: Offset.zero,
              ).animate(animation);

              return FadeTransition(
                opacity: animation,
                child: SlideTransition(position: offsetAnimation, child: child),
              );
            },
            child: _buildScreen(),
          ),
        );
      },
    );
  }

  Widget _buildScreen() {
    return switch (_screen) {
      AppScreen.intro => IntroPage(
        key: const ValueKey(AppScreen.intro),
        onFinished: () => _showScreen(AppScreen.login),
      ),
      AppScreen.login => LoginPage(
        key: const ValueKey(AppScreen.login),
        controller: _loginController,
        themeController: _themeController,
        onLoggedIn: () {
          _authenticatedUser = _loginController.authenticatedUser;
          _showScreen(AppScreen.home);
        },
        onRegisterRequested: () => _showScreen(AppScreen.register),
      ),
      AppScreen.register => RegisterPage(
        key: const ValueKey(AppScreen.register),
        controller: _registerController,
        themeController: _themeController,
        onRegistered: () {
          _authenticatedUser = _registerController.registeredUser;
          _showScreen(AppScreen.home);
        },
        onLoginRequested: () => _showScreen(AppScreen.login),
      ),
      AppScreen.home => _HomePlaceholder(
        key: const ValueKey(AppScreen.home),
        username: _authenticatedUser?.username ?? 'user',
      ),
    };
  }

  void _showScreen(AppScreen screen) {
    setState(() {
      _screen = screen;
    });
  }
}

enum AppScreen { intro, login, register, home }

class _HomePlaceholder extends StatelessWidget {
  const _HomePlaceholder({super.key, required this.username});

  final String username;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.movie_filter_outlined, size: 64),
              const SizedBox(height: 16),
              Text(
                'Cuenta creada',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Bienvenido, $username. Home se implementara en CU-04.',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

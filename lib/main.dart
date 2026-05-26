import 'package:flutter/material.dart';

import 'core/result/result.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_controller.dart';
import 'core/storage/token_storage.dart';
import 'features/auth/data/datasources/auth_mock_data_source.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/entities/authenticated_user.dart';
import 'features/auth/domain/usecases/get_current_user.dart';
import 'features/auth/domain/usecases/login_user.dart';
import 'features/auth/domain/usecases/register_user.dart';
import 'features/auth/presentation/controllers/login_controller.dart';
import 'features/auth/presentation/controllers/register_controller.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/auth/presentation/pages/register_page.dart';
import 'features/catalog/data/datasources/media_mock_data_source.dart';
import 'features/catalog/data/repositories/media_repository_impl.dart';
import 'features/catalog/domain/entities/media_item.dart';
import 'features/catalog/domain/usecases/get_home_media_items.dart';
import 'features/catalog/presentation/controllers/home_controller.dart';
import 'features/catalog/presentation/pages/home_page.dart';
import 'features/catalog/presentation/pages/media_detail_page.dart';
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
  late final GetCurrentUser _getCurrentUser;
  late final LoginController _loginController;
  late final RegisterController _registerController;
  late final HomeController _homeController;

  AppScreen _screen = AppScreen.intro;
  AuthenticatedUser? _authenticatedUser;
  MediaItem? _selectedItem;

  @override
  void initState() {
    super.initState();
    _tokenStorage = TokenStorage();
    _themeController = ThemeController();
    final authRepository = AuthRepositoryImpl(
      const AuthMockDataSource(),
      _tokenStorage,
    );
    _getCurrentUser = GetCurrentUser(authRepository);
    _loginController = LoginController(LoginUser(authRepository));
    _registerController = RegisterController(RegisterUser(authRepository));
    final mediaRepository = MediaRepositoryImpl(const MediaMockDataSource());
    _homeController = HomeController(GetHomeMediaItems(mediaRepository));
    _restoreSession();
  }

  @override
  void dispose() {
    _themeController.dispose();
    _loginController.dispose();
    _registerController.dispose();
    _homeController.dispose();
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
        onFinished: () {
          if (_authenticatedUser == null) {
            _showScreen(AppScreen.login);
          }
        },
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
      AppScreen.home => HomePage(
        key: const ValueKey(AppScreen.home),
        controller: _homeController,
        onItemSelected: _showMediaDetail,
      ),
      AppScreen.mediaDetail => MediaDetailPage(
        key: const ValueKey(AppScreen.mediaDetail),
        item: _selectedItem!,
        onBack: () => _showScreen(AppScreen.home),
      ),
    };
  }

  void _showScreen(AppScreen screen) {
    setState(() {
      _screen = screen;
    });
  }

  Future<void> _restoreSession() async {
    final result = await _getCurrentUser();

    if (!mounted) {
      return;
    }

    switch (result) {
      case Success<AuthenticatedUser?>(value: final user):
        if (user != null) {
          setState(() {
            _authenticatedUser = user;
            _screen = AppScreen.home;
          });
        }
      case Failure<AuthenticatedUser?>():
        break;
    }
  }

  void _showMediaDetail(MediaItem item) {
    setState(() {
      _selectedItem = item;
      _screen = AppScreen.mediaDetail;
    });
  }
}

enum AppScreen { intro, login, register, home, mediaDetail }

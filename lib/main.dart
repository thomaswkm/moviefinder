import 'package:flutter/material.dart';

import 'core/network/api_client.dart';
import 'core/network/api_config.dart';
import 'core/result/result.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_controller.dart';
import 'core/storage/token_storage.dart';
import 'features/auth/data/datasources/auth_mock_data_source.dart';
import 'features/auth/data/datasources/auth_remote_data_source.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/entities/authenticated_user.dart';
import 'features/auth/domain/usecases/get_current_user.dart';
import 'features/auth/domain/usecases/login_user.dart';
import 'features/auth/domain/usecases/logout_user.dart';
import 'features/auth/domain/usecases/register_user.dart';
import 'features/auth/presentation/controllers/login_controller.dart';
import 'features/auth/presentation/controllers/register_controller.dart';
import 'features/auth/presentation/pages/account_page.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/auth/presentation/pages/register_page.dart';
import 'features/catalog/data/datasources/media_remote_data_source.dart';
import 'features/catalog/data/datasources/media_mock_data_source.dart';
import 'features/catalog/data/datasources/wishlist_mock_data_source.dart';
import 'features/catalog/data/datasources/wishlist_remote_data_source.dart';
import 'features/catalog/data/repositories/media_repository_impl.dart';
import 'features/catalog/domain/entities/media_item.dart';
import 'features/catalog/domain/usecases/get_home_media_items.dart';
import 'features/catalog/presentation/controllers/home_controller.dart';
import 'features/catalog/presentation/controllers/search_controller.dart'
    as catalog;
import 'features/catalog/presentation/controllers/wishlist_controller.dart';
import 'features/catalog/presentation/pages/home_page.dart';
import 'features/catalog/presentation/pages/media_detail_page.dart';
import 'features/catalog/presentation/pages/search_page.dart';
import 'features/catalog/presentation/pages/wishlist_page.dart';
import 'features/intro/presentation/pages/intro_page.dart';
import 'features/recommendations/data/datasources/recommendations_remote_data_source.dart';
import 'features/recommendations/presentation/controllers/recommendations_controller.dart';
import 'features/recommendations/presentation/pages/recommendations_page.dart';
import 'features/streaming/data/datasources/streaming_remote_data_source.dart';
import 'features/streaming/data/datasources/streaming_mock_data_source.dart';
import 'features/streaming/data/repositories/streaming_repository_impl.dart';
import 'features/streaming/domain/usecases/get_streaming_sources.dart';
import 'shared/widgets/theme_mode_toggle.dart';

void main() {
  runApp(const MovieFinderApp());
}

class MovieFinderApp extends StatefulWidget {
  const MovieFinderApp({super.key, this.useMockData = false});

  final bool useMockData;

  @override
  State<MovieFinderApp> createState() => _MovieFinderAppState();
}

class _MovieFinderAppState extends State<MovieFinderApp> {
  late final TokenStorage _tokenStorage;
  late final ApiClient _apiClient;
  late final ThemeController _themeController;
  late final GetCurrentUser _getCurrentUser;
  late final LogoutUser _logoutUser;
  late final LoginController _loginController;
  late final RegisterController _registerController;
  late final HomeController _homeController;
  late final catalog.MediaSearchController _searchController;
  late final WishlistController _wishlistController;
  late final RecommendationsController _recommendationsController;
  late final GetStreamingSources _getStreamingSources;

  AppScreen _screen = AppScreen.intro;
  AppScreen _detailReturnScreen = AppScreen.home;
  AuthenticatedUser? _authenticatedUser;
  MediaItem? _selectedItem;

  @override
  void initState() {
    super.initState();
    _tokenStorage = TokenStorage();
    _apiClient = ApiClient(
      config: ApiConfig.development,
      tokenStorage: _tokenStorage,
    );
    _themeController = ThemeController();
    final authRepository = AuthRepositoryImpl(
      widget.useMockData
          ? const AuthMockDataSource()
          : AuthRemoteDataSource(_apiClient),
      _tokenStorage,
    );
    _getCurrentUser = GetCurrentUser(authRepository);
    _logoutUser = LogoutUser(authRepository);
    _loginController = LoginController(LoginUser(authRepository));
    _registerController = RegisterController(RegisterUser(authRepository));
    final mediaDataSource = MediaRemoteDataSource(_apiClient);
    final mediaRepository = MediaRepositoryImpl(
      widget.useMockData ? const MediaMockDataSource() : mediaDataSource,
    );
    _homeController = HomeController(GetHomeMediaItems(mediaRepository));
    _searchController = catalog.MediaSearchController(
      widget.useMockData ? const MediaMockDataSource() : mediaDataSource,
    );
    _wishlistController = WishlistController(
      widget.useMockData
          ? WishlistMockDataSource()
          : WishlistRemoteDataSource(_apiClient),
    );
    _recommendationsController = RecommendationsController(
      RecommendationsRemoteDataSource(_apiClient),
    );
    final streamingRepository = StreamingRepositoryImpl(
      widget.useMockData
          ? const StreamingMockDataSource()
          : StreamingRemoteDataSource(_apiClient),
    );
    _getStreamingSources = GetStreamingSources(streamingRepository);
    _restoreSession();
  }

  @override
  void dispose() {
    _themeController.dispose();
    _loginController.dispose();
    _registerController.dispose();
    _homeController.dispose();
    _searchController.dispose();
    _wishlistController.dispose();
    _recommendationsController.dispose();
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
          home: Stack(
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                transitionBuilder: (child, animation) {
                  final offsetAnimation = Tween<Offset>(
                    begin: const Offset(0, 0.03),
                    end: Offset.zero,
                  ).animate(animation);

                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: offsetAnimation,
                      child: child,
                    ),
                  );
                },
                child: _buildScreen(),
              ),
              Positioned(
                top: 16,
                right: 16,
                child: SafeArea(
                  child: Material(
                    color: Colors.transparent,
                    child: ThemeModeToggle(
                      key: const Key('global_theme_mode_toggle'),
                      controller: _themeController,
                    ),
                  ),
                ),
              ),
            ],
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
        onLoggedIn: () {
          _authenticatedUser = _loginController.authenticatedUser;
          _showScreen(AppScreen.home);
        },
        onRegisterRequested: () => _showScreen(AppScreen.register),
      ),
      AppScreen.register => RegisterPage(
        key: const ValueKey(AppScreen.register),
        controller: _registerController,
        onRegistered: () {
          _authenticatedUser = _registerController.registeredUser;
          _showScreen(AppScreen.home);
        },
        onLoginRequested: () => _showScreen(AppScreen.login),
      ),
      AppScreen.home => HomePage(
        key: const ValueKey(AppScreen.home),
        controller: _homeController,
        onItemSelected: (item) => _showMediaDetail(item, AppScreen.home),
        onSearchPressed: () => _showScreen(AppScreen.search),
        onWishlistPressed: () => _showScreen(AppScreen.wishlist),
        onProfilePressed: () => _showScreen(AppScreen.account),
      ),
      AppScreen.search => SearchPage(
        key: const ValueKey(AppScreen.search),
        controller: _searchController,
        onItemSelected: (item) => _showMediaDetail(item, AppScreen.search),
        onBack: () => _showScreen(AppScreen.home),
      ),
      AppScreen.wishlist => WishlistPage(
        key: const ValueKey(AppScreen.wishlist),
        controller: _wishlistController,
        onItemSelected: (item) => _showMediaDetail(item, AppScreen.wishlist),
        onBack: () => _showScreen(AppScreen.home),
      ),
      AppScreen.account => AccountPage(
        key: const ValueKey(AppScreen.account),
        user: _authenticatedUser,
        onBack: () => _showScreen(AppScreen.home),
        onRecommendationsPressed: () => _showScreen(AppScreen.recommendations),
        onLogoutPressed: _logout,
      ),
      AppScreen.recommendations => RecommendationsPage(
        key: const ValueKey(AppScreen.recommendations),
        controller: _recommendationsController,
        onBack: () => _showScreen(AppScreen.account),
      ),
      AppScreen.mediaDetail => MediaDetailPage(
        key: const ValueKey(AppScreen.mediaDetail),
        item: _selectedItem!,
        getStreamingSources: _getStreamingSources,
        wishlistController: _wishlistController,
        onBack: () => _showScreen(_detailReturnScreen),
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

  void _showMediaDetail(MediaItem item, AppScreen returnScreen) {
    setState(() {
      _detailReturnScreen = returnScreen;
      _selectedItem = item;
      _screen = AppScreen.mediaDetail;
    });
  }

  Future<void> _logout() async {
    await _logoutUser();
    if (!mounted) {
      return;
    }

    setState(() {
      _authenticatedUser = null;
      _selectedItem = null;
      _detailReturnScreen = AppScreen.home;
      _screen = AppScreen.login;
    });
  }
}

enum AppScreen {
  intro,
  login,
  register,
  home,
  search,
  wishlist,
  account,
  recommendations,
  mediaDetail,
}

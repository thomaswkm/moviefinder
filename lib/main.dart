import 'package:flutter/material.dart';

import 'core/storage/token_storage.dart';
import 'features/auth/data/datasources/auth_mock_data_source.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/usecases/register_user.dart';
import 'features/auth/presentation/controllers/register_controller.dart';
import 'features/auth/presentation/pages/register_page.dart';

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
  late final RegisterController _registerController;

  bool _isRegistered = false;

  @override
  void initState() {
    super.initState();
    _tokenStorage = TokenStorage();
    final authRepository = AuthRepositoryImpl(
      const AuthMockDataSource(),
      _tokenStorage,
    );
    _registerController = RegisterController(RegisterUser(authRepository));
  }

  @override
  void dispose() {
    _registerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MovieFinder',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF8CF241)),
        useMaterial3: true,
      ),
      home: _isRegistered
          ? _HomePlaceholder(
              username: _registerController.registeredUser?.username ?? 'user',
            )
          : RegisterPage(
              controller: _registerController,
              onRegistered: () {
                setState(() {
                  _isRegistered = true;
                });
              },
            ),
    );
  }
}

class _HomePlaceholder extends StatelessWidget {
  const _HomePlaceholder({required this.username});

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

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/di/injection.dart';
import 'core/env/app_env.dart';
import 'core/theme/app_colors.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_cubit.dart';
import 'features/auth/presentation/cubit/auth_cubit.dart';
import 'features/auth/presentation/cubit/auth_state.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/cart/presentation/cubit/cart_cubit.dart';
import 'features/favorites/presentation/cubit/favorites_cubit.dart';
import 'features/products/presentation/pages/products_shell.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  _setInitialStatusBar();
  AppEnv.init(Flavor.prod);
  await bootstrap();
}

void _setInitialStatusBar() {
  // Will be overridden by ThemeCubit.applySavedTheme() after DI init
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ),
  );
}

/// Bootstrap the app. Call after [AppEnv.init] in flavor entry points.
Future<void> bootstrap() async {
  await initInjection();
  runApp(const TechnicaTaskApp());
}

class TechnicaTaskApp extends StatelessWidget {
  const TechnicaTaskApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ThemeCubit>()..applySavedTheme(),
      child: BlocProvider(
        create: (_) => sl<AuthCubit>()..checkAuth(),
        child: BlocProvider(
          create: (_) {
            final cubit = sl<FavoritesCubit>();
            cubit.loadFavorites();
            return cubit;
          },
          child: BlocProvider(
            create: (_) {
              final cubit = sl<CartCubit>();
              cubit.loadCart();
              return cubit;
            },
            child: BlocBuilder<ThemeCubit, ThemeMode>(
              builder: (context, themeMode) {
                return MaterialApp(
                  title: AppEnv.current.appName,
                  debugShowCheckedModeBanner: AppEnv.current.showDebugBanner,
                  theme: AppTheme.light,
                  darkTheme: AppTheme.dark,
                  themeMode: themeMode,
                  home: BlocBuilder<AuthCubit, AuthState>(
                    builder: (context, state) {
                      return AnimatedSwitcher(
                        duration: const Duration(milliseconds: 400),
                        switchInCurve: Curves.easeOutCubic,
                        child: switch (state) {
                          AuthStateInitial() || AuthStateLoading() =>
                            const _SplashScreen(key: ValueKey('splash')),
                          AuthStateAuthenticated() => const ProductsShell(
                            key: ValueKey('products'),
                          ),
                          AuthStateUnauthenticated() ||
                          AuthStateError() =>
                            const LoginPage(key: ValueKey('login')),
                        },
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

/// A polished splash screen shown while checking auth.
class _SplashScreen extends StatelessWidget {
  const _SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.storefront_rounded,
                size: 36,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

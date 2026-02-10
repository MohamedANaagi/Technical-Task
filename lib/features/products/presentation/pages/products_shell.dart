import 'package:flutter/material.dart';

import 'main_shell.dart';

/// Wraps the main app with bottom nav: Products, Favorites, Cart, Profile.
/// [FavoritesCubit] is provided in [main.dart] above the Navigator.
class ProductsShell extends StatelessWidget {
  const ProductsShell({super.key});

  @override
  Widget build(BuildContext context) {
    return const MainShell();
  }
}

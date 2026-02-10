import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/pages/profile_page.dart';
import '../../../cart/presentation/cubit/cart_cubit.dart';
import '../../../cart/presentation/cubit/cart_state.dart';
import 'cart_page.dart';
import 'favorites_page.dart';
import 'products_list_page.dart';

/// Main shell with a custom animated bottom navigation bar.
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> with TickerProviderStateMixin {
  int _currentIndex = 0;

  static const _tabs = [
    _NavItem(Icons.storefront_outlined, Icons.storefront_rounded, 'Store'),
    _NavItem(
      Icons.favorite_outline_rounded,
      Icons.favorite_rounded,
      'Favorites',
    ),
    _NavItem(Icons.shopping_bag_outlined, Icons.shopping_bag_rounded, 'Cart'),
    _NavItem(Icons.person_outline_rounded, Icons.person_rounded, 'Profile'),
  ];

  void _onTabTapped(int index) {
    if (index == _currentIndex) return;
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          HeroMode(
            enabled: _currentIndex == 0,
            child: const ProductsListPage(),
          ),
          HeroMode(enabled: _currentIndex == 1, child: const FavoritesPage()),
          HeroMode(enabled: _currentIndex == 2, child: const CartPage()),
          HeroMode(enabled: _currentIndex == 3, child: const ProfilePage()),
        ],
      ),
      extendBody: true,
      bottomNavigationBar: _AnimatedNavBar(
        currentIndex: _currentIndex,
        tabs: _tabs,
        onTap: _onTabTapped,
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// Animated Nav Bar
// ═══════════════════════════════════════════════════════════════════════════════
class _AnimatedNavBar extends StatelessWidget {
  const _AnimatedNavBar({
    required this.currentIndex,
    required this.tabs,
    required this.onTap,
  });

  final int currentIndex;
  final List<_NavItem> tabs;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Container(
      margin: EdgeInsets.fromLTRB(
        16,
        0,
        16,
        bottomPadding > 0 ? bottomPadding : 12,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            height: 68,
            decoration: BoxDecoration(
              color: isDark
                  ? colorScheme.surfaceContainerHigh.withValues(alpha: 0.85)
                  : Colors.white.withValues(alpha: 0.85),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.08)
                    : Colors.black.withValues(alpha: 0.04),
              ),
              boxShadow: [
                BoxShadow(
                  color: colorScheme.shadow.withValues(
                    alpha: isDark ? 0.3 : 0.1,
                  ),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.06),
                  blurRadius: 40,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(tabs.length, (i) {
                final isSelected = i == currentIndex;
                // Cart tab with badge
                if (i == 2) {
                  return BlocBuilder<CartCubit, CartState>(
                    builder: (context, state) {
                      final count = state is CartStateLoaded
                          ? state.itemCount
                          : 0;
                      return _NavBarItem(
                        tab: tabs[i],
                        isSelected: isSelected,
                        onTap: () => onTap(i),
                        badgeCount: count,
                      );
                    },
                  );
                }
                return _NavBarItem(
                  tab: tabs[i],
                  isSelected: isSelected,
                  onTap: () => onTap(i),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// Individual Nav Item with animations
// ═══════════════════════════════════════════════════════════════════════════════
class _NavBarItem extends StatefulWidget {
  const _NavBarItem({
    required this.tab,
    required this.isSelected,
    required this.onTap,
    this.badgeCount = 0,
  });

  final _NavItem tab;
  final bool isSelected;
  final VoidCallback onTap;
  final int badgeCount;

  @override
  State<_NavBarItem> createState() => _NavBarItemState();
}

class _NavBarItemState extends State<_NavBarItem>
    with TickerProviderStateMixin {
  late final AnimationController _scaleController;
  late final AnimationController _selectController;
  late final Animation<double> _scaleAnim;
  late final Animation<double> _selectAnim;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnim = Tween(begin: 1.0, end: 0.85).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );

    _selectController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
      value: widget.isSelected ? 1.0 : 0.0,
    );
    _selectAnim = CurvedAnimation(
      parent: _selectController,
      curve: Curves.easeOutBack,
    );
  }

  @override
  void didUpdateWidget(covariant _NavBarItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSelected != oldWidget.isSelected) {
      if (widget.isSelected) {
        _selectController.forward();
      } else {
        _selectController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _selectController.dispose();
    super.dispose();
  }

  void _handleTapDown(_) => _scaleController.forward();
  void _handleTapUp(_) => _scaleController.reverse();
  void _handleTapCancel() => _scaleController.reverse();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      onTap: widget.onTap,
      behavior: HitTestBehavior.opaque,
      child: ScaleTransition(
        scale: _scaleAnim,
        child: SizedBox(
          width: 64,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Animated pill indicator
              AnimatedBuilder(
                animation: _selectAnim,
                builder: (context, child) {
                  return Container(
                    width: 40 * _selectAnim.value,
                    height: 3,
                    margin: const EdgeInsets.only(bottom: 4),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(2),
                      gradient: _selectAnim.value > 0.01
                          ? AppColors.primaryGradient
                          : null,
                    ),
                  );
                },
              ),
              // Icon with badge + animation
              AnimatedBuilder(
                animation: _selectAnim,
                builder: (context, _) {
                  final icon = widget.isSelected
                      ? widget.tab.filled
                      : widget.tab.outlined;
                  final iconSize = 24.0 + (2.0 * _selectAnim.value);
                  final color = Color.lerp(
                    colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                    colorScheme.primary,
                    _selectAnim.value,
                  )!;

                  Widget iconWidget = Icon(icon, size: iconSize, color: color);

                  // Badge for cart
                  if (widget.badgeCount > 0) {
                    iconWidget = Badge(
                      label: Text(
                        '${widget.badgeCount}',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      backgroundColor: AppColors.tertiary,
                      child: iconWidget,
                    );
                  }

                  return iconWidget;
                },
              ),
              const SizedBox(height: 3),
              // Label
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOut,
                style: TextStyle(
                  fontSize: widget.isSelected ? 11.0 : 10.0,
                  fontWeight: widget.isSelected
                      ? FontWeight.w700
                      : FontWeight.w500,
                  color: widget.isSelected
                      ? colorScheme.primary
                      : colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                  letterSpacing: widget.isSelected ? 0.2 : 0.0,
                ),
                child: Text(widget.tab.label),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
class _NavItem {
  const _NavItem(this.outlined, this.filled, this.label);
  final IconData outlined;
  final IconData filled;
  final String label;
}

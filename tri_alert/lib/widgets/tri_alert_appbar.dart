import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

/// AppBar morado con logo TriAlert, menú hamburguesa y campana
class TriAlertAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback onMenuTap;
  final bool showBack;
  final String? title;

  const TriAlertAppBar({
    super.key,
    required this.onMenuTap,
    this.showBack = false,
    this.title,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.appBarPurple,
      elevation: 0,
      leading: showBack
          ? IconButton(
              icon: const Icon(Icons.menu, color: Colors.white, size: 26),
              onPressed: onMenuTap,
            )
          : IconButton(
              icon: const Icon(Icons.menu, color: Colors.white, size: 26),
              onPressed: onMenuTap,
            ),
      title: title != null
          ? Text(
              title!,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            )
          : ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [Color(0xFF64B5F6), Colors.white, Color(0xFF64B5F6)],
              ).createShader(bounds),
              child: const Text(
                'TriAlert',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
      centerTitle: true,
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_none,
              color: Colors.white, size: 26),
          onPressed: () {},
        ),
      ],
    );
  }
}

/// Bottom Navigation Bar compartida
class TriAlertNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const TriAlertNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      decoration: BoxDecoration(
        color: AppColors.navBarBg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _NavItem(
            icon: Icons.home_rounded,
            index: 0,
            currentIndex: currentIndex,
            onTap: onTap,
          ),
          _NavItem(
            icon: Icons.add,
            index: 1,
            currentIndex: currentIndex,
            onTap: onTap,
            isCenter: true,
          ),
          _NavItem(
            icon: Icons.bar_chart_rounded,
            index: 2,
            currentIndex: currentIndex,
            onTap: onTap,
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final int index;
  final int currentIndex;
  final ValueChanged<int> onTap;
  final bool isCenter;

  const _NavItem({
    required this.icon,
    required this.index,
    required this.currentIndex,
    required this.onTap,
    this.isCenter = false,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = currentIndex == index;

    if (isCenter) {
      return GestureDetector(
        onTap: () => onTap(index),
        child: Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: isActive ? AppColors.primary : const Color(0xFF3A2D9A),
            shape: BoxShape.circle,
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.5),
                      blurRadius: 12,
                      spreadRadius: 2,
                    )
                  ]
                : [],
          ),
          child: Icon(icon, color: Colors.white, size: 26),
        ),
      );
    }

    return GestureDetector(
      onTap: () => onTap(index),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.navBarActive
              : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: isActive ? AppColors.primary : Colors.white60,
          size: 26,
        ),
      ),
    );
  }
}

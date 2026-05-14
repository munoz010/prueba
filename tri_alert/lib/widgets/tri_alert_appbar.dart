import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../utils/app_images.dart';

/// AppBar global de TriAlert
class TriAlertAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback onMenuTap;

  const TriAlertAppBar({super.key, required this.onMenuTap});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.appBarPurple,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.menu, color: Colors.white, size: 26),
        onPressed: onMenuTap,
      ),
      title: Image.network(
        AppImages.logoTexto,
        height: 30,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => const Text(
          'TriAlert',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      centerTitle: true,
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_none, color: Colors.white, size: 26),
          onPressed: () {},
        ),
      ],
    );
  }
}

/// NavBar global — los 3 botones siempre visibles
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
          BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 10),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _NavBtn(icon: Icons.home_rounded,    index: 0, current: currentIndex, onTap: onTap),
          _NavBtn(icon: Icons.add,             index: 1, current: currentIndex, onTap: onTap, isCenter: true),
          _NavBtn(icon: Icons.bar_chart_rounded, index: 2, current: currentIndex, onTap: onTap),
        ],
      ),
    );
  }
}

class _NavBtn extends StatelessWidget {
  final IconData icon;
  final int index;
  final int current;
  final ValueChanged<int> onTap;
  final bool isCenter;

  const _NavBtn({
    required this.icon,
    required this.index,
    required this.current,
    required this.onTap,
    this.isCenter = false,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = current == index;

    if (isCenter) {
      return GestureDetector(
        onTap: () => onTap(index),
        child: Container(
          width: 52, height: 52,
          decoration: BoxDecoration(
            color: isActive ? AppColors.primary : const Color(0xFF3A2D9A),
            shape: BoxShape.circle,
            boxShadow: isActive
                ? [BoxShadow(
                    color: AppColors.primary.withOpacity(0.5),
                    blurRadius: 12, spreadRadius: 2)]
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
          color: isActive ? AppColors.navBarActive : Colors.transparent,
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

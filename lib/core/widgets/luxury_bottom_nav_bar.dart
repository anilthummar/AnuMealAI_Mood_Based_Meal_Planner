import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_colors.dart';

class LuxuryBottomNavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isSpecial;

  const LuxuryBottomNavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    this.isSpecial = false,
  });
}

class LuxuryBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemSelected;
  final List<LuxuryBottomNavItem> items;

  const LuxuryBottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
        border: Border(
          top: BorderSide(
            color: isDark ? const Color(0xFF2C2822) : const Color(0xFFF0EBE1),
            width: 1.2,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.06),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Container(
          height: 64,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(items.length, (index) {
              final item = items[index];
              final isSelected = selectedIndex == index;

              return Expanded(
                child: _NavBarItemTile(
                  item: item,
                  isSelected: isSelected,
                  isDark: isDark,
                  onTap: () {
                    HapticFeedback.selectionClick();
                    onItemSelected(index);
                  },
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _NavBarItemTile extends StatelessWidget {
  final LuxuryBottomNavItem item;
  final bool isSelected;
  final bool isDark;
  final VoidCallback onTap;

  const _NavBarItemTile({
    required this.item,
    required this.isSelected,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final activeGold = isDark ? AppColors.butterGold : AppColors.primaryGold;
    final activeBg = isDark
        ? const Color(0xFF2C2614)
        : AppColors.amberContainer.withValues(alpha: 0.7);
    final activeTextColor = isDark
        ? AppColors.butterGold
        : AppColors.primaryGoldDark;
    final inactiveColor = isDark
        ? const Color(0xFF8E8E93)
        : const Color(0xFF7A7A7A);

    return InkWell(
      onTap: onTap,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOutCubic,
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
        decoration: BoxDecoration(
          color: isSelected ? activeBg : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                AnimatedScale(
                  scale: isSelected ? 1.08 : 1.0,
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeInOutBack,
                  child: Icon(
                    isSelected ? item.activeIcon : item.icon,
                    size: 22,
                    color: isSelected ? activeGold : inactiveColor,
                  ),
                ),
                if (item.isSpecial)
                  Positioned(
                    top: -2,
                    right: -4,
                    child: Container(
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(
                        color: activeGold,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: activeGold.withValues(alpha: 0.6),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 3),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
                letterSpacing: isSelected ? -0.3 : -0.2,
                color: isSelected ? activeTextColor : inactiveColor,
              ),
              child: Text(
                item.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

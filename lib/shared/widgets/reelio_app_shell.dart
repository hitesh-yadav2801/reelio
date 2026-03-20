import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:reelio/core/theme/app_colors.dart';
import 'package:reelio/core/theme/app_spacing.dart';
import 'package:reelio/core/theme/app_typography.dart';

class ReelioAppShell extends StatelessWidget {
  const ReelioAppShell({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: Container(
        height: 60 + bottomInset,
        padding: EdgeInsets.only(bottom: bottomInset),
        decoration: const BoxDecoration(
          color: AppColors.colorSurfaceElevated,
          border: Border(top: BorderSide(color: AppColors.colorDivider)),
        ),
        child: Row(
          children: [
            _NavItem(
              icon: Icons.home_rounded,
              label: 'Feed',
              isSelected: navigationShell.currentIndex == 0,
              isUpload: false,
              onTap: () => _onTabSelected(0),
            ),
            _NavItem(
              icon: Icons.add_rounded,
              label: 'Upload',
              isSelected: navigationShell.currentIndex == 1,
              isUpload: true,
              onTap: () => _onTabSelected(1),
            ),
            _NavItem(
              icon: Icons.person_rounded,
              label: 'Profile',
              isSelected: navigationShell.currentIndex == 2,
              isUpload: false,
              onTap: () => _onTabSelected(2),
            ),
          ],
        ),
      ),
    );
  }

  void _onTabSelected(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.isUpload,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isSelected;
  final bool isUpload;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    if (isUpload) {
      return Expanded(
        child: GestureDetector(
          onTap: onTap,
          child: Center(
            child: Container(
              width: AppSpacing.space48,
              height: AppSpacing.space48,
              decoration: BoxDecoration(
                color: AppColors.colorAccentPrimary,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.colorDivider),
              ),
              child: Icon(icon, size: 28, color: AppColors.colorTextOnAccent),
            ),
          ),
        ),
      );
    }

    final iconColor = isSelected
        ? AppColors.colorAccentPrimary
        : AppColors.colorNeutralStone;
    final textColor = isSelected
        ? AppColors.colorAccentPrimary
        : AppColors.colorTextSecondary;

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 26, color: iconColor),
            const SizedBox(height: AppSpacing.space2),
            Text(
              label,
              style: AppTypography.overline.copyWith(color: textColor),
            ),
          ],
        ),
      ),
    );
  }
}

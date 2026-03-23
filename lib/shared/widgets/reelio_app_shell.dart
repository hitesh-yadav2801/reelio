import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:reelio/core/theme/app_colors.dart';
import 'package:reelio/core/theme/app_spacing.dart';
import 'package:reelio/core/theme/app_typography.dart';
import 'package:reelio/features/connectivity/presentation/bloc/connectivity_cubit.dart';

class ReelioAppShell extends StatelessWidget {
  const ReelioAppShell({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Scaffold(
      body: Stack(
        children: [
          navigationShell,
          BlocBuilder<ConnectivityCubit, ConnectivityState>(
            buildWhen: (previous, current) => previous.status != current.status,
            builder: (context, state) {
              final showOfflineBanner = state.isOffline;
              final topInset = MediaQuery.paddingOf(context).top;

              return AnimatedPositioned(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOut,
                top: showOfflineBanner ? 0 : -(topInset + 44),
                left: 0,
                right: 0,
                child: _OfflineBanner(topInset: topInset),
              );
            },
          ),
        ],
      ),
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

class _OfflineBanner extends StatelessWidget {
  const _OfflineBanner({required this.topInset});

  final double topInset;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.colorAccentAlert,
      elevation: 3,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.space16,
          topInset + AppSpacing.space8,
          AppSpacing.space16,
          AppSpacing.space8,
        ),
        child: Text(
          'No internet connection',
          textAlign: TextAlign.center,
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.colorTextOnAccent,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
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

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:reelio/core/theme/app_colors.dart';
import 'package:reelio/core/theme/app_typography.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({required this.onFinished, super.key});

  final VoidCallback onFinished;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  static const _minSplashDuration = Duration(milliseconds: 2500);
  static const _lineAnimationDuration = Duration(milliseconds: 1500);

  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(_minSplashDuration, _handleFinished);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _handleFinished() {
    if (!mounted) {
      return;
    }
    widget.onFinished();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.colorSurfaceWarm,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Reelio', style: AppTypography.display.copyWith(fontSize: 32)),
            const SizedBox(height: 16),
            TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0, end: 120),
              duration: _lineAnimationDuration,
              curve: Curves.easeInOut,
              builder: (context, width, child) {
                return SizedBox(width: width, child: child);
              },
              child: Container(
                height: 2,
                decoration: BoxDecoration(
                  color: AppColors.colorAccentPrimary,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

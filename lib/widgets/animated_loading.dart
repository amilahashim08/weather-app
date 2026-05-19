import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../utils/animations.dart';

/// Shimmer placeholders — Google-style loading on sky background.
class WeatherLoadingPlaceholder extends StatefulWidget {
  const WeatherLoadingPlaceholder({super.key});

  @override
  State<WeatherLoadingPlaceholder> createState() =>
      _WeatherLoadingPlaceholderState();
}

class _WeatherLoadingPlaceholderState extends State<WeatherLoadingPlaceholder>
    with SingleTickerProviderStateMixin {
  late final AnimationController _shimmer;

  @override
  void initState() {
    super.initState();
    _shimmer = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
  }

  @override
  void dispose() {
    _shimmer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeSlideIn(
      duration: AppMotion.fast,
      child: AnimatedBuilder(
        animation: _shimmer,
        builder: (context, _) {
          return Column(
            children: [
              _ShimmerBlock(
                animation: _shimmer,
                height: 140,
                borderRadius: 24,
              ),
              const SizedBox(height: AppSpacing.md),
              _ShimmerBlock(
                animation: _shimmer,
                height: 88,
                borderRadius: 24,
              ),
              const SizedBox(height: AppSpacing.md),
              _ShimmerBlock(
                animation: _shimmer,
                height: 200,
                borderRadius: 24,
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ShimmerBlock extends StatelessWidget {
  const _ShimmerBlock({
    required this.animation,
    required this.height,
    required this.borderRadius,
  });

  final Animation<double> animation;
  final double height;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final t = animation.value;
    return Container(
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        gradient: LinearGradient(
          begin: Alignment(-1 + t * 2, 0),
          end: Alignment(t * 2, 0),
          colors: [
            Colors.white.withValues(alpha: 0.15),
            Colors.white.withValues(alpha: 0.35),
            Colors.white.withValues(alpha: 0.15),
          ],
        ),
      ),
    );
  }
}

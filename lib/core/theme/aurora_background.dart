import 'package:flutter/material.dart';
import 'aurora_gradient_scheme.dart';

/// Animated Aurora gradient background driven by weather code.
///
/// 10-second flowing gradient animation.
class AuroraBackground extends StatefulWidget {
  final int weatherCode;
  final Widget child;

  const AuroraBackground({
    super.key,
    required this.weatherCode,
    required this.child,
  });

  @override
  State<AuroraBackground> createState() => _AuroraBackgroundState();
}

class _AuroraBackgroundState extends State<AuroraBackground>
    with TickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = WeatherGradientScheme.forCode(
      widget.weatherCode,
      isDark: isDark,
    );

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final t = _controller.value;
        final begin = Alignment(-1 + t, -0.5 + (t * 0.5));
        final end = Alignment(1 - t, 0.5 - (t * 0.5));

        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: begin,
              end: end,
              colors: colors,
              tileMode: TileMode.clamp,
            ),
          ),
          child: widget.child,
        );
      },
    );
  }
}

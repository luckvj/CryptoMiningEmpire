import 'package:flutter/material.dart';

/// Smooth animations and transitions for the app
class SmoothAnimations {
  // Animation durations
  static const Duration fast = Duration(milliseconds: 200);
  static const Duration normal = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 500);
  
  // Curves
  static const Curve defaultCurve = Curves.easeInOutCubic;
  static const Curve bounceCurve = Curves.elasticOut;
  static const Curve smoothCurve = Curves.easeOutCubic;
  
  /// Smooth scroll physics
  static const ScrollPhysics smoothScroll = BouncingScrollPhysics(
    parent: AlwaysScrollableScrollPhysics(),
  );
  
  /// Fade in animation
  static Widget fadeIn({
    required Widget child,
    Duration duration = normal,
    Duration delay = Duration.zero,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: duration,
      curve: defaultCurve,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: child,
        );
      },
      child: child,
    );
  }
  
  /// Slide in from bottom animation
  static Widget slideInFromBottom({
    required Widget child,
    Duration duration = normal,
    double offset = 50.0,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: offset, end: 0.0),
      duration: duration,
      curve: smoothCurve,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, value),
          child: Opacity(
            opacity: 1 - (value / offset).clamp(0.0, 1.0),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
  
  /// Scale animation
  static Widget scaleIn({
    required Widget child,
    Duration duration = normal,
    double begin = 0.8,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: begin, end: 1.0),
      duration: duration,
      curve: bounceCurve,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: child,
        );
      },
      child: child,
    );
  }
  
  /// Animated list item
  static Widget listItem({
    required Widget child,
    required int index,
    int maxDelay = 5,
  }) {
    final delay = Duration(milliseconds: (index * 50).clamp(0, maxDelay * 50));
    
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: normal + delay,
      curve: smoothCurve,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}

/// Hero transition wrapper
class HeroTransition extends StatelessWidget {
  final String tag;
  final Widget child;
  
  const HeroTransition({
    super.key,
    required this.tag,
    required this.child,
  });
  
  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: tag,
      child: Material(
        color: Colors.transparent,
        child: child,
      ),
    );
  }
}

/// Shimmer loading effect
class ShimmerLoading extends StatefulWidget {
  final Widget child;
  final Color baseColor;
  final Color highlightColor;
  
  const ShimmerLoading({
    super.key,
    required this.child,
    this.baseColor = const Color(0xFF1E293B),
    this.highlightColor = const Color(0xFF334155),
  });
  
  @override
  State<ShimmerLoading> createState() => _ShimmerLoadingState();
}

class _ShimmerLoadingState extends State<ShimmerLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                widget.baseColor,
                widget.highlightColor,
                widget.baseColor,
              ],
              stops: [
                _controller.value - 0.3,
                _controller.value,
                _controller.value + 0.3,
              ].map((e) => e.clamp(0.0, 1.0)).toList(),
            ).createShader(bounds);
          },
          child: widget.child,
        );
      },
    );
  }
}

/// Page transition builder
class SmoothPageRoute<T> extends MaterialPageRoute<T> {
  SmoothPageRoute({
    required super.builder,
    super.settings,
  });
  
  @override
  Duration get transitionDuration => const Duration(milliseconds: 300);
  
  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0.05, 0),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        )),
        child: child,
      ),
    );
  }
}

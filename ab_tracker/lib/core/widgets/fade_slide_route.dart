import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Helper pour les transitions animées
///
/// Usage : FadeSlideRoute.page(child: widget)
class FadeSlideRoute {
  static CustomTransitionPage<void> page({
    required Widget child,
    Duration duration = const Duration(milliseconds: 300),
  }) {
    return CustomTransitionPage<void>(
      child: child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        // ignore: unused_local_variable
        const begin = 0.0;
        // ignore: unused_local_variable
        const end = 1.0;
        final curve = Curves.easeInOut;

        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: curve,
        );

        return FadeTransition(
          opacity: curvedAnimation,
          child: SlideTransition(
            position: Tween(begin: const Offset(0.1, 0), end: Offset.zero)
                .animate(curvedAnimation),
            child: child,
          ),
        );
      },
      transitionDuration: duration,
    );
  }
}

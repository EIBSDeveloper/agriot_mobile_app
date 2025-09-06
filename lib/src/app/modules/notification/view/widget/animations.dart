import 'package:flutter/material.dart';

class SlideAnimation extends StatelessWidget {
  final Widget child;
  final Duration delay;

  const SlideAnimation({super.key, 
    required this.child,
    this.delay = Duration.zero,
  });

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
      animation: AnimationController(
        vsync: Navigator.of(context),
        duration: const Duration(milliseconds: 500),
      )..forward(),
      builder: (context, child) => SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(-1, 0),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: AnimationController(
              vsync: Navigator.of(context),
              duration: const Duration(milliseconds: 500),
            )..forward(from: delay.inMilliseconds / 1000),
            curve: Curves.easeOut,
          )),
          child: child,
        ),
      child: child,
    );
}

class FadeInAnimation extends StatelessWidget {
  final Widget child;
  final Duration delay;

  const FadeInAnimation({super.key, 
    required this.child,
    this.delay = Duration.zero,
  });

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
      animation: AnimationController(
        vsync: Navigator.of(context),
        duration: const Duration(milliseconds: 500),
      )..forward(),
      builder: (context, child) => FadeTransition(
          opacity: Tween<double>(
            begin: 0,
            end: 1,
          ).animate(CurvedAnimation(
            parent: AnimationController(
              vsync: Navigator.of(context),
              duration: const Duration(milliseconds: 500),
            )..forward(from: delay.inMilliseconds / 1000),
            curve: Curves.easeIn,
          )),
          child: child,
        ),
      child: child,
    );
}
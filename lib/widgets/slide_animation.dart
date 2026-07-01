import 'package:flutter/material.dart';

class SlideAnimation extends PageRouteBuilder {
  final Widget page;
  final AxisDirection direction;
  final Duration duration;

  SlideAnimation({
    required this.page,
    this.direction = AxisDirection.right,
    this.duration = const Duration(milliseconds: 400), // Durasi default 400ms
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const beginOffset = Offset(1.0, 0.0); // Geser dari kanan
            const endOffset = Offset.zero;

            // Menggunakan curve untuk animasi yang lebih smooth
            final curve = CurvedAnimation(
              parent: animation,
              curve: Curves.easeInOut, // Transisi smooth, mulai dan akhir perlahan
            );

            final offsetTween = Tween<Offset>(
              begin: _getBeginOffset(direction),
              end: endOffset,
            );

            final tween = Tween(begin: 0.0, end: 1.0).animate(curve);

            return SlideTransition(
              position: animation.drive(offsetTween),
              child: FadeTransition(
                opacity: tween,
                child: child,
              ),
            );
          },
        );

  static Offset _getBeginOffset(AxisDirection direction) {
    switch (direction) {
      case AxisDirection.up:
        return const Offset(0.0, 1.0);
      case AxisDirection.down:
        return const Offset(0.0, -1.0);
      case AxisDirection.left:
        return const Offset(1.0, 0.0); // Slide dari kanan
      case AxisDirection.right:
        return const Offset(-1.0, 0.0); // Slide dari kiri
    }
  }
}

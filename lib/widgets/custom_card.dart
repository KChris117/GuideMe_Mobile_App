import 'package:flutter/material.dart';

// Widget MainCard
class MainCard extends StatelessWidget {
  final Widget child;
  final double elevation;
  final Color color;
  final BorderRadiusGeometry borderRadius;

  const MainCard({
    Key? key,
    required this.child,
    this.elevation = 5.0,
    this.color = Colors.white,
    this.borderRadius = const BorderRadius.all(Radius.circular(5)),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: borderRadius,
      ),
      elevation: elevation,
      color: color,
      child: child,
    );
  }
}

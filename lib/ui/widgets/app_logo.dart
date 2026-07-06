import 'package:flutter/material.dart';

class AppLogo extends StatelessWidget {
  const AppLogo({super.key, this.size = 96, this.heroTag = "app-logo"});
  final double size;
  final String heroTag;

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: heroTag,
      child: SizedBox(
        width: size,
        height: size,
        child: ClipOval(
          child: Image.asset(
            'assets/image/logos.png',
            width: size,
            height: size,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}
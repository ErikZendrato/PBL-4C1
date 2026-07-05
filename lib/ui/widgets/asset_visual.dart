import 'dart:io';

import 'package:flutter/material.dart';

class AssetVisual extends StatelessWidget {
  const AssetVisual({
    super.key,
    required this.image,
    required this.size,
    this.backgroundColor,
  });

  final String image;
  final double size;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(size * 0.22);
    final file = image.isEmpty ? null : File(image);
    final hasFile = file != null && file.existsSync();

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor ?? const Color(0xFFE8EDF7),
        borderRadius: radius,
      ),
      clipBehavior: Clip.antiAlias,
      child: hasFile
          ? Image.file(
              file,
              fit: BoxFit.cover,
              width: size,
              height: size,
            )
          : Icon(
              Icons.inventory_2_rounded,
              size: size * 0.5,
              color: const Color(0xFF8A8D9D),
            ),
    );
  }
}
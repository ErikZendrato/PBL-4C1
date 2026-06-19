import 'package:flutter/material.dart';

class AssetVisual extends StatelessWidget {
  const AssetVisual({
    super.key,
    required this.image,
    this.size = 56,
    this.backgroundColor = const Color(0xFFF1EFF8),
  });

  final String image;
  final double size;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(_iconFor(image), color: Colors.black87, size: size * 0.62),
    );
  }

  IconData _iconFor(String value) {
    switch (value) {
      case "camera":
        return Icons.photo_camera_rounded;
      case "tripod":
        return Icons.camera_alt_rounded;
      case "lighting":
        return Icons.light_rounded;
      case "microphone":
        return Icons.mic_external_on_rounded;
      case "monitor":
        return Icons.desktop_windows_rounded;
      case "keyboard":
        return Icons.keyboard_rounded;
      case "mouse":
        return Icons.mouse_rounded;
      case "switch":
        return Icons.settings_input_component_rounded;
      case "wireless_adapter":
        return Icons.wifi_tethering_rounded;
      case "crimping":
        return Icons.construction_rounded;
      case "harddisk":
        return Icons.sd_storage_rounded;
      case "projector":
        return Icons.present_to_all_rounded;
      default:
        return Icons.inventory_2_rounded;
    }
  }
}

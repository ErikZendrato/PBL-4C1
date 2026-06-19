import 'package:flutter/material.dart';

class StatusChip extends StatelessWidget {
  const StatusChip({super.key, required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final style = _styleFor(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: style.background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: style.border),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: style.foreground,
          fontSize: 12,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  _ChipStyle _styleFor(String status) {
    switch (status) {
      case "Dipinjam":
        return const _ChipStyle(
          Color(0xFFE8F8EE),
          Color(0xFF2CA65A),
          Color(0xFF8BDEAB),
        );
      case "Selesai":
        return const _ChipStyle(
          Color(0xFFEAF2FF),
          Color(0xFF1463D8),
          Color(0xFF92BFFF),
        );
      case "Ditolak":
        return const _ChipStyle(
          Color(0xFFFFECEC),
          Color(0xFFD73D3D),
          Color(0xFFFFA7A7),
        );
      default:
        return const _ChipStyle(
          Color(0xFFFFF2DC),
          Color(0xFFF49B19),
          Color(0xFFFFD08A),
        );
    }
  }
}

class _ChipStyle {
  const _ChipStyle(this.background, this.foreground, this.border);

  final Color background;
  final Color foreground;
  final Color border;
}

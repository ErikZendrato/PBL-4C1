import 'package:flutter/material.dart';

import 'auth/login.dart';
import 'widgets/app_logo.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F4FA),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fade,
          child: SlideTransition(
            position: _slide,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 36, 24, 26),
              child: Column(
                children: [
                  const Spacer(),
                  const AppLogo(size: 102),
                  const SizedBox(height: 28),
                  const Text(
                    "ALAT LAB TI",
                    style: TextStyle(
                      fontSize: 27,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    "Peminjaman Alat Laboratorium\nJurusan Teknologi Informasi",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, height: 1.35),
                  ),
                  const Spacer(),
                  _RoleCard(
                    title: "Login Mahasiswa",
                    subtitle: "Akses Untuk Mahasiswa",
                    icon: Icons.person_rounded,
                    color: const Color(0xFF6D46D9),
                    background: Colors.white,
                    borderColor: const Color(0xFF6D46D9),
                    onTap: () => _openLogin("USER"),
                  ),
                  const SizedBox(height: 18),
                  _RoleCard(
                    title: "Login Admin Lab",
                    subtitle: "Akses Untuk Admin Lab",
                    icon: Icons.admin_panel_settings_rounded,
                    color: const Color(0xFF0B63D8),
                    background: const Color(0xFFEFF6FF),
                    borderColor: const Color(0xFF9EC8FF),
                    onTap: () => _openLogin("ADMIN"),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _openLogin(String role) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => LoginPage(role: role)),
    );
  }
}

class _RoleCard extends StatelessWidget {
  const _RoleCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.background,
    required this.borderColor,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final Color background;
  final Color borderColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Ink(
        height: 84,
        padding: const EdgeInsets.symmetric(horizontal: 18),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: borderColor, width: 1.5),
        ),
        child: Row(
          children: [
            Icon(icon, size: 34, color: color),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(color: color, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 6),
                  Text(subtitle, style: TextStyle(color: color, fontSize: 13)),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_rounded, color: color),
          ],
        ),
      ),
    );
  }
}

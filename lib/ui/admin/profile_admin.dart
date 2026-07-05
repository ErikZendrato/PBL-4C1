import 'package:flutter/material.dart';

import '../../models/users.dart';
import '../../services/auth_service.dart';
import '../splash.dart';

class ProfileAdmin extends StatefulWidget {
  const ProfileAdmin({super.key, required this.admin, required this.onUpdated});

  final UserModel? admin;
  final VoidCallback onUpdated;

  @override
  State<ProfileAdmin> createState() => _ProfileAdminState();
}

class _ProfileAdminState extends State<ProfileAdmin> {
  final _auth = AuthService();

  @override
  Widget build(BuildContext context) {
    final admin = widget.admin;

    return Scaffold(
      backgroundColor: const Color(0xFFE8EDF7),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 28, 20, 28),
          children: [
            Center(
              child: Column(
                children: [
                  Container(
                    width: 96,
                    height: 96,
                    decoration: const BoxDecoration(
                      color: Color(0xFF313498),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.admin_panel_settings_rounded,
                      color: Colors.white,
                      size: 56,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    admin?.name ?? "Admin Lab",
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF313498).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      admin?.lab.isNotEmpty == true ? admin!.lab : "-",
                      style: const TextStyle(
                        color: Color(0xFF313498),
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                children: [
                  _InfoTile(
                    icon: Icons.badge_outlined,
                    label: "Username",
                    value: admin?.nim ?? "-",
                  ),
                  const Divider(height: 1, indent: 18, endIndent: 18),
                  _InfoTile(
                    icon: Icons.call_outlined,
                    label: "No. HP",
                    value: admin?.phone.isNotEmpty == true ? admin!.phone : "-",
                  ),
                  const Divider(height: 1, indent: 18, endIndent: 18),
                  _InfoTile(
                    icon: Icons.science_outlined,
                    label: "Laboratorium",
                    value: admin?.lab.isNotEmpty == true ? admin!.lab : "-",
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: OutlinedButton.icon(
                onPressed: () => _showEditSheet(context),
                icon: const Icon(Icons.edit_outlined),
                label: const Text("Edit Profil"),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: FilledButton.icon(
                style: FilledButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () async {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (dialogContext) => AlertDialog(
                      title: const Text("Keluar akun?"),
                      content: const Text("Kamu akan keluar dari sesi admin ini."),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(dialogContext, false),
                          child: const Text("Batal"),
                        ),
                        FilledButton(
                          style: FilledButton.styleFrom(backgroundColor: Colors.red),
                          onPressed: () => Navigator.pop(dialogContext, true),
                          child: const Text("Keluar"),
                        ),
                      ],
                    ),
                  );

                  if (confirmed != true) {
                    return;
                  }

                  await _auth.logout();

                  if (!context.mounted) {
                    return;
                  }

                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const SplashPage()),
                    (route) => false,
                  );
                },
                icon: const Icon(Icons.logout_rounded),
                label: const Text("Logout"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showEditSheet(BuildContext context) async {
    final admin = widget.admin;

    if (admin == null || admin.id == null) {
      return;
    }

    final nameCtrl = TextEditingController(text: admin.name);
    final phoneCtrl = TextEditingController(text: admin.phone);
    final passwordCtrl = TextEditingController();

    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Edit Profil",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: "Nama"),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: phoneCtrl,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(labelText: "No. HP"),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: passwordCtrl,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: "Password baru",
                  hintText: "Kosongkan jika tidak diganti",
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: FilledButton(
                  onPressed: () async {
                    if (nameCtrl.text.trim().isEmpty) {
                      return;
                    }

                    await _auth.updateProfile(
                      id: admin.id!,
                      name: nameCtrl.text.trim(),
                      nim: admin.nim,
                      phone: phoneCtrl.text.trim(),
                      password: passwordCtrl.text.trim().isEmpty
                          ? admin.password
                          : passwordCtrl.text.trim(),
                      role: admin.role,
                    );

                    if (sheetContext.mounted) {
                      Navigator.pop(sheetContext, true);
                    }
                  },
                  child: const Text("Simpan"),
                ),
              ),
            ],
          ),
        );
      },
    );

    if (saved == true) {
      widget.onUpdated();
    }
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({required this.icon, required this.label, required this.value});

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF313498)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF8A8D9D))),
                const SizedBox(height: 2),
                Text(value, style: const TextStyle(fontWeight: FontWeight.w700)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
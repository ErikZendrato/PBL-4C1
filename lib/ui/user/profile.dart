import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../models/users.dart';
import '../../services/auth_service.dart';
import '../splash.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({
    super.key,
    this.embedded = false,
    this.user,
    this.onProfileChanged,
  });

  final bool embedded;
  final UserModel? user;
  final VoidCallback? onProfileChanged;

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _auth = AuthService();
  final _name = TextEditingController();
  final _nim = TextEditingController();
  final _phone = TextEditingController();
  final _password = TextEditingController();

  int? _loadedUserId;
  bool _hide = true;
  bool _loading = false;
  bool _editing = false;
  String _photoPath = "";

  @override
  void initState() {
    super.initState();
    _syncUser(widget.user);
  }

  @override
  void didUpdateWidget(covariant ProfilePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.user?.id != widget.user?.id) {
      _syncUser(widget.user);
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _nim.dispose();
    _phone.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.user;

    final content = user == null
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            child: Column(
              children: [
                _ProfileHeader(
                  photoPath: _photoPath,
                  onEditPhoto: _pickPhoto,
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
                  child: _editing
                      ? _buildEditForm()
                      : _buildReadOnlyView(),
                ),
              ],
            ),
          );

    if (widget.embedded) {
      return ColoredBox(color: const Color(0xFFF5F4FA), child: content);
    }

    return Scaffold(backgroundColor: const Color(0xFFF5F4FA), body: content);
  }

  Widget _buildReadOnlyView() {
    return Column(
      children: [
        _ReadOnlyField(
          icon: Icons.person_rounded,
          label: "Nama Lengkap",
          value: _name.text,
        ),
        _ReadOnlyField(
          icon: Icons.badge_rounded,
          label: "NIM",
          value: _nim.text,
        ),
        _ReadOnlyField(
          icon: Icons.phone_rounded,
          label: "Phone",
          value: _phone.text.isEmpty ? "-" : _phone.text,
        ),
        _ReadOnlyField(
          icon: Icons.lock_rounded,
          label: "Password",
          value: "•" * (_password.text.isEmpty ? 8 : _password.text.length),
          isLast: true,
        ),
        const SizedBox(height: 28),
        SizedBox(
          width: double.infinity,
          height: 54,
          child: OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF5B39D4),
              side: const BorderSide(color: Color(0xFF5B39D4)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            onPressed: () => setState(() => _editing = true),
            icon: const Icon(Icons.edit_rounded),
            label: const Text("Edit Profile"),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 54,
          child: FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            onPressed: _logout,
            icon: const Icon(Icons.logout_rounded),
            label: const Text("Logout"),
          ),
        ),
      ],
    );
  }

  Widget _buildEditForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: _name,
            decoration: const InputDecoration(
              labelText: "Nama Lengkap",
              prefixIcon: Icon(Icons.person_rounded),
            ),
            validator: (value) {
              if (value == null || value.trim().length < 3) {
                return "Nama minimal 3 karakter";
              }
              return null;
            },
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _nim,
            decoration: const InputDecoration(
              labelText: "NIM",
              prefixIcon: Icon(Icons.badge_rounded),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return "NIM wajib diisi";
              }
              return null;
            },
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _phone,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
              labelText: "Phone",
              prefixIcon: Icon(Icons.phone_rounded),
            ),
            validator: (value) {
              if (value == null || value.trim().length < 8) {
                return "Nomor telepon tidak valid";
              }
              return null;
            },
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _password,
            obscureText: _hide,
            decoration: InputDecoration(
              labelText: "Password",
              prefixIcon: const Icon(Icons.lock_rounded),
              suffixIcon: IconButton(
                onPressed: () => setState(() => _hide = !_hide),
                icon: Icon(
                  _hide
                      ? Icons.visibility_rounded
                      : Icons.visibility_off_rounded,
                ),
              ),
            ),
            validator: (value) {
              if (value == null || value.length < 6) {
                return "Password minimal 6 karakter";
              }
              return null;
            },
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF5B39D4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              onPressed: _loading ? null : _save,
              icon: _loading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2.3,
                      ),
                    )
                  : const Icon(Icons.save_rounded),
              label: const Text("Simpan Profile"),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF5B39D4),
                side: const BorderSide(color: Color(0xFF5B39D4)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              onPressed: _loading
                  ? null
                  : () {
                      _syncUser(widget.user, force: true);
                      setState(() => _editing = false);
                    },
              icon: const Icon(Icons.close_rounded),
              label: const Text("Batal"),
            ),
          ),
        ],
      ),
    );
  }

  void _syncUser(UserModel? user, {bool force = false}) {
    if (user == null || (!force && _loadedUserId == user.id)) {
      return;
    }

    _loadedUserId = user.id;
    _name.text = user.name;
    _nim.text = user.nim;
    _phone.text = user.phone;
    _password.text = user.password;
    _photoPath = user.photo;
  }

  Future<void> _pickPhoto() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera_rounded),
              title: const Text("Ambil Foto"),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_rounded),
              title: const Text("Pilih dari Galeri"),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );

    if (source == null) return;

    final picked = await ImagePicker().pickImage(
      source: source,
      maxWidth: 800,
      imageQuality: 85,
    );

    if (picked == null) return;

    setState(() => _photoPath = picked.path);

    final user = widget.user;
    if (user?.id != null) {
      await _auth.updateProfile(
        id: user!.id!,
        name: user.name,
        nim: user.nim,
        phone: user.phone,
        password: user.password,
        role: user.role,
        photo: picked.path,
      );
      widget.onProfileChanged?.call();
    }
  }

  Future<void> _save() async {
    final user = widget.user;

    if (user?.id == null || !_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _loading = true);

    await _auth.updateProfile(
      id: user!.id!,
      name: _name.text,
      nim: _nim.text,
      phone: _phone.text,
      password: _password.text,
      role: user.role,
      photo: _photoPath,
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _loading = false;
      _editing = false;
    });
    widget.onProfileChanged?.call();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Profile berhasil diperbarui."),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _logout() async {
    FocusScope.of(context).unfocus();
    await _auth.logout();

    if (!mounted) {
      return;
    }

    Navigator.of(context).pushAndRemoveUntil(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const SplashPage(),
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
      (route) => false,
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.photoPath, required this.onEditPhoto});

  final String photoPath;
  final VoidCallback onEditPhoto;

  @override
  Widget build(BuildContext context) {
    final hasPhoto = photoPath.isNotEmpty && File(photoPath).existsSync();

    return ClipPath(
      clipper: _ProfileClipper(),
      child: Container(
        height: 220,
        width: double.infinity,
        color: const Color(0xFF5B39D4),
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              const SizedBox(height: 16),
              const Text(
                "Profile",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 18),
              GestureDetector(
                onTap: onEditPhoto,
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    Container(
                      width: 86,
                      height: 86,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFFFFA54D),
                        border: Border.all(color: Colors.white, width: 4),
                        image: hasPhoto
                            ? DecorationImage(
                                image: FileImage(File(photoPath)),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: hasPhoto
                          ? null
                          : const Icon(
                              Icons.person_rounded,
                              size: 58,
                              color: Colors.white,
                            ),
                    ),
                    Container(
                      width: 28,
                      height: 28,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                      ),
                      child: const Icon(
                        Icons.edit_rounded,
                        size: 16,
                        color: Color(0xFF5B39D4),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    return Path()
      ..lineTo(0, size.height - 34)
      ..quadraticBezierTo(
        size.width * 0.25,
        size.height - 12,
        size.width * 0.5,
        size.height - 26,
      )
      ..quadraticBezierTo(
        size.width * 0.75,
        size.height - 40,
        size.width,
        size.height - 20,
      )
      ..lineTo(size.width, 0)
      ..close();
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

class _ReadOnlyField extends StatelessWidget {
  const _ReadOnlyField({
    required this.icon,
    required this.label,
    required this.value,
    this.isLast = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : const Border(
                bottom: BorderSide(color: Color(0xFFE0DFE8)),
              ),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.black87),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontSize: 12, color: Color(0xFF8A8D9D)),
                ),
                const SizedBox(height: 3),
                Text(
                  value.isEmpty ? "-" : value,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:peminjaman/ui/auth/login.dart';

import '../../services/auth_service.dart';
import '../../ui/user/dashboard.dart';
import '../../ui/widgets/app_logo.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _auth = AuthService();
  final _nama = TextEditingController();
  final _nim = TextEditingController();
  final _phone = TextEditingController();
  final _password = TextEditingController();

  bool _hide = true;
  bool _loading = false;

  @override
  void dispose() {
    _nama.dispose();
    _nim.dispose();
    _phone.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F4FA),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 18, 24, 28),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_rounded),
                  ),
                ),
                const SizedBox(height: 20),
                const AppLogo(size: 82),
                const SizedBox(height: 28),
                const Text(
                  "SIGN UP",
                  style: TextStyle(
                    fontSize: 23,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0,
                  ),
                ),
                const SizedBox(height: 28),
                _InputField(
                  label: "Full Name",
                  hint: "Masukan Nama Lengkap Anda",
                  controller: _nama,
                  textInputAction: TextInputAction.next,
                  validator: (value) {
                    if (value == null || value.trim().length < 3) {
                      return "Nama minimal 3 karakter";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                _InputField(
                  label: "NIM",
                  hint: "Masukan NIM Anda",
                  controller: _nim,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.next,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "NIM wajib diisi";
                    }
                    if (value.trim().length < 5) {
                      return "NIM terlalu pendek";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                _InputField(
                  label: "Phone Number",
                  hint: "Masukan Nomor Telepon Anda",
                  controller: _phone,
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.next,
                  validator: (value) {
                    if (value == null || value.trim().length < 8) {
                      return "Nomor telepon tidak valid";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                _InputField(
                  label: "Password",
                  hint: "Masukan Password Anda",
                  controller: _password,
                  obscureText: _hide,
                  suffixIcon: IconButton(
                    onPressed: () => setState(() => _hide = !_hide),
                    icon: Icon(
                      _hide
                          ? Icons.visibility_rounded
                          : Icons.visibility_off_rounded,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.length < 6) {
                      return "Password minimal 6 karakter";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: FilledButton(
                    onPressed: _loading ? null : _submit,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: _loading
                          ? const SizedBox(
                              key: ValueKey("loading"),
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              "Sign Up",
                              key: ValueKey("label"),
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _loading = true);

    try {
      final user = await _auth.register(
        name: _nama.text,
        nim: _nim.text,
        phone: _phone.text,
        password: _password.text,
      );

      await _auth.saveSession(user);

      if (!mounted) {
        return;
      }

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
        (route) => false,
      );
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("NIM sudah terdaftar atau data tidak valid."),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}

class _InputField extends StatelessWidget {
  const _InputField({
    required this.label,
    required this.hint,
    required this.controller,
    this.obscureText = false,
    this.suffixIcon,
    this.validator,
    this.keyboardType,
    this.textInputAction,
  });

  final String label;
  final String hint;
  final TextEditingController controller;
  final bool obscureText;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      validator: validator,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        suffixIcon: suffixIcon,
      ),
    );
  }
}

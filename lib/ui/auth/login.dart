import 'package:flutter/material.dart';

import '../../services/auth_service.dart';
import '../../ui/admin/dashboard_admin.dart';
import '../../ui/user/dashboard.dart';
import '../../ui/widgets/app_logo.dart';
import 'forgot_password_page.dart';
import 'register.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key, this.role = "USER"});

  final String role;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _auth = AuthService();
  final _nim = TextEditingController();
  final _password = TextEditingController();

  bool _hide = true;
  bool _loading = false;

  bool get _isAdmin => widget.role.toUpperCase() == "ADMIN";

  @override
  void dispose() {
    _nim.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F4FA),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 22, 24, 24),
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
                SizedBox(height: _isAdmin ? 30 : 22),
                const AppLogo(size: 88),
                const SizedBox(height: 32),
                Text(
                  _isAdmin ? "Admin Lab" : "Login Mahasiswa",
                  style: const TextStyle(
                    fontSize: 27,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  _isAdmin
                      ? "Masuk untuk mengelola\nPeminjaman alat"
                      : "Masuk untuk mengakses aplikasi",
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 14, height: 1.4),
                ),
                const SizedBox(height: 38),
                _InputField(
                  controller: _nim,
                  label: _isAdmin ? "Username" : "NIM",
                  hint: _isAdmin ? "Masukan Username Anda" : "Masukan NIM Anda",
                  textInputAction: TextInputAction.next,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return _isAdmin
                          ? "Username wajib diisi"
                          : "NIM wajib diisi";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 18),
                _InputField(
                  controller: _password,
                  label: "Password",
                  hint: "Masukan Password Anda",
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
                    if (value == null || value.isEmpty) {
                      return "Password wajib diisi";
                    }
                    return null;
                  },
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      if (_isAdmin) {
                        _showMessage("Silakan hubungi admin lab.");
                        return;
                      }

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ForgotPasswordPage(),
                        ),
                      );
                    },
                    child: const Text("forgot password?"),
                  ),
                ),
                const SizedBox(height: 8),
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
                          : Text(
                              _isAdmin ? "Masuk" : "Login",
                              key: const ValueKey("label"),
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                    ),
                  ),
                ),
                if (!_isAdmin) ...[
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Belum punya akun?"),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const RegisterPage(),
                            ),
                          );
                        },
                        child: const Text("Daftar di sini"),
                      ),
                    ],
                  ),
                ],
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

    final user = await _auth.login(
      _nim.text,
      _password.text,
      role: widget.role,
    );

    if (!mounted) {
      return;
    }

    setState(() => _loading = false);

    if (user == null) {
      _showMessage("NIM/username atau password tidak sesuai.");
      return;
    }

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) =>
            _isAdmin ? const DashboardAdmin() : const DashboardPage(),
      ),
      (route) => false,
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }
}

class _InputField extends StatelessWidget {
  const _InputField({
    required this.controller,
    required this.label,
    required this.hint,
    this.obscureText = false,
    this.suffixIcon,
    this.validator,
    this.textInputAction,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final bool obscureText;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  final TextInputAction? textInputAction;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      textInputAction: textInputAction,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        suffixIcon: suffixIcon,
      ),
    );
  }
}

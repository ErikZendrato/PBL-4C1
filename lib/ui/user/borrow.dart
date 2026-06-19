import 'package:flutter/material.dart';

import '../../models/asset.dart';
import '../../services/auth_service.dart';
import '../../services/borrow_service.dart';
import '../widgets/asset_visual.dart';
import 'dashboard.dart';

class BorrowPage extends StatefulWidget {
  const BorrowPage({super.key, required this.asset});

  final AssetModel asset;

  @override
  State<BorrowPage> createState() => _BorrowPageState();
}

class _BorrowPageState extends State<BorrowPage> {
  final _formKey = GlobalKey<FormState>();
  final _auth = AuthService();
  final _borrowService = BorrowService();
  final _description = TextEditingController();

  DateTime? _borrowDate;
  DateTime? _returnDate;
  String _purpose = "Tugas Mata Kuliah";
  bool _loading = false;

  final _purposeOptions = const [
    "Tugas Mata Kuliah",
    "Praktikum",
    "Penelitian",
    "Kegiatan Himpunan",
  ];

  @override
  void dispose() {
    _description.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F4FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF5B39D4),
        foregroundColor: Colors.white,
        title: const Text(
          "Form Peminjaman",
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 26, 20, 28),
          children: [
            _AssetSummary(asset: widget.asset),
            const SizedBox(height: 22),
            const _Label("Tanggal Pinjam"),
            _DateField(
              value: _borrowDate,
              hint: "ex : 24 Mei 2026",
              onTap: () => _pickDate(isBorrowDate: true),
            ),
            const SizedBox(height: 18),
            const _Label("Tanggal Kembali"),
            _DateField(
              value: _returnDate,
              hint: "ex : 25 Mei 2026",
              onTap: () => _pickDate(isBorrowDate: false),
            ),
            const SizedBox(height: 18),
            const _Label("Keperluan"),
            DropdownButtonFormField<String>(
              initialValue: _purpose,
              items: _purposeOptions
                  .map(
                    (item) => DropdownMenuItem(value: item, child: Text(item)),
                  )
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _purpose = value);
                }
              },
            ),
            const SizedBox(height: 18),
            const _Label("Deskripsi"),
            TextFormField(
              controller: _description,
              minLines: 4,
              maxLines: 6,
              decoration: const InputDecoration(
                hintText: "ex : Untuk keperluan proyek video tugas akhir",
              ),
              validator: (value) {
                if (value == null || value.trim().length < 8) {
                  return "Deskripsi minimal 8 karakter";
                }
                return null;
              },
            ),
            const SizedBox(height: 14),
            InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Upload jaminan masih opsional."),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              child: Ink(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFEDEBFA),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFD8D3E6)),
                ),
                child: const Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Upload Jaminan(Optional)",
                            style: TextStyle(fontWeight: FontWeight.w800),
                          ),
                          SizedBox(height: 6),
                          Text("Foto KTP/SIM", style: TextStyle(fontSize: 12)),
                        ],
                      ),
                    ),
                    Icon(Icons.upload_rounded),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
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
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : const Text("Ajukan Peminjaman", key: ValueKey("label")),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDate({required bool isBorrowDate}) async {
    final now = DateTime.now();
    final initial = isBorrowDate
        ? (_borrowDate ?? now)
        : (_returnDate ?? _borrowDate ?? now.add(const Duration(days: 1)));

    final date = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );

    if (date == null) {
      return;
    }

    setState(() {
      if (isBorrowDate) {
        _borrowDate = date;

        if (_returnDate != null && _returnDate!.isBefore(date)) {
          _returnDate = null;
        }
      } else {
        _returnDate = date;
      }
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_borrowDate == null || _returnDate == null) {
      _showMessage("Tanggal pinjam dan kembali wajib diisi.");
      return;
    }

    if (_returnDate!.isBefore(_borrowDate!)) {
      _showMessage("Tanggal kembali tidak boleh sebelum tanggal pinjam.");
      return;
    }

    final user = await _auth.currentUser();

    if (user?.id == null) {
      _showMessage("Session habis. Silakan login kembali.");
      return;
    }

    setState(() => _loading = true);

    await _borrowService.createBorrow(
      userId: user!.id!,
      assetId: widget.asset.id!,
      borrowDate: _borrowDate!,
      returnDate: _returnDate!,
      purpose: "$_purpose\n${_description.text.trim()}",
    );

    if (!mounted) {
      return;
    }

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const BorrowSuccessPage()),
      (route) => false,
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }
}

class BorrowSuccessPage extends StatelessWidget {
  const BorrowSuccessPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(28, 20, 28, 28),
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const DashboardPage(initialIndex: 1),
                      ),
                      (route) => false,
                    );
                  },
                  icon: const Icon(Icons.arrow_back_rounded),
                ),
              ),
              const Spacer(),
              Container(
                width: 84,
                height: 84,
                decoration: const BoxDecoration(
                  color: Color(0xFF2EBB58),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: Colors.white,
                  size: 58,
                ),
              ),
              const SizedBox(height: 30),
              const Text(
                "Pengajuan Terkirim",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0,
                ),
              ),
              const SizedBox(height: 28),
              const Text(
                "Data peminjaman kamu\ntelah disimpan.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, height: 1.35),
              ),
              const Spacer(flex: 2),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: FilledButton(
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const DashboardPage(initialIndex: 1),
                      ),
                      (route) => false,
                    );
                  },
                  child: const Text("Selesai"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AssetSummary extends StatelessWidget {
  const _AssetSummary({required this.asset});

  final AssetModel asset;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFD8D3E6)),
      ),
      child: Row(
        children: [
          AssetVisual(image: asset.image, size: 58),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  asset.name,
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 4),
                Text(
                  "Tersedia ${asset.stock} unit",
                  style: const TextStyle(
                    color: Color(0xFF6D46D9),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DateField extends StatelessWidget {
  const _DateField({
    required this.value,
    required this.hint,
    required this.onTap,
  });

  final DateTime? value;
  final String hint;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: InputDecorator(
        decoration: InputDecoration(
          hintText: hint,
          suffixIcon: const Icon(Icons.calendar_month_rounded),
        ),
        child: Text(
          value == null ? hint : _formatDate(value!),
          style: TextStyle(
            color: value == null ? const Color(0xFF9D98AD) : Colors.black,
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      "Jan",
      "Feb",
      "Mar",
      "Apr",
      "Mei",
      "Jun",
      "Jul",
      "Agu",
      "Sep",
      "Okt",
      "Nov",
      "Des",
    ];

    return "${date.day} ${months[date.month - 1]} ${date.year}";
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.w800)),
    );
  }
}

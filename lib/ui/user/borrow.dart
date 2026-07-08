// import 'dart:io';

// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:path/path.dart' as p;
// import 'package:path_provider/path_provider.dart';

// import '../../models/asset.dart';
// import '../../services/auth_service.dart';
// import '../../services/borrow_service.dart';
// import '../widgets/asset_visual.dart';
// import 'dashboard.dart';

// class BorrowPage extends StatefulWidget {
//   const BorrowPage({super.key, required this.asset});

//   final AssetModel asset;

//   @override
//   State<BorrowPage> createState() => _BorrowPageState();
// }

// class _BorrowPageState extends State<BorrowPage> {
//   final _formKey = GlobalKey<FormState>();
//   final _auth = AuthService();
//   final _borrowService = BorrowService();
//   final _description = TextEditingController();
//   final _picker = ImagePicker();

//   DateTime? _borrowDate;
//   DateTime? _returnDate;
//   String _purpose = "Tugas Mata Kuliah";
//   bool _loading = false;

//   File? _jaminanFile;
//   bool _jaminanError = false;

//   final _purposeOptions = const [
//     "Tugas Mata Kuliah",
//     "Praktikum",
//     "Penelitian",
//     "Kegiatan Himpunan",
//   ];

//   @override
//   void dispose() {
//     _description.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF5F4FA),
//       appBar: AppBar(
//         backgroundColor: const Color(0xFF5B39D4),
//         foregroundColor: Colors.white,
//         title: const Text(
//           "Form Peminjaman",
//           style: TextStyle(fontWeight: FontWeight.w900),
//         ),
//       ),
//       body: Form(
//         key: _formKey,
//         child: ListView(
//           padding: const EdgeInsets.fromLTRB(20, 26, 20, 28),
//           children: [
//             _AssetSummary(asset: widget.asset),
//             const SizedBox(height: 22),
//             const _Label("Tanggal Pinjam"),
//             _DateField(
//               value: _borrowDate,
//               hint: "ex : 24 Mei 2026",
//               onTap: () => _pickDate(isBorrowDate: true),
//             ),
//             const SizedBox(height: 18),
//             const _Label("Tanggal Kembali"),
//             _DateField(
//               value: _returnDate,
//               hint: "ex : 25 Mei 2026",
//               onTap: () => _pickDate(isBorrowDate: false),
//             ),
//             const SizedBox(height: 18),
//             const _Label("Keperluan"),
//             DropdownButtonFormField<String>(
//               initialValue: _purpose,
//               items: _purposeOptions
//                   .map(
//                     (item) => DropdownMenuItem(value: item, child: Text(item)),
//                   )
//                   .toList(),
//               onChanged: (value) {
//                 if (value != null) {
//                   setState(() => _purpose = value);
//                 }
//               },
//             ),
//             const SizedBox(height: 18),
//             const _Label("Deskripsi"),
//             TextFormField(
//               controller: _description,
//               minLines: 4,
//               maxLines: 6,
//               decoration: const InputDecoration(
//                 hintText: "ex : Untuk keperluan proyek video tugas akhir",
//               ),
//               validator: (value) {
//                 if (value == null || value.trim().length < 8) {
//                   return "Deskripsi minimal 8 karakter";
//                 }
//                 return null;
//               },
//             ),
//             const SizedBox(height: 14),
//             InkWell(
//               borderRadius: BorderRadius.circular(12),
//               onTap: _pickJaminan,
//               child: Ink(
//                 padding: const EdgeInsets.all(14),
//                 decoration: BoxDecoration(
//                   color: const Color(0xFFEDEBFA),
//                   borderRadius: BorderRadius.circular(12),
//                   border: Border.all(
//                     color: _jaminanError && _jaminanFile == null
//                         ? Colors.red
//                         : const Color(0xFFD8D3E6),
//                   ),
//                 ),
//                 child: Row(
//                   children: [
//                     if (_jaminanFile != null) ...[
//                       ClipRRect(
//                         borderRadius: BorderRadius.circular(8),
//                         child: Image.file(
//                           _jaminanFile!,
//                           width: 48,
//                           height: 48,
//                           fit: BoxFit.cover,
//                         ),
//                       ),
//                       const SizedBox(width: 12),
//                     ],
//                     Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           const Text(
//                             "Upload Jaminan (Foto KTM) *",
//                             style: TextStyle(fontWeight: FontWeight.w800),
//                           ),
//                           const SizedBox(height: 6),
//                           Text(
//                             _jaminanFile == null
//                                 ? "Wajib diisi. Ketuk untuk pilih foto KTM."
//                                 : "Foto terpilih. Ketuk untuk ganti.",
//                             style: TextStyle(
//                               fontSize: 12,
//                               color: _jaminanError && _jaminanFile == null
//                                   ? Colors.red
//                                   : null,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                     Icon(
//                       _jaminanFile == null
//                           ? Icons.upload_rounded
//                           : Icons.check_circle_rounded,
//                       color: _jaminanFile == null
//                           ? (_jaminanError ? Colors.red : null)
//                           : const Color(0xFF2EBB58),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//             const SizedBox(height: 30),
//             SizedBox(
//               height: 56,
//               child: FilledButton(
//                 onPressed: _loading ? null : _submit,
//                 child: AnimatedSwitcher(
//                   duration: const Duration(milliseconds: 200),
//                   child: _loading
//                       ? const SizedBox(
//                           key: ValueKey("loading"),
//                           width: 22,
//                           height: 22,
//                           child: CircularProgressIndicator(
//                             color: Colors.white,
//                             strokeWidth: 2.5,
//                           ),
//                         )
//                       : const Text("Ajukan Peminjaman", key: ValueKey("label")),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Future<void> _pickDate({required bool isBorrowDate}) async {
//     final now = DateTime.now();
//     final initial = isBorrowDate
//         ? (_borrowDate ?? now)
//         : (_returnDate ?? _borrowDate ?? now.add(const Duration(days: 1)));

//     final date = await showDatePicker(
//       context: context,
//       initialDate: initial,
//       firstDate: now,
//       lastDate: now.add(const Duration(days: 365)),
//     );

//     if (date == null) {
//       return;
//     }

//     setState(() {
//       if (isBorrowDate) {
//         _borrowDate = date;

//         if (_returnDate != null && _returnDate!.isBefore(date)) {
//           _returnDate = null;
//         }
//       } else {
//         _returnDate = date;
//       }
//     });
//   }

//   Future<void> _pickJaminan() async {
//     final source = await showModalBottomSheet<ImageSource>(
//       context: context,
//       builder: (context) => SafeArea(
//         child: Wrap(
//           children: [
//             ListTile(
//               leading: const Icon(Icons.photo_camera_rounded),
//               title: const Text("Ambil Foto"),
//               onTap: () => Navigator.pop(context, ImageSource.camera),
//             ),
//             ListTile(
//               leading: const Icon(Icons.photo_library_rounded),
//               title: const Text("Pilih dari Galeri"),
//               onTap: () => Navigator.pop(context, ImageSource.gallery),
//             ),
//           ],
//         ),
//       ),
//     );

//     if (source == null) {
//       return;
//     }

//     final picked = await _picker.pickImage(source: source, imageQuality: 80);

//     if (picked == null) {
//       return;
//     }

//     // Salin ke direktori aplikasi supaya path-nya permanen (tidak hilang
//     // walau file cache/gallery-nya dihapus/berubah).
//     final docsDir = await getApplicationDocumentsDirectory();
//     final jaminanDir = Directory(p.join(docsDir.path, "jaminan"));

//     if (!await jaminanDir.exists()) {
//       await jaminanDir.create(recursive: true);
//     }

//     final fileName =
//         "jaminan_${DateTime.now().millisecondsSinceEpoch}${p.extension(picked.path)}";
//     final savedFile = await File(
//       picked.path,
//     ).copy(p.join(jaminanDir.path, fileName));

//     setState(() {
//       _jaminanFile = savedFile;
//       _jaminanError = false;
//     });
//   }

//   Future<void> _submit() async {
//     if (!_formKey.currentState!.validate()) {
//       return;
//     }

//     if (_borrowDate == null || _returnDate == null) {
//       _showMessage("Tanggal pinjam dan kembali wajib diisi.");
//       return;
//     }

//     if (_returnDate!.isBefore(_borrowDate!)) {
//       _showMessage("Tanggal kembali tidak boleh sebelum tanggal pinjam.");
//       return;
//     }

//     if (_jaminanFile == null) {
//       setState(() => _jaminanError = true);
//       _showMessage("Foto KTM wajib diupload sebagai jaminan.");
//       return;
//     }

//     final user = await _auth.currentUser();

//     if (user?.id == null) {
//       _showMessage("Session habis. Silakan login kembali.");
//       return;
//     }

//     setState(() => _loading = true);

//     await _borrowService.createBorrow(
//       userId: user!.id!,
//       assetId: widget.asset.id!,
//       borrowDate: _borrowDate!,
//       returnDate: _returnDate!,
//       purpose: "$_purpose\n${_description.text.trim()}",
//       jaminanImage: _jaminanFile!.path,
//     );

//     if (!mounted) {
//       return;
//     }

//     Navigator.pushAndRemoveUntil(
//       context,
//       MaterialPageRoute(builder: (_) => const BorrowSuccessPage()),
//       (route) => false,
//     );
//   }

//   void _showMessage(String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
//     );
//   }
// }

// class BorrowSuccessPage extends StatelessWidget {
//   const BorrowSuccessPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.fromLTRB(28, 20, 28, 28),
//           child: Column(
//             children: [
//               Align(
//                 alignment: Alignment.centerLeft,
//                 child: IconButton(
//                   onPressed: () {
//                     Navigator.pushAndRemoveUntil(
//                       context,
//                       MaterialPageRoute(
//                         builder: (_) => const DashboardPage(initialIndex: 1),
//                       ),
//                       (route) => false,
//                     );
//                   },
//                   icon: const Icon(Icons.arrow_back_rounded),
//                 ),
//               ),
//               const Spacer(),
//               Container(
//                 width: 84,
//                 height: 84,
//                 decoration: const BoxDecoration(
//                   color: Color(0xFF2EBB58),
//                   shape: BoxShape.circle,
//                 ),
//                 child: const Icon(
//                   Icons.check_rounded,
//                   color: Colors.white,
//                   size: 58,
//                 ),
//               ),
//               const SizedBox(height: 30),
//               const Text(
//                 "Pengajuan Terkirim",
//                 style: TextStyle(
//                   fontSize: 22,
//                   fontWeight: FontWeight.w900,
//                   letterSpacing: 0,
//                 ),
//               ),
//               const SizedBox(height: 28),
//               const Text(
//                 "Data peminjaman kamu\ntelah disimpan.",
//                 textAlign: TextAlign.center,
//                 style: TextStyle(fontSize: 16, height: 1.35),
//               ),
//               const Spacer(flex: 2),
//               SizedBox(
//                 width: double.infinity,
//                 height: 56,
//                 child: FilledButton(
//                   onPressed: () {
//                     Navigator.pushAndRemoveUntil(
//                       context,
//                       MaterialPageRoute(
//                         builder: (_) => const DashboardPage(initialIndex: 1),
//                       ),
//                       (route) => false,
//                     );
//                   },
//                   child: const Text("Selesai"),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// class _AssetSummary extends StatelessWidget {
//   const _AssetSummary({required this.asset});

//   final AssetModel asset;

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.all(14),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: const Color(0xFFD8D3E6)),
//       ),
//       child: Row(
//         children: [
//           AssetVisual(image: asset.image, size: 58),
//           const SizedBox(width: 14),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   asset.name,
//                   style: const TextStyle(fontWeight: FontWeight.w900),
//                 ),
//                 const SizedBox(height: 4),
//                 Text(
//                   "Tersedia ${asset.stock} unit",
//                   style: const TextStyle(
//                     color: Color(0xFF6D46D9),
//                     fontSize: 12,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class _DateField extends StatelessWidget {
//   const _DateField({
//     required this.value,
//     required this.hint,
//     required this.onTap,
//   });

//   final DateTime? value;
//   final String hint;
//   final VoidCallback onTap;

//   @override
//   Widget build(BuildContext context) {
//     return InkWell(
//       borderRadius: BorderRadius.circular(12),
//       onTap: onTap,
//       child: InputDecorator(
//         decoration: InputDecoration(
//           hintText: hint,
//           suffixIcon: const Icon(Icons.calendar_month_rounded),
//         ),
//         child: Text(
//           value == null ? hint : _formatDate(value!),
//           style: TextStyle(
//             color: value == null ? const Color(0xFF9D98AD) : Colors.black,
//           ),
//         ),
//       ),
//     );
//   }

//   String _formatDate(DateTime date) {
//     const months = [
//       "Jan",
//       "Feb",
//       "Mar",
//       "Apr",
//       "Mei",
//       "Jun",
//       "Jul",
//       "Agu",
//       "Sep",
//       "Okt",
//       "Nov",
//       "Des",
//     ];

//     return "${date.day} ${months[date.month - 1]} ${date.year}";
//   }
// }

// class _Label extends StatelessWidget {
//   const _Label(this.text);

//   final String text;

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 8),
//       child: Text(text, style: const TextStyle(fontWeight: FontWeight.w800)),
//     );
//   }
// }

//====================================================================================================================

// import 'dart:io';

// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:path/path.dart' as p;
// import 'package:path_provider/path_provider.dart';

// import '../../models/asset.dart';
// import '../../services/auth_service.dart';
// import '../../services/borrow_service.dart';
// import '../widgets/asset_visual.dart';
// import 'dashboard.dart';

// class BorrowPage extends StatefulWidget {
//   const BorrowPage({super.key, required this.asset});

//   final AssetModel asset;

//   @override
//   State<BorrowPage> createState() => _BorrowPageState();
// }

// class _BorrowPageState extends State<BorrowPage> {
//   final _formKey = GlobalKey<FormState>();
//   final _auth = AuthService();
//   final _borrowService = BorrowService();
//   final _description = TextEditingController();
//   final _picker = ImagePicker();

//   DateTime? _borrowDate;
//   DateTime? _returnDate;
//   String _purpose = "Tugas Mata Kuliah";
//   bool _loading = false;
//   int _quantity = 1;

//   File? _jaminanFile;
//   bool _jaminanError = false;

//   final _purposeOptions = const [
//     "Tugas Mata Kuliah",
//     "Praktikum",
//     "Penelitian",
//     "Kegiatan Himpunan",
//   ];

//   int get _maxQuantity => widget.asset.stock < 1 ? 1 : widget.asset.stock;

//   @override
//   void dispose() {
//     _description.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF5F4FA),
//       appBar: AppBar(
//         backgroundColor: const Color(0xFF5B39D4),
//         foregroundColor: Colors.white,
//         title: const Text(
//           "Form Peminjaman",
//           style: TextStyle(fontWeight: FontWeight.w900),
//         ),
//       ),
//       body: Form(
//         key: _formKey,
//         child: ListView(
//           padding: const EdgeInsets.fromLTRB(20, 26, 20, 28),
//           children: [
//             _AssetSummary(asset: widget.asset),
//             const SizedBox(height: 18),
//             const _Label("Unit yang Dibutuhkan"),
//             _QuantityStepper(
//               quantity: _quantity,
//               maxQuantity: _maxQuantity,
//               onChanged: (value) => setState(() => _quantity = value),
//             ),
//             const SizedBox(height: 18),
//             const _Label("Tanggal Pinjam"),
//             _DateField(
//               value: _borrowDate,
//               hint: "ex : 24 Mei 2026",
//               onTap: () => _pickDate(isBorrowDate: true),
//             ),
//             const SizedBox(height: 18),
//             const _Label("Tanggal Kembali"),
//             _DateField(
//               value: _returnDate,
//               hint: "ex : 25 Mei 2026",
//               onTap: () => _pickDate(isBorrowDate: false),
//             ),
//             const SizedBox(height: 18),
//             const _Label("Keperluan"),
//             DropdownButtonFormField<String>(
//               initialValue: _purpose,
//               items: _purposeOptions
//                   .map(
//                     (item) => DropdownMenuItem(value: item, child: Text(item)),
//                   )
//                   .toList(),
//               onChanged: (value) {
//                 if (value != null) {
//                   setState(() => _purpose = value);
//                 }
//               },
//             ),
//             const SizedBox(height: 18),
//             const _Label("Deskripsi"),
//             TextFormField(
//               controller: _description,
//               minLines: 4,
//               maxLines: 6,
//               decoration: const InputDecoration(
//                 hintText: "ex : Untuk keperluan proyek video tugas akhir",
//               ),
//               validator: (value) {
//                 if (value == null || value.trim().length < 8) {
//                   return "Deskripsi minimal 8 karakter";
//                 }
//                 return null;
//               },
//             ),
//             const SizedBox(height: 14),
//             InkWell(
//               borderRadius: BorderRadius.circular(12),
//               onTap: _pickJaminan,
//               child: Ink(
//                 padding: const EdgeInsets.all(14),
//                 decoration: BoxDecoration(
//                   color: const Color(0xFFEDEBFA),
//                   borderRadius: BorderRadius.circular(12),
//                   border: Border.all(
//                     color: _jaminanError && _jaminanFile == null
//                         ? Colors.red
//                         : const Color(0xFFD8D3E6),
//                   ),
//                 ),
//                 child: Row(
//                   children: [
//                     if (_jaminanFile != null) ...[
//                       ClipRRect(
//                         borderRadius: BorderRadius.circular(8),
//                         child: Image.file(
//                           _jaminanFile!,
//                           width: 48,
//                           height: 48,
//                           fit: BoxFit.cover,
//                         ),
//                       ),
//                       const SizedBox(width: 12),
//                     ],
//                     Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           const Text(
//                             "Upload Jaminan (Foto KTM) *",
//                             style: TextStyle(fontWeight: FontWeight.w800),
//                           ),
//                           const SizedBox(height: 6),
//                           Text(
//                             _jaminanFile == null
//                                 ? "Wajib diisi. Ketuk untuk pilih foto KTM."
//                                 : "Foto terpilih. Ketuk untuk ganti.",
//                             style: TextStyle(
//                               fontSize: 12,
//                               color: _jaminanError && _jaminanFile == null
//                                   ? Colors.red
//                                   : null,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                     Icon(
//                       _jaminanFile == null
//                           ? Icons.upload_rounded
//                           : Icons.check_circle_rounded,
//                       color: _jaminanFile == null
//                           ? (_jaminanError ? Colors.red : null)
//                           : const Color(0xFF2EBB58),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//             const SizedBox(height: 30),
//             SizedBox(
//               height: 56,
//               child: FilledButton(
//                 onPressed: _loading ? null : _submit,
//                 child: AnimatedSwitcher(
//                   duration: const Duration(milliseconds: 200),
//                   child: _loading
//                       ? const SizedBox(
//                           key: ValueKey("loading"),
//                           width: 22,
//                           height: 22,
//                           child: CircularProgressIndicator(
//                             color: Colors.white,
//                             strokeWidth: 2.5,
//                           ),
//                         )
//                       : const Text("Ajukan Peminjaman", key: ValueKey("label")),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Future<void> _pickDate({required bool isBorrowDate}) async {
//     final now = DateTime.now();
//     final initial = isBorrowDate
//         ? (_borrowDate ?? now)
//         : (_returnDate ?? _borrowDate ?? now.add(const Duration(days: 1)));

//     final date = await showDatePicker(
//       context: context,
//       initialDate: initial,
//       firstDate: now,
//       lastDate: now.add(const Duration(days: 365)),
//     );

//     if (date == null) {
//       return;
//     }

//     setState(() {
//       if (isBorrowDate) {
//         _borrowDate = date;

//         if (_returnDate != null && _returnDate!.isBefore(date)) {
//           _returnDate = null;
//         }
//       } else {
//         _returnDate = date;
//       }
//     });
//   }

//   Future<void> _pickJaminan() async {
//     final source = await showModalBottomSheet<ImageSource>(
//       context: context,
//       builder: (context) => SafeArea(
//         child: Wrap(
//           children: [
//             ListTile(
//               leading: const Icon(Icons.photo_camera_rounded),
//               title: const Text("Ambil Foto"),
//               onTap: () => Navigator.pop(context, ImageSource.camera),
//             ),
//             ListTile(
//               leading: const Icon(Icons.photo_library_rounded),
//               title: const Text("Pilih dari Galeri"),
//               onTap: () => Navigator.pop(context, ImageSource.gallery),
//             ),
//           ],
//         ),
//       ),
//     );

//     if (source == null) {
//       return;
//     }

//     final picked = await _picker.pickImage(source: source, imageQuality: 80);

//     if (picked == null) {
//       return;
//     }

//     // Salin ke direktori aplikasi supaya path-nya permanen (tidak hilang
//     // walau file cache/gallery-nya dihapus/berubah).
//     final docsDir = await getApplicationDocumentsDirectory();
//     final jaminanDir = Directory(p.join(docsDir.path, "jaminan"));

//     if (!await jaminanDir.exists()) {
//       await jaminanDir.create(recursive: true);
//     }

//     final fileName =
//         "jaminan_${DateTime.now().millisecondsSinceEpoch}${p.extension(picked.path)}";
//     final savedFile = await File(
//       picked.path,
//     ).copy(p.join(jaminanDir.path, fileName));

//     setState(() {
//       _jaminanFile = savedFile;
//       _jaminanError = false;
//     });
//   }

//   Future<void> _submit() async {
//     if (!_formKey.currentState!.validate()) {
//       return;
//     }

//     if (_borrowDate == null || _returnDate == null) {
//       _showMessage("Tanggal pinjam dan kembali wajib diisi.");
//       return;
//     }

//     if (_returnDate!.isBefore(_borrowDate!)) {
//       _showMessage("Tanggal kembali tidak boleh sebelum tanggal pinjam.");
//       return;
//     }

//     if (_quantity < 1 || _quantity > _maxQuantity) {
//       _showMessage("Unit yang dibutuhkan melebihi stok tersedia.");
//       return;
//     }

//     if (_jaminanFile == null) {
//       setState(() => _jaminanError = true);
//       _showMessage("Foto KTM wajib diupload sebagai jaminan.");
//       return;
//     }

//     final user = await _auth.currentUser();

//     if (user?.id == null) {
//       _showMessage("Session habis. Silakan login kembali.");
//       return;
//     }

//     setState(() => _loading = true);

//     await _borrowService.createBorrow(
//       userId: user!.id!,
//       assetId: widget.asset.id!,
//       borrowDate: _borrowDate!,
//       returnDate: _returnDate!,
//       purpose: "$_purpose\n${_description.text.trim()}",
//       jaminanImage: _jaminanFile!.path,
//       quantity: _quantity,
//     );

//     if (!mounted) {
//       return;
//     }

//     Navigator.pushAndRemoveUntil(
//       context,
//       MaterialPageRoute(builder: (_) => const BorrowSuccessPage()),
//       (route) => false,
//     );
//   }

//   void _showMessage(String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
//     );
//   }
// }

// class BorrowSuccessPage extends StatelessWidget {
//   const BorrowSuccessPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.fromLTRB(28, 20, 28, 28),
//           child: Column(
//             children: [
//               Align(
//                 alignment: Alignment.centerLeft,
//                 child: IconButton(
//                   onPressed: () {
//                     Navigator.pushAndRemoveUntil(
//                       context,
//                       MaterialPageRoute(
//                         builder: (_) => const DashboardPage(initialIndex: 1),
//                       ),
//                       (route) => false,
//                     );
//                   },
//                   icon: const Icon(Icons.arrow_back_rounded),
//                 ),
//               ),
//               const Spacer(),
//               Container(
//                 width: 84,
//                 height: 84,
//                 decoration: const BoxDecoration(
//                   color: Color(0xFF2EBB58),
//                   shape: BoxShape.circle,
//                 ),
//                 child: const Icon(
//                   Icons.check_rounded,
//                   color: Colors.white,
//                   size: 58,
//                 ),
//               ),
//               const SizedBox(height: 30),
//               const Text(
//                 "Pengajuan Terkirim",
//                 style: TextStyle(
//                   fontSize: 22,
//                   fontWeight: FontWeight.w900,
//                   letterSpacing: 0,
//                 ),
//               ),
//               const SizedBox(height: 28),
//               const Text(
//                 "Data peminjaman kamu\ntelah disimpan.",
//                 textAlign: TextAlign.center,
//                 style: TextStyle(fontSize: 16, height: 1.35),
//               ),
//               const Spacer(flex: 2),
//               SizedBox(
//                 width: double.infinity,
//                 height: 56,
//                 child: FilledButton(
//                   onPressed: () {
//                     Navigator.pushAndRemoveUntil(
//                       context,
//                       MaterialPageRoute(
//                         builder: (_) => const DashboardPage(initialIndex: 1),
//                       ),
//                       (route) => false,
//                     );
//                   },
//                   child: const Text("Selesai"),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// class _AssetSummary extends StatelessWidget {
//   const _AssetSummary({required this.asset});

//   final AssetModel asset;

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.all(14),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: const Color(0xFFD8D3E6)),
//       ),
//       child: Row(
//         children: [
//           AssetVisual(image: asset.image, size: 58),
//           const SizedBox(width: 14),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   asset.name,
//                   style: const TextStyle(fontWeight: FontWeight.w900),
//                 ),
//                 const SizedBox(height: 4),
//                 Text(
//                   "Tersedia ${asset.stock} unit",
//                   style: const TextStyle(
//                     color: Color(0xFF6D46D9),
//                     fontSize: 12,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class _QuantityStepper extends StatelessWidget {
//   const _QuantityStepper({
//     required this.quantity,
//     required this.maxQuantity,
//     required this.onChanged,
//   });

//   final int quantity;
//   final int maxQuantity;
//   final ValueChanged<int> onChanged;

//   @override
//   Widget build(BuildContext context) {
//     final canIncrease = quantity < maxQuantity;
//     final canDecrease = quantity > 1;

//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: const Color(0xFFD8D3E6)),
//       ),
//       child: Row(
//         children: [
//           Expanded(
//             child: Text(
//               "$quantity unit",
//               style: const TextStyle(
//                 fontSize: 16,
//                 fontWeight: FontWeight.w800,
//               ),
//             ),
//           ),
//           Text(
//             "maks. $maxQuantity",
//             style: const TextStyle(
//               fontSize: 12,
//               color: Color(0xFF9D98AD),
//             ),
//           ),
//           const SizedBox(width: 6),
//           Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               InkWell(
//                 borderRadius: BorderRadius.circular(6),
//                 onTap: canIncrease ? () => onChanged(quantity + 1) : null,
//                 child: Padding(
//                   padding: const EdgeInsets.all(4),
//                   child: Icon(
//                     Icons.keyboard_arrow_up_rounded,
//                     color: canIncrease
//                         ? const Color(0xFF5B39D4)
//                         : const Color(0xFFD8D3E6),
//                   ),
//                 ),
//               ),
//               InkWell(
//                 borderRadius: BorderRadius.circular(6),
//                 onTap: canDecrease ? () => onChanged(quantity - 1) : null,
//                 child: Padding(
//                   padding: const EdgeInsets.all(4),
//                   child: Icon(
//                     Icons.keyboard_arrow_down_rounded,
//                     color: canDecrease
//                         ? const Color(0xFF5B39D4)
//                         : const Color(0xFFD8D3E6),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }

// class _DateField extends StatelessWidget {
//   const _DateField({
//     required this.value,
//     required this.hint,
//     required this.onTap,
//   });

//   final DateTime? value;
//   final String hint;
//   final VoidCallback onTap;

//   @override
//   Widget build(BuildContext context) {
//     return InkWell(
//       borderRadius: BorderRadius.circular(12),
//       onTap: onTap,
//       child: InputDecorator(
//         decoration: InputDecoration(
//           hintText: hint,
//           suffixIcon: const Icon(Icons.calendar_month_rounded),
//         ),
//         child: Text(
//           value == null ? hint : _formatDate(value!),
//           style: TextStyle(
//             color: value == null ? const Color(0xFF9D98AD) : Colors.black,
//           ),
//         ),
//       ),
//     );
//   }

//   String _formatDate(DateTime date) {
//     const months = [
//       "Jan",
//       "Feb",
//       "Mar",
//       "Apr",
//       "Mei",
//       "Jun",
//       "Jul",
//       "Agu",
//       "Sep",
//       "Okt",
//       "Nov",
//       "Des",
//     ];

//     return "${date.day} ${months[date.month - 1]} ${date.year}";
//   }
// }

// class _Label extends StatelessWidget {
//   const _Label(this.text);

//   final String text;

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 8),
//       child: Text(text, style: const TextStyle(fontWeight: FontWeight.w800)),
//     );
//   }
// }

//===========================================================================================================

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

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
  final _picker = ImagePicker();

  DateTime? _borrowDate;
  DateTime? _returnDate;
  String _purpose = "Tugas Mata Kuliah";
  bool _loading = false;
  int _quantity = 1;

  File? _jaminanFile;
  bool _jaminanError = false;

  final _purposeOptions = const [
    "Tugas Mata Kuliah",
    "Praktikum",
    "Penelitian",
    "Kegiatan Himpunan",
  ];

  int get _maxQuantity => widget.asset.stock < 1 ? 1 : widget.asset.stock;

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
            const SizedBox(height: 18),
            const _Label("Unit yang Dibutuhkan"),
            _QuantityStepper(
              quantity: _quantity,
              maxQuantity: _maxQuantity,
              onChanged: (value) => setState(() => _quantity = value),
            ),
            const SizedBox(height: 18),
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
              onTap: _pickJaminan,
              child: Ink(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFEDEBFA),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _jaminanError && _jaminanFile == null
                        ? Colors.red
                        : const Color(0xFFD8D3E6),
                  ),
                ),
                child: Row(
                  children: [
                    if (_jaminanFile != null) ...[
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          _jaminanFile!,
                          width: 48,
                          height: 48,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: 12),
                    ],
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Upload Jaminan (Foto KTM) *",
                            style: TextStyle(fontWeight: FontWeight.w800),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            _jaminanFile == null
                                ? "Wajib diisi. Ketuk untuk pilih foto KTM."
                                : "Foto terpilih. Ketuk untuk ganti.",
                            style: TextStyle(
                              fontSize: 12,
                              color: _jaminanError && _jaminanFile == null
                                  ? Colors.red
                                  : null,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      _jaminanFile == null
                          ? Icons.upload_rounded
                          : Icons.check_circle_rounded,
                      color: _jaminanFile == null
                          ? (_jaminanError ? Colors.red : null)
                          : const Color(0xFF2EBB58),
                    ),
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

  Future<void> _pickJaminan() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) => SafeArea(
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

    if (source == null) {
      return;
    }

    final picked = await _picker.pickImage(source: source, imageQuality: 80);

    if (picked == null) {
      return;
    }

    // Salin ke direktori aplikasi supaya path-nya permanen (tidak hilang
    // walau file cache/gallery-nya dihapus/berubah).
    final docsDir = await getApplicationDocumentsDirectory();
    final jaminanDir = Directory(p.join(docsDir.path, "jaminan"));

    if (!await jaminanDir.exists()) {
      await jaminanDir.create(recursive: true);
    }

    final fileName =
        "jaminan_${DateTime.now().millisecondsSinceEpoch}${p.extension(picked.path)}";
    final savedFile = await File(
      picked.path,
    ).copy(p.join(jaminanDir.path, fileName));

    setState(() {
      _jaminanFile = savedFile;
      _jaminanError = false;
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

    if (_quantity < 1 || _quantity > _maxQuantity) {
      _showMessage("Unit yang dibutuhkan melebihi stok tersedia.");
      return;
    }

    if (_jaminanFile == null) {
      setState(() => _jaminanError = true);
      _showMessage("Foto KTM wajib diupload sebagai jaminan.");
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
      jaminanImage: _jaminanFile!.path,
      quantity: _quantity,
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

class _QuantityStepper extends StatelessWidget {
  const _QuantityStepper({
    required this.quantity,
    required this.maxQuantity,
    required this.onChanged,
  });

  final int quantity;
  final int maxQuantity;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final canIncrease = quantity < maxQuantity;
    final canDecrease = quantity > 1;

    return InputDecorator(
      decoration: InputDecoration(
        suffixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
        suffixIcon: Padding(
          padding: const EdgeInsets.only(left: 6),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              InkWell(
                borderRadius: BorderRadius.circular(4),
                onTap: canIncrease ? () => onChanged(quantity + 1) : null,
                child: Icon(
                  Icons.keyboard_arrow_up_rounded,
                  size: 20,
                  color: canIncrease
                      ? const Color(0xFF5B39D4)
                      : const Color(0xFFD8D3E6),
                ),
              ),
              InkWell(
                borderRadius: BorderRadius.circular(4),
                onTap: canDecrease ? () => onChanged(quantity - 1) : null,
                child: Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: 20,
                  color: canDecrease
                      ? const Color(0xFF5B39D4)
                      : const Color(0xFFD8D3E6),
                ),
              ),
            ],
          ),
        ),
      ),
      child: Row(
        children: [
          Text(
            "$quantity unit",
            style: const TextStyle(fontSize: 16, color: Colors.black),
          ),
          const Spacer(),
          Text(
            "maks. $maxQuantity",
            style: const TextStyle(fontSize: 12, color: Color(0xFF9D98AD)),
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
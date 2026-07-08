// import 'dart:io';

// import 'package:flutter/material.dart';

// import '../../services/borrow_service.dart';
// import '../widgets/asset_visual.dart';
// import '../widgets/status_chip.dart';

// class RequestAdminPage extends StatefulWidget {
//   const RequestAdminPage({super.key, this.embedded = false, this.lab = ""});

//   final bool embedded;
//   final String lab;

//   @override
//   State<RequestAdminPage> createState() => _RequestAdminPageState();
// }

// class _RequestAdminPageState extends State<RequestAdminPage>
//     with SingleTickerProviderStateMixin {
//   late final TabController _tabController;
//   final _statuses = const ["Menunggu", "Dipinjam", "Selesai", "Ditolak"];

//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: _statuses.length, vsync: this);
//   }

//   @override
//   void dispose() {
//     _tabController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final content = Column(
//       children: [
//         SafeArea(
//           bottom: false,
//           child: Container(
//             width: double.infinity,
//             height: 76,
//             color: const Color(0xFF313498),
//             padding: const EdgeInsets.symmetric(horizontal: 18),
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 const Text(
//                   "Peminjaman",
//                   style: TextStyle(
//                     color: Colors.white,
//                     fontSize: 18,
//                     fontWeight: FontWeight.w900,
//                   ),
//                 ),
//                 if (widget.lab.isNotEmpty)
//                   Text(
//                     widget.lab,
//                     style: const TextStyle(
//                       color: Colors.white70,
//                       fontSize: 12,
//                     ),
//                   ),
//               ],
//             ),
//           ),
//         ),
//         Container(
//           color: const Color(0xFFE8EDF7),
//           child: TabBar(
//             controller: _tabController,
//             isScrollable: true,
//             labelColor: const Color(0xFF060899),
//             unselectedLabelColor: const Color(0xFF94928F),
//             indicatorColor: const Color(0xFF060899),
//             tabs: _statuses.map((status) => Tab(text: status)).toList(),
//           ),
//         ),
//         Expanded(
//           child: TabBarView(
//             controller: _tabController,
//             children: _statuses
//                 .map((status) => _RequestList(status: status, lab: widget.lab))
//                 .toList(),
//           ),
//         ),
//       ],
//     );

//     if (widget.embedded) {
//       return ColoredBox(color: const Color(0xFFE8EDF7), child: content);
//     }

//     return Scaffold(backgroundColor: const Color(0xFFE8EDF7), body: content);
//   }
// }

// class _RequestList extends StatefulWidget {
//   const _RequestList({required this.status, required this.lab});

//   final String status;
//   final String lab;

//   @override
//   State<_RequestList> createState() => _RequestListState();
// }

// class _RequestListState extends State<_RequestList> {
//   final _service = BorrowService();

//   @override
//   Widget build(BuildContext context) {
//     return FutureBuilder<List<Map<String, dynamic>>>(
//       future: _service.getAllBorrows(status: widget.status, lab: widget.lab),
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return const Center(child: CircularProgressIndicator());
//         }

//         final rows = snapshot.data ?? [];

//         if (rows.isEmpty) {
//           return _EmptyRequest(status: widget.status);
//         }

//         return RefreshIndicator(
//           onRefresh: () async => setState(() {}),
//           child: ListView.separated(
//             physics: const AlwaysScrollableScrollPhysics(),
//             padding: const EdgeInsets.fromLTRB(18, 24, 18, 28),
//             itemCount: rows.length,
//             separatorBuilder: (context, index) => const SizedBox(height: 14),
//             itemBuilder: (context, index) {
//               return _RequestCard(
//                 data: rows[index],
//                 onChanged: () => setState(() {}),
//               );
//             },
//           ),
//         );
//       },
//     );
//   }
// }

// class _RequestCard extends StatelessWidget {
//   const _RequestCard({required this.data, required this.onChanged});

//   final Map<String, dynamic> data;
//   final VoidCallback onChanged;

//   @override
//   Widget build(BuildContext context) {
//     final status = data["status"]?.toString() ?? "Menunggu";

//     return InkWell(
//       borderRadius: BorderRadius.circular(10),
//       onTap: () async {
//         final changed = await Navigator.push<bool>(
//           context,
//           MaterialPageRoute(builder: (_) => AdminBorrowDetailPage(data: data)),
//         );

//         if (changed == true) {
//           onChanged();
//         }
//       },
//       child: Ink(
//         padding: const EdgeInsets.all(14),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(10),
//           border: Border.all(color: const Color(0xFFDAD6E3)),
//         ),
//         child: Row(
//           children: [
//             AssetVisual(image: data["assetImage"]?.toString() ?? "", size: 64),
//             const SizedBox(width: 14),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     data["userName"]?.toString() ?? "-",
//                     maxLines: 1,
//                     overflow: TextOverflow.ellipsis,
//                     style: const TextStyle(
//                       fontSize: 17,
//                       fontWeight: FontWeight.w900,
//                     ),
//                   ),
//                   const SizedBox(height: 2),
//                   Text(
//                     data["assetName"]?.toString() ?? "-",
//                     maxLines: 1,
//                     overflow: TextOverflow.ellipsis,
//                     style: const TextStyle(fontSize: 13),
//                   ),
//                   const SizedBox(height: 2),
//                   Text(
//                     _formatRange(
//                       data["borrowDate"]?.toString() ?? "",
//                       data["returnDate"]?.toString() ?? "",
//                     ),
//                     style: const TextStyle(fontSize: 12),
//                   ),
//                 ],
//               ),
//             ),
//             const SizedBox(width: 8),
//             StatusChip(status: status),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class AdminBorrowDetailPage extends StatefulWidget {
//   const AdminBorrowDetailPage({super.key, required this.data});

//   final Map<String, dynamic> data;

//   @override
//   State<AdminBorrowDetailPage> createState() => _AdminBorrowDetailPageState();
// }

// class _AdminBorrowDetailPageState extends State<AdminBorrowDetailPage> {
//   final _service = BorrowService();
//   bool _loading = false;

//   @override
//   Widget build(BuildContext context) {
//     final status = widget.data["status"]?.toString() ?? "Menunggu";
//     final purposeParts = _splitPurpose(
//       widget.data["purpose"]?.toString() ?? "",
//     );

//     return Scaffold(
//       backgroundColor: const Color(0xFFE8EDF7),
//       appBar: AppBar(
//         backgroundColor: const Color(0xFF313498),
//         foregroundColor: Colors.white,
//         title: Text(
//           _titleFor(status),
//           style: const TextStyle(fontWeight: FontWeight.w900),
//         ),
//       ),
//       body: ListView(
//         padding: const EdgeInsets.fromLTRB(28, 28, 28, 32),
//         children: [
//           Center(child: StatusChip(status: status)),
//           const SizedBox(height: 28),
//           Row(
//             children: [
//               const CircleAvatar(
//                 radius: 22,
//                 backgroundColor: Colors.white,
//                 child: Icon(
//                   Icons.person_rounded,
//                   color: Colors.black,
//                   size: 34,
//                 ),
//               ),
//               const SizedBox(width: 14),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       widget.data["userName"]?.toString() ?? "-",
//                       style: const TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.w900,
//                       ),
//                     ),
//                     Text(widget.data["userNim"]?.toString() ?? "-"),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 28),
//           const _SectionTitle("informasi alat"),
//           Row(
//             children: [
//               AssetVisual(
//                 image: widget.data["assetImage"]?.toString() ?? "",
//                 size: 58,
//                 backgroundColor: Colors.white,
//               ),
//               const SizedBox(width: 14),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       widget.data["assetName"]?.toString() ?? "-",
//                       style: const TextStyle(fontWeight: FontWeight.w900),
//                     ),
//                     Text(widget.data["assetLab"]?.toString() ?? "-"),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 26),
//           const _SectionTitle("Jadwal Peminjaman"),
//           _InfoRow(
//             label: "Tanggal Peminjaman       : ",
//             value: _formatDate(widget.data["borrowDate"]?.toString() ?? ""),
//           ),
//           const SizedBox(height: 8),
//           _InfoRow(
//             label: "Tanggal Pengembalian    : ",
//             value: _formatDate(widget.data["returnDate"]?.toString() ?? ""),
//           ),
//           const SizedBox(height: 26),
//           const _SectionTitle("Keperluan"),
//           Text(purposeParts.$1),
//           const SizedBox(height: 24),
//           const _SectionTitle("Deskripsi"),
//           Text(purposeParts.$2),
//           const SizedBox(height: 24),
//           const _SectionTitle("Jaminan"),
//           _JaminanPreview(path: widget.data["jaminanImage"]?.toString() ?? ""),
//           const SizedBox(height: 28),
//           _ActionButtons(
//             status: status,
//             loading: _loading,
//             onReject: () => _updateStatus("Ditolak"),
//             onApprove: () => _updateStatus("Dipinjam"),
//             onDone: () => _updateStatus("Selesai"),
//           ),
//         ],
//       ),
//     );
//   }

//   Future<void> _updateStatus(String status) async {
//     setState(() => _loading = true);

//     final result = await _service.updateStatus(
//       widget.data["id"] as int,
//       status,
//     );

//     if (!mounted) {
//       return;
//     }

//     setState(() => _loading = false);

//     if (result == 0) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text("Status gagal diperbarui. Stok mungkin kosong."),
//           behavior: SnackBarBehavior.floating,
//         ),
//       );
//       return;
//     }

//     Navigator.pop(context, true);
//   }

//   String _titleFor(String status) {
//     if (status == "Menunggu") {
//       return "Detail Pengajuan";
//     }

//     if (status == "Selesai") {
//       return "Detail Selesai";
//     }

//     return "Detail Peminjaman";
//   }
// }

// class _ActionButtons extends StatelessWidget {
//   const _ActionButtons({
//     required this.status,
//     required this.loading,
//     required this.onReject,
//     required this.onApprove,
//     required this.onDone,
//   });

//   final String status;
//   final bool loading;
//   final VoidCallback onReject;
//   final VoidCallback onApprove;
//   final VoidCallback onDone;

//   @override
//   Widget build(BuildContext context) {
//     if (status == "Menunggu") {
//       return Row(
//         children: [
//           Expanded(
//             child: FilledButton(
//               style: FilledButton.styleFrom(backgroundColor: Colors.red),
//               onPressed: loading ? null : onReject,
//               child: const Text("Tolak"),
//             ),
//           ),
//           const SizedBox(width: 30),
//           Expanded(
//             child: FilledButton(
//               style: FilledButton.styleFrom(
//                 backgroundColor: const Color(0xFF2BAA55),
//               ),
//               onPressed: loading ? null : onApprove,
//               child: const Text("Setuju"),
//             ),
//           ),
//         ],
//       );
//     }

//     if (status == "Dipinjam") {
//       return SizedBox(
//         height: 52,
//         child: FilledButton(
//           style: FilledButton.styleFrom(
//             backgroundColor: const Color(0xFF1565D8),
//           ),
//           onPressed: loading ? null : onDone,
//           child: const Text("Tandai Dikembalikan"),
//         ),
//       );
//     }

//     return const SizedBox.shrink();
//   }
// }

// class _JaminanPreview extends StatelessWidget {
//   const _JaminanPreview({required this.path});

//   final String path;

//   @override
//   Widget build(BuildContext context) {
//     final file = File(path);
//     final hasFile = path.isNotEmpty && file.existsSync();

//     return InkWell(
//       borderRadius: BorderRadius.circular(14),
//       onTap: hasFile
//           ? () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder: (_) => Scaffold(
//                     backgroundColor: Colors.black,
//                     appBar: AppBar(
//                       backgroundColor: Colors.black,
//                       foregroundColor: Colors.white,
//                       title: const Text("Foto Jaminan"),
//                     ),
//                     body: Center(
//                       child: InteractiveViewer(child: Image.file(file)),
//                     ),
//                   ),
//                 ),
//               );
//             }
//           : null,
//       child: Container(
//         padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(14),
//         ),
//         child: Row(
//           children: [
//             if (hasFile) ...[
//               ClipRRect(
//                 borderRadius: BorderRadius.circular(6),
//                 child: Image.file(
//                   file,
//                   width: 40,
//                   height: 40,
//                   fit: BoxFit.cover,
//                 ),
//               ),
//               const SizedBox(width: 10),
//             ],
//             Expanded(
//               child: Text(
//                 hasFile ? "Lihat foto jaminan (KTM)" : "Tidak ada jaminan diupload",
//                 maxLines: 1,
//                 overflow: TextOverflow.ellipsis,
//                 style: const TextStyle(fontWeight: FontWeight.w800),
//               ),
//             ),
//             if (hasFile) const Icon(Icons.visibility_rounded),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class _SectionTitle extends StatelessWidget {
//   const _SectionTitle(this.text);

//   final String text;

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 10),
//       child: Text(
//         text,
//         style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
//       ),
//     );
//   }
// }

// class _InfoRow extends StatelessWidget {
//   const _InfoRow({required this.label, required this.value});

//   final String label;
//   final String value;

//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       children: [
//         Expanded(child: Text(label)),
//         Expanded(child: Text(value)),
//       ],
//     );
//   }
// }

// class _EmptyRequest extends StatelessWidget {
//   const _EmptyRequest({required this.status});

//   final String status;

//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: Padding(
//         padding: const EdgeInsets.all(28),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             const Icon(
//               Icons.inbox_outlined,
//               size: 66,
//               color: Color(0xFF8A8D9D),
//             ),
//             const SizedBox(height: 12),
//             Text(
//               "Belum ada peminjaman $status.",
//               textAlign: TextAlign.center,
//               style: const TextStyle(fontWeight: FontWeight.w800),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// (String, String) _splitPurpose(String value) {
//   final parts = value.split("\n");

//   if (parts.length == 1) {
//     return (parts.first.isEmpty ? "-" : parts.first, "-");
//   }

//   return (parts.first, parts.skip(1).join("\n"));
// }

// String _formatRange(String start, String end) {
//   return "${_formatDate(start)} - ${_formatDate(end)}";
// }

// String _formatDate(String value) {
//   final date = DateTime.tryParse(value);

//   if (date == null) {
//     return value;
//   }

//   const months = [
//     "januari",
//     "februari",
//     "maret",
//     "april",
//     "mei",
//     "juni",
//     "juli",
//     "agustus",
//     "september",
//     "oktober",
//     "november",
//     "desember",
//   ];

//   return "${date.day} ${months[date.month - 1]} ${date.year}";
// }

//==================================================================================================================

// import 'dart:io';

// import 'package:flutter/material.dart';

// import '../../services/borrow_service.dart';
// import '../widgets/asset_visual.dart';
// import '../widgets/status_chip.dart';

// class RequestAdminPage extends StatefulWidget {
//   const RequestAdminPage({super.key, this.embedded = false, this.lab = ""});

//   final bool embedded;
//   final String lab;

//   @override
//   State<RequestAdminPage> createState() => _RequestAdminPageState();
// }

// class _RequestAdminPageState extends State<RequestAdminPage>
//     with SingleTickerProviderStateMixin {
//   late final TabController _tabController;
//   final _statuses = const ["Menunggu", "Dipinjam", "Selesai", "Ditolak"];

//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: _statuses.length, vsync: this);
//   }

//   @override
//   void dispose() {
//     _tabController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final content = Column(
//       children: [
//         SafeArea(
//           bottom: false,
//           child: Container(
//             width: double.infinity,
//             height: 76,
//             color: const Color(0xFF313498),
//             padding: const EdgeInsets.symmetric(horizontal: 18),
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 const Text(
//                   "Peminjaman",
//                   style: TextStyle(
//                     color: Colors.white,
//                     fontSize: 18,
//                     fontWeight: FontWeight.w900,
//                   ),
//                 ),
//                 if (widget.lab.isNotEmpty)
//                   Text(
//                     widget.lab,
//                     style: const TextStyle(
//                       color: Colors.white70,
//                       fontSize: 12,
//                     ),
//                   ),
//               ],
//             ),
//           ),
//         ),
//         Container(
//           color: const Color(0xFFE8EDF7),
//           child: TabBar(
//             controller: _tabController,
//             isScrollable: true,
//             labelColor: const Color(0xFF060899),
//             unselectedLabelColor: const Color(0xFF94928F),
//             indicatorColor: const Color(0xFF060899),
//             tabs: _statuses.map((status) => Tab(text: status)).toList(),
//           ),
//         ),
//         Expanded(
//           child: TabBarView(
//             controller: _tabController,
//             children: _statuses
//                 .map((status) => _RequestList(status: status, lab: widget.lab))
//                 .toList(),
//           ),
//         ),
//       ],
//     );

//     if (widget.embedded) {
//       return ColoredBox(color: const Color(0xFFE8EDF7), child: content);
//     }

//     return Scaffold(backgroundColor: const Color(0xFFE8EDF7), body: content);
//   }
// }

// class _RequestList extends StatefulWidget {
//   const _RequestList({required this.status, required this.lab});

//   final String status;
//   final String lab;

//   @override
//   State<_RequestList> createState() => _RequestListState();
// }

// class _RequestListState extends State<_RequestList> {
//   final _service = BorrowService();

//   @override
//   Widget build(BuildContext context) {
//     return FutureBuilder<List<Map<String, dynamic>>>(
//       future: _service.getAllBorrows(status: widget.status, lab: widget.lab),
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return const Center(child: CircularProgressIndicator());
//         }

//         final rows = snapshot.data ?? [];

//         if (rows.isEmpty) {
//           return _EmptyRequest(status: widget.status);
//         }

//         return RefreshIndicator(
//           onRefresh: () async => setState(() {}),
//           child: ListView.separated(
//             physics: const AlwaysScrollableScrollPhysics(),
//             padding: const EdgeInsets.fromLTRB(18, 24, 18, 28),
//             itemCount: rows.length,
//             separatorBuilder: (context, index) => const SizedBox(height: 14),
//             itemBuilder: (context, index) {
//               return _RequestCard(
//                 data: rows[index],
//                 onChanged: () => setState(() {}),
//               );
//             },
//           ),
//         );
//       },
//     );
//   }
// }

// class _RequestCard extends StatelessWidget {
//   const _RequestCard({required this.data, required this.onChanged});

//   final Map<String, dynamic> data;
//   final VoidCallback onChanged;

//   @override
//   Widget build(BuildContext context) {
//     final status = data["status"]?.toString() ?? "Menunggu";
//     final quantity = (data["quantity"] as int?) ?? 1;

//     return InkWell(
//       borderRadius: BorderRadius.circular(10),
//       onTap: () async {
//         final changed = await Navigator.push<bool>(
//           context,
//           MaterialPageRoute(builder: (_) => AdminBorrowDetailPage(data: data)),
//         );

//         if (changed == true) {
//           onChanged();
//         }
//       },
//       child: Ink(
//         padding: const EdgeInsets.all(14),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(10),
//           border: Border.all(color: const Color(0xFFDAD6E3)),
//         ),
//         child: Row(
//           children: [
//             AssetVisual(image: data["assetImage"]?.toString() ?? "", size: 64),
//             const SizedBox(width: 14),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     data["userName"]?.toString() ?? "-",
//                     maxLines: 1,
//                     overflow: TextOverflow.ellipsis,
//                     style: const TextStyle(
//                       fontSize: 17,
//                       fontWeight: FontWeight.w900,
//                     ),
//                   ),
//                   const SizedBox(height: 2),
//                   Row(
//                     children: [
//                       Expanded(
//                         child: Text(
//                           data["assetName"]?.toString() ?? "-",
//                           maxLines: 1,
//                           overflow: TextOverflow.ellipsis,
//                           style: const TextStyle(fontSize: 13),
//                         ),
//                       ),
//                       Container(
//                         margin: const EdgeInsets.only(left: 6),
//                         padding: const EdgeInsets.symmetric(
//                           horizontal: 8,
//                           vertical: 2,
//                         ),
//                         decoration: BoxDecoration(
//                           color: const Color(0xFFEDEBFA),
//                           borderRadius: BorderRadius.circular(6),
//                         ),
//                         child: Text(
//                           "x$quantity",
//                           style: const TextStyle(
//                             fontSize: 11,
//                             fontWeight: FontWeight.w800,
//                             color: Color(0xFF5B39D4),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 2),
//                   Text(
//                     _formatRange(
//                       data["borrowDate"]?.toString() ?? "",
//                       data["returnDate"]?.toString() ?? "",
//                     ),
//                     style: const TextStyle(fontSize: 12),
//                   ),
//                 ],
//               ),
//             ),
//             const SizedBox(width: 8),
//             StatusChip(status: status),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class AdminBorrowDetailPage extends StatefulWidget {
//   const AdminBorrowDetailPage({super.key, required this.data});

//   final Map<String, dynamic> data;

//   @override
//   State<AdminBorrowDetailPage> createState() => _AdminBorrowDetailPageState();
// }

// class _AdminBorrowDetailPageState extends State<AdminBorrowDetailPage> {
//   final _service = BorrowService();
//   bool _loading = false;

//   @override
//   Widget build(BuildContext context) {
//     final status = widget.data["status"]?.toString() ?? "Menunggu";
//     final quantity = (widget.data["quantity"] as int?) ?? 1;
//     final purposeParts = _splitPurpose(
//       widget.data["purpose"]?.toString() ?? "",
//     );

//     return Scaffold(
//       backgroundColor: const Color(0xFFE8EDF7),
//       appBar: AppBar(
//         backgroundColor: const Color(0xFF313498),
//         foregroundColor: Colors.white,
//         title: Text(
//           _titleFor(status),
//           style: const TextStyle(fontWeight: FontWeight.w900),
//         ),
//       ),
//       body: ListView(
//         padding: const EdgeInsets.fromLTRB(28, 28, 28, 32),
//         children: [
//           Center(child: StatusChip(status: status)),
//           const SizedBox(height: 28),
//           Row(
//             children: [
//               const CircleAvatar(
//                 radius: 22,
//                 backgroundColor: Colors.white,
//                 child: Icon(
//                   Icons.person_rounded,
//                   color: Colors.black,
//                   size: 34,
//                 ),
//               ),
//               const SizedBox(width: 14),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       widget.data["userName"]?.toString() ?? "-",
//                       style: const TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.w900,
//                       ),
//                     ),
//                     Text(widget.data["userNim"]?.toString() ?? "-"),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 28),
//           const _SectionTitle("informasi alat"),
//           Row(
//             children: [
//               AssetVisual(
//                 image: widget.data["assetImage"]?.toString() ?? "",
//                 size: 58,
//                 backgroundColor: Colors.white,
//               ),
//               const SizedBox(width: 14),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       widget.data["assetName"]?.toString() ?? "-",
//                       style: const TextStyle(fontWeight: FontWeight.w900),
//                     ),
//                     Text(widget.data["assetLab"]?.toString() ?? "-"),
//                   ],
//                 ),
//               ),
//               Container(
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 12,
//                   vertical: 6,
//                 ),
//                 decoration: BoxDecoration(
//                   color: const Color(0xFFEDEBFA),
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: Text(
//                   "$quantity unit",
//                   style: const TextStyle(
//                     fontWeight: FontWeight.w900,
//                     color: Color(0xFF5B39D4),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 26),
//           const _SectionTitle("Jadwal Peminjaman"),
//           _InfoRow(
//             label: "Tanggal Peminjaman       : ",
//             value: _formatDate(widget.data["borrowDate"]?.toString() ?? ""),
//           ),
//           const SizedBox(height: 8),
//           _InfoRow(
//             label: "Tanggal Pengembalian    : ",
//             value: _formatDate(widget.data["returnDate"]?.toString() ?? ""),
//           ),
//           const SizedBox(height: 8),
//           _InfoRow(
//             label: "Unit yang Dibutuhkan     : ",
//             value: "$quantity unit",
//           ),
//           const SizedBox(height: 26),
//           const _SectionTitle("Keperluan"),
//           Text(purposeParts.$1),
//           const SizedBox(height: 24),
//           const _SectionTitle("Deskripsi"),
//           Text(purposeParts.$2),
//           const SizedBox(height: 24),
//           const _SectionTitle("Jaminan"),
//           _JaminanPreview(path: widget.data["jaminanImage"]?.toString() ?? ""),
//           const SizedBox(height: 28),
//           _ActionButtons(
//             status: status,
//             loading: _loading,
//             onReject: () => _updateStatus("Ditolak"),
//             onApprove: () => _updateStatus("Dipinjam"),
//             onDone: () => _updateStatus("Selesai"),
//           ),
//         ],
//       ),
//     );
//   }

//   Future<void> _updateStatus(String status) async {
//     setState(() => _loading = true);

//     final result = await _service.updateStatus(
//       widget.data["id"] as int,
//       status,
//     );

//     if (!mounted) {
//       return;
//     }

//     setState(() => _loading = false);

//     if (result == 0) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text("Status gagal diperbarui. Stok mungkin kosong."),
//           behavior: SnackBarBehavior.floating,
//         ),
//       );
//       return;
//     }

//     Navigator.pop(context, true);
//   }

//   String _titleFor(String status) {
//     if (status == "Menunggu") {
//       return "Detail Pengajuan";
//     }

//     if (status == "Selesai") {
//       return "Detail Selesai";
//     }

//     return "Detail Peminjaman";
//   }
// }

// class _ActionButtons extends StatelessWidget {
//   const _ActionButtons({
//     required this.status,
//     required this.loading,
//     required this.onReject,
//     required this.onApprove,
//     required this.onDone,
//   });

//   final String status;
//   final bool loading;
//   final VoidCallback onReject;
//   final VoidCallback onApprove;
//   final VoidCallback onDone;

//   @override
//   Widget build(BuildContext context) {
//     if (status == "Menunggu") {
//       return Row(
//         children: [
//           Expanded(
//             child: FilledButton(
//               style: FilledButton.styleFrom(backgroundColor: Colors.red),
//               onPressed: loading ? null : onReject,
//               child: const Text("Tolak"),
//             ),
//           ),
//           const SizedBox(width: 30),
//           Expanded(
//             child: FilledButton(
//               style: FilledButton.styleFrom(
//                 backgroundColor: const Color(0xFF2BAA55),
//               ),
//               onPressed: loading ? null : onApprove,
//               child: const Text("Setuju"),
//             ),
//           ),
//         ],
//       );
//     }

//     if (status == "Dipinjam") {
//       return SizedBox(
//         height: 52,
//         child: FilledButton(
//           style: FilledButton.styleFrom(
//             backgroundColor: const Color(0xFF1565D8),
//           ),
//           onPressed: loading ? null : onDone,
//           child: const Text("Tandai Dikembalikan"),
//         ),
//       );
//     }

//     return const SizedBox.shrink();
//   }
// }

// class _JaminanPreview extends StatelessWidget {
//   const _JaminanPreview({required this.path});

//   final String path;

//   @override
//   Widget build(BuildContext context) {
//     final file = File(path);
//     final hasFile = path.isNotEmpty && file.existsSync();

//     return InkWell(
//       borderRadius: BorderRadius.circular(14),
//       onTap: hasFile
//           ? () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder: (_) => Scaffold(
//                     backgroundColor: Colors.black,
//                     appBar: AppBar(
//                       backgroundColor: Colors.black,
//                       foregroundColor: Colors.white,
//                       title: const Text("Foto Jaminan"),
//                     ),
//                     body: Center(
//                       child: InteractiveViewer(child: Image.file(file)),
//                     ),
//                   ),
//                 ),
//               );
//             }
//           : null,
//       child: Container(
//         padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(14),
//         ),
//         child: Row(
//           children: [
//             if (hasFile) ...[
//               ClipRRect(
//                 borderRadius: BorderRadius.circular(6),
//                 child: Image.file(
//                   file,
//                   width: 40,
//                   height: 40,
//                   fit: BoxFit.cover,
//                 ),
//               ),
//               const SizedBox(width: 10),
//             ],
//             Expanded(
//               child: Text(
//                 hasFile ? "Lihat foto jaminan (KTM)" : "Tidak ada jaminan diupload",
//                 maxLines: 1,
//                 overflow: TextOverflow.ellipsis,
//                 style: const TextStyle(fontWeight: FontWeight.w800),
//               ),
//             ),
//             if (hasFile) const Icon(Icons.visibility_rounded),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class _SectionTitle extends StatelessWidget {
//   const _SectionTitle(this.text);

//   final String text;

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 10),
//       child: Text(
//         text,
//         style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
//       ),
//     );
//   }
// }

// class _InfoRow extends StatelessWidget {
//   const _InfoRow({required this.label, required this.value});

//   final String label;
//   final String value;

//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       children: [
//         Expanded(child: Text(label)),
//         Expanded(child: Text(value)),
//       ],
//     );
//   }
// }

// class _EmptyRequest extends StatelessWidget {
//   const _EmptyRequest({required this.status});

//   final String status;

//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: Padding(
//         padding: const EdgeInsets.all(28),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             const Icon(
//               Icons.inbox_outlined,
//               size: 66,
//               color: Color(0xFF8A8D9D),
//             ),
//             const SizedBox(height: 12),
//             Text(
//               "Belum ada peminjaman $status.",
//               textAlign: TextAlign.center,
//               style: const TextStyle(fontWeight: FontWeight.w800),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// (String, String) _splitPurpose(String value) {
//   final parts = value.split("\n");

//   if (parts.length == 1) {
//     return (parts.first.isEmpty ? "-" : parts.first, "-");
//   }

//   return (parts.first, parts.skip(1).join("\n"));
// }

// String _formatRange(String start, String end) {
//   return "${_formatDate(start)} - ${_formatDate(end)}";
// }

// String _formatDate(String value) {
//   final date = DateTime.tryParse(value);

//   if (date == null) {
//     return value;
//   }

//   const months = [
//     "januari",
//     "februari",
//     "maret",
//     "april",
//     "mei",
//     "juni",
//     "juli",
//     "agustus",
//     "september",
//     "oktober",
//     "november",
//     "desember",
//   ];

//   return "${date.day} ${months[date.month - 1]} ${date.year}";
// }


//==================================================================================================================

import 'dart:io';

import 'package:flutter/material.dart';

import '../../services/borrow_service.dart';
import '../widgets/asset_visual.dart';
import '../widgets/status_chip.dart';

class RequestAdminPage extends StatefulWidget {
  const RequestAdminPage({super.key, this.embedded = false, this.lab = ""});

  final bool embedded;
  final String lab;

  @override
  State<RequestAdminPage> createState() => _RequestAdminPageState();
}

class _RequestAdminPageState extends State<RequestAdminPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final _statuses = const ["Menunggu", "Dipinjam", "Selesai", "Ditolak"];
  final _service = BorrowService();

  Map<String, int> _counts = const {};
  bool _loadingCounts = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _statuses.length, vsync: this);
    _loadCounts();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadCounts() async {
    final rows = await _service.getAllBorrows(lab: widget.lab);

    final counts = <String, int>{for (final status in _statuses) status: 0};

    for (final row in rows) {
      final status = row["status"]?.toString() ?? "";
      if (counts.containsKey(status)) {
        counts[status] = (counts[status] ?? 0) + 1;
      }
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _counts = counts;
      _loadingCounts = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final content = Column(
      children: [
        SafeArea(
          bottom: false,
          child: Container(
            width: double.infinity,
            height: 76,
            color: const Color(0xFF313498),
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Peminjaman",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                if (widget.lab.isNotEmpty)
                  Text(
                    widget.lab,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
          ),
        ),
        Container(
          color: const Color(0xFFE8EDF7),
          child: TabBar(
            controller: _tabController,
            isScrollable: true,
            labelColor: const Color(0xFF060899),
            unselectedLabelColor: const Color(0xFF94928F),
            indicatorColor: const Color(0xFF060899),
            tabs: _statuses.map((status) {
              final showCount = status == "Menunggu" || status == "Dipinjam";
              final count = _counts[status] ?? 0;
              return Tab(
                text: (showCount && !_loadingCounts)
                    ? "$status ($count)"
                    : status,
              );
            }).toList(),
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: _statuses
                .map(
                  (status) => _RequestList(
                    status: status,
                    lab: widget.lab,
                    onStatusChanged: _loadCounts,
                  ),
                )
                .toList(),
          ),
        ),
      ],
    );

    if (widget.embedded) {
      return ColoredBox(color: const Color(0xFFE8EDF7), child: content);
    }

    return Scaffold(backgroundColor: const Color(0xFFE8EDF7), body: content);
  }
}

class _RequestList extends StatefulWidget {
  const _RequestList({
    required this.status,
    required this.lab,
    this.onStatusChanged,
  });

  final String status;
  final String lab;
  final VoidCallback? onStatusChanged;

  @override
  State<_RequestList> createState() => _RequestListState();
}

class _RequestListState extends State<_RequestList> {
  final _service = BorrowService();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _service.getAllBorrows(status: widget.status, lab: widget.lab),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final rows = snapshot.data ?? [];

        if (rows.isEmpty) {
          return _EmptyRequest(status: widget.status);
        }

        return RefreshIndicator(
          onRefresh: () async => setState(() {}),
          child: ListView.separated(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(18, 24, 18, 28),
            itemCount: rows.length,
            separatorBuilder: (context, index) => const SizedBox(height: 14),
            itemBuilder: (context, index) {
              return _RequestCard(
                data: rows[index],
                onChanged: () {
                  setState(() {});
                  widget.onStatusChanged?.call();
                },
              );
            },
          ),
        );
      },
    );
  }
}

class _RequestCard extends StatelessWidget {
  const _RequestCard({required this.data, required this.onChanged});

  final Map<String, dynamic> data;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final status = data["status"]?.toString() ?? "Menunggu";
    final quantity = (data["quantity"] as int?) ?? 1;

    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: () async {
        final changed = await Navigator.push<bool>(
          context,
          MaterialPageRoute(builder: (_) => AdminBorrowDetailPage(data: data)),
        );

        if (changed == true) {
          onChanged();
        }
      },
      child: Ink(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFDAD6E3)),
        ),
        child: Row(
          children: [
            AssetVisual(image: data["assetImage"]?.toString() ?? "", size: 64),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data["userName"]?.toString() ?? "-",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          data["assetName"]?.toString() ?? "-",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 13),
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(left: 6),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEDEBFA),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          "x$quantity",
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF5B39D4),
                            height: 1.0,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _formatRange(
                      data["borrowDate"]?.toString() ?? "",
                      data["returnDate"]?.toString() ?? "",
                    ),
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            StatusChip(status: status),
          ],
        ),
      ),
    );
  }
}

class AdminBorrowDetailPage extends StatefulWidget {
  const AdminBorrowDetailPage({super.key, required this.data});

  final Map<String, dynamic> data;

  @override
  State<AdminBorrowDetailPage> createState() => _AdminBorrowDetailPageState();
}

class _AdminBorrowDetailPageState extends State<AdminBorrowDetailPage> {
  final _service = BorrowService();
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    final status = widget.data["status"]?.toString() ?? "Menunggu";
    final quantity = (widget.data["quantity"] as int?) ?? 1;
    final purposeParts = _splitPurpose(
      widget.data["purpose"]?.toString() ?? "",
    );

    return Scaffold(
      backgroundColor: const Color(0xFFE8EDF7),
      appBar: AppBar(
        backgroundColor: const Color(0xFF313498),
        foregroundColor: Colors.white,
        title: Text(
          _titleFor(status),
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(28, 28, 28, 32),
        children: [
          Center(child: StatusChip(status: status)),
          const SizedBox(height: 28),
          Row(
            children: [
              const CircleAvatar(
                radius: 22,
                backgroundColor: Colors.white,
                child: Icon(
                  Icons.person_rounded,
                  color: Colors.black,
                  size: 34,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.data["userName"]?.toString() ?? "-",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(widget.data["userNim"]?.toString() ?? "-"),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),
          const _SectionTitle("informasi alat"),
          Row(
            children: [
              AssetVisual(
                image: widget.data["assetImage"]?.toString() ?? "",
                size: 58,
                backgroundColor: Colors.white,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.data["assetName"]?.toString() ?? "-",
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                    Text(widget.data["assetLab"]?.toString() ?? "-"),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFEDEBFA),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  "$quantity unit",
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF5B39D4),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 26),
          const _SectionTitle("Jadwal Peminjaman"),
          _InfoRow(
            label: "Tanggal Peminjaman",
            value: _formatDate(widget.data["borrowDate"]?.toString() ?? ""),
          ),
          const SizedBox(height: 8),
          _InfoRow(
            label: "Tanggal Pengembalian",
            value: _formatDate(widget.data["returnDate"]?.toString() ?? ""),
          ),
          const SizedBox(height: 8),
          _InfoRow(
            label: "Unit yang Dibutuhkan",
            value: "$quantity unit",
          ),
          const SizedBox(height: 26),
          const _SectionTitle("Keperluan"),
          Text(purposeParts.$1),
          const SizedBox(height: 24),
          const _SectionTitle("Deskripsi"),
          Text(purposeParts.$2),
          const SizedBox(height: 24),
          const _SectionTitle("Jaminan"),
          _JaminanPreview(path: widget.data["jaminanImage"]?.toString() ?? ""),
          const SizedBox(height: 28),
          _ActionButtons(
            status: status,
            loading: _loading,
            onReject: () => _updateStatus("Ditolak"),
            onApprove: () => _updateStatus("Dipinjam"),
            onDone: () => _updateStatus("Selesai"),
          ),
        ],
      ),
    );
  }

  Future<void> _updateStatus(String status) async {
    setState(() => _loading = true);

    final result = await _service.updateStatus(
      widget.data["id"] as int,
      status,
    );

    if (!mounted) {
      return;
    }

    setState(() => _loading = false);

    if (result == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Status gagal diperbarui. Stok mungkin kosong."),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    Navigator.pop(context, true);
  }

  String _titleFor(String status) {
    if (status == "Menunggu") {
      return "Detail Pengajuan";
    }

    if (status == "Selesai") {
      return "Detail Selesai";
    }

    return "Detail Peminjaman";
  }
}

class _ActionButtons extends StatelessWidget {
  const _ActionButtons({
    required this.status,
    required this.loading,
    required this.onReject,
    required this.onApprove,
    required this.onDone,
  });

  final String status;
  final bool loading;
  final VoidCallback onReject;
  final VoidCallback onApprove;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    if (status == "Menunggu") {
      return Row(
        children: [
          Expanded(
            child: FilledButton(
              style: FilledButton.styleFrom(backgroundColor: Colors.red),
              onPressed: loading ? null : onReject,
              child: const Text("Tolak"),
            ),
          ),
          const SizedBox(width: 30),
          Expanded(
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF2BAA55),
              ),
              onPressed: loading ? null : onApprove,
              child: const Text("Setuju"),
            ),
          ),
        ],
      );
    }

    if (status == "Dipinjam") {
      return SizedBox(
        height: 52,
        child: FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFF1565D8),
          ),
          onPressed: loading ? null : onDone,
          child: const Text("Tandai Dikembalikan"),
        ),
      );
    }

    return const SizedBox.shrink();
  }
}

class _JaminanPreview extends StatelessWidget {
  const _JaminanPreview({required this.path});

  final String path;

  @override
  Widget build(BuildContext context) {
    final file = File(path);
    final hasFile = path.isNotEmpty && file.existsSync();

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: hasFile
          ? () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => Scaffold(
                    backgroundColor: Colors.black,
                    appBar: AppBar(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      title: const Text("Foto Jaminan"),
                    ),
                    body: Center(
                      child: InteractiveViewer(child: Image.file(file)),
                    ),
                  ),
                ),
              );
            }
          : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            if (hasFile) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: Image.file(
                  file,
                  width: 40,
                  height: 40,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 10),
            ],
            Expanded(
              child: Text(
                hasFile ? "Lihat foto jaminan (KTM)" : "Tidak ada jaminan diupload",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
            if (hasFile) const Icon(Icons.visibility_rounded),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        text,
        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(label)),
        Expanded(child: Text(value)),
      ],
    );
  }
}

class _EmptyRequest extends StatelessWidget {
  const _EmptyRequest({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.inbox_outlined,
              size: 66,
              color: Color(0xFF8A8D9D),
            ),
            const SizedBox(height: 12),
            Text(
              "Belum ada peminjaman $status.",
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ],
        ),
      ),
    );
  }
}

(String, String) _splitPurpose(String value) {
  final parts = value.split("\n");

  if (parts.length == 1) {
    return (parts.first.isEmpty ? "-" : parts.first, "-");
  }

  return (parts.first, parts.skip(1).join("\n"));
}

String _formatRange(String start, String end) {
  return "${_formatDate(start)} - ${_formatDate(end)}";
}

String _formatDate(String value) {
  final date = DateTime.tryParse(value);

  if (date == null) {
    return value;
  }

  const months = [
    "januari",
    "februari",
    "maret",
    "april",
    "mei",
    "juni",
    "juli",
    "agustus",
    "september",
    "oktober",
    "november",
    "desember",
  ];

  return "${date.day} ${months[date.month - 1]} ${date.year}";
}